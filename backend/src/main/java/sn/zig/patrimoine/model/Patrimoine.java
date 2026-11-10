package sn.zig.patrimoine.model;

import jakarta.persistence.*;
import lombok.*;

/**
 * Entité JPA Patrimoine du microservice ms-patrimoine (TP1 & TP2 Dr Lamine FATY).
 * Modèle relationnel mappé avec la table 'patrimoines'.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "patrimoines")
public class Patrimoine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code")
    private String codePatrimoine;

    @Column(name = "nom", nullable = false)
    private String nomPatrimoine;

    @Lob
    @Column(name = "description", columnDefinition = "TEXT")
    private String descriptionPatrimoine;

    @Lob
    @Column(name = "historique", columnDefinition = "TEXT")
    private String historiquePatrimoine;

    @Column(name = "adresse")
    private String adressePatrimoine;

    @Column(name = "capacite")
    private int capacitePatrimoine;

    @Column(name = "latitude")
    private Double latitudePatrimoine;

    @Column(name = "longitude")
    private Double longitudePatrimoine;

    // --- Méthodes de compatibilité avec les anciens getters/setters TP1 ---
    public String getNom() { return nomPatrimoine; }
    public void setNom(String nom) { this.nomPatrimoine = nom; }

    public String getCode() { return codePatrimoine; }
    public void setCode(String code) { this.codePatrimoine = code; }

    public String getDescription() { return descriptionPatrimoine; }
    public void setDescription(String desc) { this.descriptionPatrimoine = desc; }

    public String getHistorique() { return historiquePatrimoine; }
    public void setHistorique(String hist) { this.historiquePatrimoine = hist; }

    public String getAdresse() { return adressePatrimoine; }
    public void setAdresse(String adr) { this.adressePatrimoine = adr; }

    public int getCapacite() { return capacitePatrimoine; }
    public void setCapacite(int cap) { this.capacitePatrimoine = cap; }
}
