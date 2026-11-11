package sn.zig.patrimoine.model;

import jakarta.persistence.*;
import lombok.*;

/**
 * Entité JPA stockant les réservations de visites touristiques (Pôle 2 / App Mobile)
 * Table MySQL : reservations_mobile (visible dans phpMyAdmin -> patrimoinedb)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "reservations_mobile")
public class ReservationMobile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "patrimoine_id", nullable = false)
    private Long patrimoineId;

    @Column(name = "nom_patrimoine", nullable = false)
    private String nomPatrimoine;

    @Column(name = "nom_touriste", nullable = false)
    private String nomTouriste;

    @Column(name = "date_visite", nullable = false)
    private String dateVisite;

    @Column(name = "creneau_horaire", nullable = false)
    private String creneauHoraire;

    @Column(name = "nombre_personnes", nullable = false)
    private int nombrePersonnes;

    @Column(name = "nom_guide")
    private String nomGuide;

    @Column(name = "montant_total", nullable = false)
    private double montantTotal;

    @Column(name = "mode_paiement", nullable = false)
    private String modePaiement; // WAVE, ORANGE_MONEY, SUR_PLACE

    @Column(name = "statut", nullable = false)
    private String statut; // EN_ATTENTE, CONFIRMEE, ANNULEE, EFFECTUEE

    @Column(name = "code_reservation", nullable = false, unique = true)
    private String codeReservation;
}
