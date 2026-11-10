package sn.zig.patrimoine.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object pour Patrimoine (TP 2 - Slide 7 Dr Lamine FATY).
 * Rôles : transport, découplage des couches, sécurité et optimisation.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PatrimoineDto {

    private Long id;
    private String nomPatrimoine;
    private String codePatrimoine;
    private String descriptionPatrimoine;
    private String historiquePatrimoine;
    private String adressePatrimoine;
    private int capacitePatrimoine;
    private Double latitudePatrimoine;
    private Double longitudePatrimoine;
}
