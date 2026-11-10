package sn.zig.patrimoine.mappers;

import org.mapstruct.Mapper;
import sn.zig.patrimoine.dto.PatrimoineDto;
import sn.zig.patrimoine.model.Patrimoine;

/**
 * Interface Mapper MapStruct (TP 2 - Slide 9 Dr Lamine FATY).
 * Génère automatiquement le code de conversion bidirectionnelle entre Patrimoine et PatrimoineDto.
 */
@Mapper(componentModel = "spring")
public interface PatrimoineMapper {

    // Convertit le DTO reçu en Entité pour la base de données
    Patrimoine toEntity(PatrimoineDto patrimoineDto);

    // Convertit l'Entité sauvegardée en DTO pour la réponse API
    PatrimoineDto toDto(Patrimoine patrimoine);
}
