package sn.zig.patrimoine.model;

import jakarta.persistence.*;
import lombok.*;

/**
 * Entité JPA stockant les comptes inscrits depuis l'application mobile Flutter
 * Table MySQL : comptes_mobile (visible dans phpMyAdmin -> patrimoinedb)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "comptes_mobile")
public class CompteMobile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nom_complet", nullable = false)
    private String nomComplet;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "mot_de_passe", nullable = false)
    private String motDePasse;

    @Column(name = "telephone")
    private String telephone;

    @Column(name = "role")
    private String role; // TOURISTE, GUIDE

    @Column(name = "langues_parlees")
    private String languesParlees;

    @Column(name = "tarif_guide_journalier")
    private Double tarifGuideJournalier;
}
