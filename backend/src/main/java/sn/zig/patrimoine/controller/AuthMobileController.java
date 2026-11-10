package sn.zig.patrimoine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import sn.zig.patrimoine.model.CompteMobile;
import sn.zig.patrimoine.model.UtilisateurBdd;
import sn.zig.patrimoine.repository.CompteMobileRepository;
import sn.zig.patrimoine.repository.UtilisateurBddRepository;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Contrôleur REST d'authentification pour l'application mobile Flutter (Pôle 1 : Collé SYLL)
 * Synchronisé avec la table principale 'utilisateurs' (BCrypt) et 'comptes_mobile' de patrimoinedb.
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthMobileController {

    private final UtilisateurBddRepository utilisateurBddRepository;
    private final CompteMobileRepository compteRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @GetMapping("/users")
    public List<UtilisateurBdd> getAllUsers() {
        return utilisateurBddRepository.findAll();
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> payload) {
        String identifiant = payload.getOrDefault("email", "").trim();
        String password = payload.getOrDefault("motDePasse", "").trim();

        // 1. Recherche dans la table principale 'utilisateurs' (par email OU par username)
        Optional<UtilisateurBdd> optUser = utilisateurBddRepository.findByEmailIgnoreCase(identifiant);
        if (optUser.isEmpty()) {
            optUser = utilisateurBddRepository.findByUsernameIgnoreCase(identifiant);
        }

        if (optUser.isPresent()) {
            UtilisateurBdd u = optUser.get();
            boolean matchBcrypt = false;
            try {
                matchBcrypt = passwordEncoder.matches(password, u.getPassword());
            } catch (Exception ignored) {}

            if (matchBcrypt || u.getPassword().equals(password)) {
                Map<String, Object> response = new HashMap<>();
                response.put("id", u.getId());
                response.put("nomComplet", (u.getPrenom() != null ? u.getPrenom() + " " : "") + (u.getNom() != null ? u.getNom() : ""));
                response.put("email", u.getEmail());
                response.put("telephone", u.getTelephone() != null ? u.getTelephone() : "");
                response.put("role", "TOURISTE");
                response.put("languesParlees", u.getLangues() != null ? u.getLangues() : "Français");
                return ResponseEntity.ok(response);
            }
        }

        // 2. Recherche complémentaire dans 'comptes_mobile'
        Optional<CompteMobile> optMobile = compteRepository.findByEmailIgnoreCase(identifiant);
        if (optMobile.isPresent() && optMobile.get().getMotDePasse().equals(password)) {
            return ResponseEntity.ok(optMobile.get());
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("message", "Email/identifiant ou mot de passe incorrect."));
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody CompteMobile nouveau) {
        String email = nouveau.getEmail() != null ? nouveau.getEmail().trim() : "";
        if (email.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "L'email est obligatoire."));
        }
        if (utilisateurBddRepository.findByEmailIgnoreCase(email).isPresent()
                || compteRepository.findByEmailIgnoreCase(email).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("message", "Un compte existe déjà avec cet email dans MySQL."));
        }

        // Découpage Prénom / Nom pour la table 'utilisateurs'
        String nomComplet = nouveau.getNomComplet() != null ? nouveau.getNomComplet().trim() : "Touriste";
        String prenom = nomComplet;
        String nom = "Visiteur";
        if (nomComplet.contains(" ")) {
            int idx = nomComplet.lastIndexOf(" ");
            prenom = nomComplet.substring(0, idx).trim();
            nom = nomComplet.substring(idx + 1).trim();
        }
        String baseUsername = email.split("@")[0] + "_" + (System.currentTimeMillis() % 1000);

        UtilisateurBdd u = UtilisateurBdd.builder()
                .username(baseUsername)
                .password(passwordEncoder.encode(nouveau.getMotDePasse()))
                .prenom(prenom)
                .nom(nom)
                .email(email)
                .telephone(nouveau.getTelephone())
                .role("ROLE_TOURISTE")
                .actif(true)
                .guideValide(true)
                .langues(nouveau.getLanguesParlees())
                .dateInscription(LocalDateTime.now())
                .build();
        UtilisateurBdd savedBdd = utilisateurBddRepository.save(u);

        nouveau.setEmail(email);
        nouveau.setRole("TOURISTE");
        compteRepository.save(nouveau);

        Map<String, Object> response = new HashMap<>();
        response.put("id", savedBdd.getId());
        response.put("nomComplet", nomComplet);
        response.put("email", savedBdd.getEmail());
        response.put("telephone", savedBdd.getTelephone() != null ? savedBdd.getTelephone() : "");
        response.put("role", "TOURISTE");
        response.put("languesParlees", savedBdd.getLangues() != null ? savedBdd.getLangues() : "Français");
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> payload) {
        String identifiant = payload.getOrDefault("email", "").trim();
        String newPass = payload.getOrDefault("nouveauMotDePasse", "").trim();

        boolean found = false;

        Optional<UtilisateurBdd> optUser = utilisateurBddRepository.findByEmailIgnoreCase(identifiant);
        if (optUser.isEmpty()) {
            optUser = utilisateurBddRepository.findByUsernameIgnoreCase(identifiant);
        }
        if (optUser.isPresent()) {
            UtilisateurBdd u = optUser.get();
            u.setPassword(passwordEncoder.encode(newPass));
            utilisateurBddRepository.save(u);
            found = true;
        }

        Optional<CompteMobile> optMobile = compteRepository.findByEmailIgnoreCase(identifiant);
        if (optMobile.isPresent()) {
            CompteMobile c = optMobile.get();
            c.setMotDePasse(newPass);
            compteRepository.save(c);
            found = true;
        }

        if (!found) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Aucun compte trouvé avec cet email dans la base MySQL."));
        }
        return ResponseEntity.ok(Map.of("message", "Mot de passe mis à jour dans MySQL."));
    }

    @PutMapping("/profile/{id}")
    public ResponseEntity<?> updateProfile(@PathVariable("id") Long id,
                                           @RequestBody Map<String, String> payload) {
        Optional<UtilisateurBdd> opt = utilisateurBddRepository.findById(id);
        if (opt.isPresent()) {
            UtilisateurBdd u = opt.get();
            if (payload.containsKey("nomComplet")) {
                String nc = payload.get("nomComplet").trim();
                if (nc.contains(" ")) {
                    int idx = nc.lastIndexOf(" ");
                    u.setPrenom(nc.substring(0, idx).trim());
                    u.setNom(nc.substring(idx + 1).trim());
                } else {
                    u.setPrenom(nc);
                }
            }
            if (payload.containsKey("telephone")) {
                u.setTelephone(payload.get("telephone"));
            }
            if (payload.containsKey("languesParlees")) {
                u.setLangues(payload.get("languesParlees"));
            }
            utilisateurBddRepository.save(u);
        }
        return ResponseEntity.ok(Map.of("status", "updated"));
    }
}
