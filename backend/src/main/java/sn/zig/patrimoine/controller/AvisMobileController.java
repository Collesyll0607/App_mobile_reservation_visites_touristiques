package sn.zig.patrimoine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import sn.zig.patrimoine.model.AvisMobile;
import sn.zig.patrimoine.repository.AvisMobileRepository;

import java.util.List;

@RestController
@RequestMapping("/api/avis")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AvisMobileController {

    private final AvisMobileRepository avisRepository;

    @GetMapping
    public List<AvisMobile> getAllAvis() {
        return avisRepository.findAll();
    }

    @GetMapping("/site/{patrimoineId}")
    public List<AvisMobile> getAvisBySite(@PathVariable("patrimoineId") Long patrimoineId) {
        return avisRepository.findByPatrimoineIdOrderByIdDesc(patrimoineId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AvisMobile addAvis(@RequestBody AvisMobile avis) {
        return avisRepository.save(avis);
    }
}
