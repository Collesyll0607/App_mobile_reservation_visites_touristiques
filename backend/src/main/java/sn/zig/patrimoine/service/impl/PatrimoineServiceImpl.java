package sn.zig.patrimoine.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.zig.patrimoine.dto.PatrimoineDto;
import sn.zig.patrimoine.mappers.PatrimoineMapper;
import sn.zig.patrimoine.model.Patrimoine;
import sn.zig.patrimoine.repository.PatrimoineRepository;
import sn.zig.patrimoine.service.IPatrimoineService;

import java.util.List;

/**
 * Implémentation du service Patrimoine avec Mapping DTO (TP 2 - Slides 11 à 16 Dr Lamine FATY).
 */
@Service
@Transactional
@RequiredArgsConstructor
public class PatrimoineServiceImpl implements IPatrimoineService {

    private final PatrimoineRepository patrimoineRepository;
    private final PatrimoineMapper patrimoineMapper;

    // 1. Méthode savePatrimoine() (Slide 12)
    @Override
    public PatrimoineDto savePatrimoine(PatrimoineDto patrimoineDto) {
        // 1. Conversion DTO -> Entité
        Patrimoine patrimoine = patrimoineMapper.toEntity(patrimoineDto);
        // 2. Sauvegarde en BDD
        Patrimoine savedPatrimoine = patrimoineRepository.save(patrimoine);
        // 3. Conversion Entité -> DTO et retour
        return patrimoineMapper.toDto(savedPatrimoine);
    }

    // 2. Méthode getAllPatrimoines() (Slide 13)
    @Override
    @Transactional(readOnly = true)
    public List<PatrimoineDto> getAllPatrimoines() {
        return patrimoineRepository.findAll().stream()
                .map(patrimoineMapper::toDto)
                .toList();
    }

    // 3. Méthode getByIdPatrimoine() (Slide 14)
    @Override
    @Transactional(readOnly = true)
    public PatrimoineDto getByIdPatrimoine(Long id) {
        Patrimoine patrimoine = patrimoineRepository.findById(id).orElseThrow();
        return patrimoineMapper.toDto(patrimoine);
    }

    // 4. Méthode updatePatrimoine() (Slide 15)
    @Override
    public PatrimoineDto updatePatrimoine(Long id, PatrimoineDto patrimoineDto) {
        Patrimoine patrimoine = patrimoineRepository.findById(id).orElseThrow();

        patrimoine.setAdressePatrimoine(patrimoineDto.getAdressePatrimoine());
        patrimoine.setCodePatrimoine(patrimoineDto.getCodePatrimoine());
        patrimoine.setCapacitePatrimoine(patrimoineDto.getCapacitePatrimoine());
        patrimoine.setDescriptionPatrimoine(patrimoineDto.getDescriptionPatrimoine());
        patrimoine.setHistoriquePatrimoine(patrimoineDto.getHistoriquePatrimoine());
        patrimoine.setNomPatrimoine(patrimoineDto.getNomPatrimoine());
        patrimoine.setLatitudePatrimoine(patrimoineDto.getLatitudePatrimoine());
        patrimoine.setLongitudePatrimoine(patrimoineDto.getLongitudePatrimoine());

        Patrimoine savedPatrimoine = patrimoineRepository.save(patrimoine);
        return patrimoineMapper.toDto(savedPatrimoine);
    }

    // 5. Méthode deletePatrimoine() (Slide 16)
    @Override
    public void deletePatrimoine(Long id) {
        patrimoineRepository.deleteById(id);
    }
}
