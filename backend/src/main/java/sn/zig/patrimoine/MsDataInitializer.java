package sn.zig.patrimoine;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import sn.zig.patrimoine.model.AvisMobile;
import sn.zig.patrimoine.model.CompteMobile;
import sn.zig.patrimoine.model.Patrimoine;
import sn.zig.patrimoine.model.UtilisateurBdd;
import sn.zig.patrimoine.repository.AvisMobileRepository;
import sn.zig.patrimoine.repository.CompteMobileRepository;
import sn.zig.patrimoine.repository.PatrimoineRepository;
import sn.zig.patrimoine.repository.UtilisateurBddRepository;

import java.time.LocalDateTime;

/**
 * Charge les données initiales dans MySQL (patrimoinedb) au démarrage de ms-patrimoine :
 * - Table 'patrimoines' (Sites touristiques)
 * - Table 'utilisateurs' (Comptes touristes avec BCrypt)
 * - Table 'comptes_mobile' (Comptes mobiles)
 * - Table 'avis_mobile' (Avis et notes des visiteurs)
 */
@Component
@RequiredArgsConstructor
public class MsDataInitializer implements CommandLineRunner {

    private final PatrimoineRepository patrimoineRepository;
    private final CompteMobileRepository compteMobileRepository;
    private final AvisMobileRepository avisMobileRepository;
    private final UtilisateurBddRepository utilisateurBddRepository;

    @Override
    public void run(String... args) {
        if (patrimoineRepository.count() == 0) {
            patrimoineRepository.save(Patrimoine.builder()
                    .codePatrimoine("PAT-ZIG-001")
                    .nomPatrimoine("Alliance Française de Ziguinchor")
                    .descriptionPatrimoine("Centre culturel majeur et monument historique au quartier Escale.")
                    .historiquePatrimoine("Édifice colonial rénové, haut lieu d'échanges artistiques et littéraires de Casamance.")
                    .adressePatrimoine("Rue du Général de Gaulle, Escale, Ziguinchor")
                    .capacitePatrimoine(150)
                    .latitudePatrimoine(12.5833)
                    .longitudePatrimoine(-16.2719)
                    .build());

            patrimoineRepository.save(Patrimoine.builder()
                    .codePatrimoine("PAT-ZIG-002")
                    .nomPatrimoine("Port et Marché aux Poissons de Boudody")
                    .descriptionPatrimoine("Marché traditionnel vibrant sur les berges du fleuve Casamance.")
                    .historiquePatrimoine("Embarcadère historique des pirogues vers les îles de l'embouchure.")
                    .adressePatrimoine("Quartier Boudody, bord du fleuve, Ziguinchor")
                    .capacitePatrimoine(500)
                    .latitudePatrimoine(12.5855)
                    .longitudePatrimoine(-16.2780)
                    .build());

            patrimoineRepository.save(Patrimoine.builder()
                    .codePatrimoine("PAT-CAS-003")
                    .nomPatrimoine("Cases à Impluvium d'Enampore & Mlomp")
                    .descriptionPatrimoine("Architecture traditionnelle unique circulaire conçue pour capter l'eau de pluie.")
                    .historiquePatrimoine("Chef-d'œuvre de l'ingénierie vernaculaire du peuple Diola Bandial.")
                    .adressePatrimoine("Village d'Enampore / Mlomp, Casamance")
                    .capacitePatrimoine(80)
                    .latitudePatrimoine(12.5614)
                    .longitudePatrimoine(-16.5831)
                    .build());

            patrimoineRepository.save(Patrimoine.builder()
                    .codePatrimoine("PAT-CAR-004")
                    .nomPatrimoine("Île Historique de Carabane")
                    .descriptionPatrimoine("Premier comptoir commercial français en Casamance (1836).")
                    .historiquePatrimoine("Vestiges de l'église bretonne, de l'ancien bagne et tombeau du Capitaine Protet.")
                    .adressePatrimoine("Embouchure du fleuve Casamance, Île de Carabane")
                    .capacitePatrimoine(300)
                    .latitudePatrimoine(12.5567)
                    .longitudePatrimoine(-16.7025)
                    .build());

            patrimoineRepository.save(Patrimoine.builder()
                    .codePatrimoine("PAT-ZIG-005")
                    .nomPatrimoine("Mémorial Le Joola de Ziguinchor")
                    .descriptionPatrimoine("Monument solennel et musée érigé au bord du fleuve Casamance en mémoire des victimes du naufrage du 26 septembre 2002.")
                    .historiquePatrimoine("Lieu de mémoire et d'histoire retraçant la tragédie maritime et rendant hommage aux familles casamançaises.")
                    .adressePatrimoine("Quai du Port de Ziguinchor, Escale")
                    .capacitePatrimoine(200)
                    .latitudePatrimoine(12.5872)
                    .longitudePatrimoine(-16.2735)
                    .build());

            System.out.println(">>> [ms-patrimoine] 5 sites patrimoniaux insérés dans MySQL (patrimoinedb) !");
        }

        if (utilisateurBddRepository.count() == 0) {
            BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
            utilisateurBddRepository.save(UtilisateurBdd.builder()
                    .username("touriste")
                    .password(encoder.encode("passer123"))
                    .prenom("Aïssatou")
                    .nom("Fall")
                    .email("aissatou.fall@gmail.com")
                    .telephone("+221 76 555 44 33")
                    .role("ROLE_TOURISTE")
                    .actif(true)
                    .guideValide(true)
                    .langues("Français")
                    .dateInscription(LocalDateTime.now())
                    .build());

            System.out.println(">>> [ms-patrimoine] Compte touriste par défaut inséré dans 'utilisateurs' (aissatou.fall@gmail.com / passer123) !");
        }

        if (compteMobileRepository.count() == 0) {
            compteMobileRepository.save(CompteMobile.builder()
                    .nomComplet("Collé Syll (Touriste)")
                    .email("touriste@uasz.sn")
                    .motDePasse("123456")
                    .telephone("+221 77 123 45 67")
                    .role("TOURISTE")
                    .languesParlees("Français, Wolof")
                    .build());

            compteMobileRepository.save(CompteMobile.builder()
                    .nomComplet("Mamadou Lamine Diedhiou")
                    .email("guide@uasz.sn")
                    .motDePasse("123456")
                    .telephone("+221 77 412 34 56")
                    .role("GUIDE")
                    .languesParlees("Français, Diola, Wolof, Anglais")
                    .tarifGuideJournalier(10000.0)
                    .build());

            System.out.println(">>> [ms-patrimoine] Comptes initiaux insérés dans MySQL (table comptes_mobile) !");
        }

        if (avisMobileRepository.count() == 0) {
            avisMobileRepository.save(AvisMobile.builder()
                    .patrimoineId(1L)
                    .auteur("Awa Diop")
                    .note(5)
                    .commentaire("Superbe découverte au cœur du quartier Escale de Ziguinchor !")
                    .datePublication("08/11/2026")
                    .build());
            avisMobileRepository.save(AvisMobile.builder()
                    .patrimoineId(4L)
                    .auteur("Jean-Marc Faye")
                    .note(5)
                    .commentaire("L'île de Carabane et son église bretonne sont incontournables en Casamance.")
                    .datePublication("09/11/2026")
                    .build());
        }
    }
}
