package sn.zig.patrimoine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sn.zig.patrimoine.dto.PatrimoineDto;
import sn.zig.patrimoine.service.IPatrimoineService;

import java.util.List;

/**
 * Contrôleur REST pour ms-patrimoine avec DTO (TP 2 - Slides 17 à 21 Dr Lamine FATY).
 * Expose les endpoints :
 * - GET    /api/patrimoines       (Slide 17)
 * - GET    /api/patrimoines/{id}  (Slide 18)
 * - POST   /api/patrimoines       (Slide 19)
 * - PUT    /api/patrimoines/{id}  (Slide 20)
 * - DELETE /api/patrimoines/{id}  (Slide 21)
 */
@RestController
@RequestMapping("/api/patrimoines")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PatrimoineController {

    private final IPatrimoineService patrimoineService;

    // 1. Récupérer tous les patrimoines (Slide 17)
    @GetMapping
    public List<PatrimoineDto> getAllPatrimoines() {
        return this.patrimoineService.getAllPatrimoines();
    }

    // 2. Récupérer un patrimoine par son ID (Slide 18)
    @GetMapping("/{id}")
    public ResponseEntity<PatrimoineDto> getPatrimoineById(@PathVariable("id") Long id) {
        try {
            PatrimoineDto dto = this.patrimoineService.getByIdPatrimoine(id);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 3. Créer un patrimoine (Slide 19)
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PatrimoineDto createPatrimoine(@RequestBody PatrimoineDto patrimoineDto) {
        return this.patrimoineService.savePatrimoine(patrimoineDto);
    }

    // 4. Mettre à jour un patrimoine (Slide 20)
    @PutMapping("/{id}")
    public ResponseEntity<PatrimoineDto> updatePatrimoine(@PathVariable("id") Long id,
                                                          @RequestBody PatrimoineDto patrimoineDto) {
        try {
            PatrimoineDto dto = this.patrimoineService.updatePatrimoine(id, patrimoineDto);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 5. Supprimer un patrimoine (Slide 21)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePatrimoine(@PathVariable("id") Long id) {
        try {
            this.patrimoineService.deletePatrimoine(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
