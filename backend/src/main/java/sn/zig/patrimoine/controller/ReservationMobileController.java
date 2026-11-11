package sn.zig.patrimoine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sn.zig.patrimoine.model.ReservationMobile;
import sn.zig.patrimoine.repository.ReservationMobileRepository;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Contrôleur REST des Réservations de Visites Touristiques (Flutter -> MySQL)
 * Expose /api/reservations pour sauvegarder, consulter, modifier le statut et supprimer.
 */
@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ReservationMobileController {

    private final ReservationMobileRepository reservationRepository;

    @GetMapping
    public List<ReservationMobile> getAllReservations() {
        return reservationRepository.findAllByOrderByIdDesc();
    }

    @GetMapping("/code/{code}")
    public ResponseEntity<ReservationMobile> getByCode(@PathVariable("code") String code) {
        return reservationRepository.findByCodeReservation(code)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ReservationMobile> saveReservation(@RequestBody ReservationMobile req) {
        // Si une réservation avec le même code existe déjà, on la met à jour sans doublon
        Optional<ReservationMobile> existingOpt =
                reservationRepository.findByCodeReservation(req.getCodeReservation());

        if (existingOpt.isPresent()) {
            ReservationMobile existing = existingOpt.get();
            existing.setPatrimoineId(req.getPatrimoineId());
            existing.setNomPatrimoine(req.getNomPatrimoine());
            existing.setNomTouriste(req.getNomTouriste());
            existing.setDateVisite(req.getDateVisite());
            existing.setCreneauHoraire(req.getCreneauHoraire());
            existing.setNombrePersonnes(req.getNombrePersonnes());
            existing.setNomGuide(req.getNomGuide());
            existing.setMontantTotal(req.getMontantTotal());
            existing.setModePaiement(req.getModePaiement());
            existing.setStatut(req.getStatut());
            return ResponseEntity.ok(reservationRepository.save(existing));
        }

        // Laisse MySQL générer l'ID auto-incrémenté pour les nouvelles insertions
        req.setId(null);
        ReservationMobile saved = reservationRepository.save(req);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{code}/statut")
    public ResponseEntity<ReservationMobile> updateStatut(
            @PathVariable("code") String code,
            @RequestBody Map<String, String> payload) {
        Optional<ReservationMobile> opt = reservationRepository.findByCodeReservation(code);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        String nouveauStatut = payload.getOrDefault("statut", "").trim();
        if (nouveauStatut.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        ReservationMobile res = opt.get();
        res.setStatut(nouveauStatut);
        return ResponseEntity.ok(reservationRepository.save(res));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<Void> deleteByCode(@PathVariable("code") String code) {
        Optional<ReservationMobile> opt = reservationRepository.findByCodeReservation(code);
        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        reservationRepository.delete(opt.get());
        return ResponseEntity.noContent().build();
    }
}
