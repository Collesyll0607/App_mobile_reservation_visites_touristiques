package sn.zig.patrimoine.model;

import jakarta.persistence.*;
import lombok.*;

/**
 * Entité JPA stockant les avis publiés depuis l'application mobile Flutter
 * Table MySQL : avis_mobile (visible dans phpMyAdmin -> patrimoinedb)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "avis_mobile")
public class AvisMobile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "patrimoine_id", nullable = false)
    private Long patrimoineId;

    @Column(name = "auteur", nullable = false)
    private String auteur;

    @Column(name = "note", nullable = false)
    private int note;

    @Column(name = "commentaire", columnDefinition = "TEXT")
    private String commentaire;

    @Column(name = "date_publication")
    private String datePublication;
}
