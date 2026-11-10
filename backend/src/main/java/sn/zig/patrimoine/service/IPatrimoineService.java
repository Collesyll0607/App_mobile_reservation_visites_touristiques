package sn.zig.patrimoine.service;

import sn.zig.patrimoine.dto.PatrimoineDto;

import java.util.List;

/**
 * Interface Service Métier IPatrimoineService (TP 2 - Slide 10 Dr Lamine FATY).
 * Toutes les méthodes manipulent désormais des objets DTO pour découpler l'API de la persistance.
 */
public interface IPatrimoineService {

    PatrimoineDto savePatrimoine(PatrimoineDto patrimoineDto);

    List<PatrimoineDto> getAllPatrimoines();

    PatrimoineDto getByIdPatrimoine(Long id);

    PatrimoineDto updatePatrimoine(Long id, PatrimoineDto patrimoineDto);

    void deletePatrimoine(Long id);
}
