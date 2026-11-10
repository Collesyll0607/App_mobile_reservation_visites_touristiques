package sn.zig.patrimoine.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Entité JPA mappée directement sur la table 'utilisateurs' de patrimoinedb
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "utilisateurs")
public class UtilisateurBdd {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 100)
    private String prenom;

    @Column(nullable = false, length = 100)
    private String nom;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(length = 30)
    private String telephone;

    @Column(nullable = false, length = 30)
    private String role;

    private Boolean actif;
    private Boolean guideValide;

    @Column(length = 255)
    private String langues;

    private LocalDateTime dateInscription;
}
