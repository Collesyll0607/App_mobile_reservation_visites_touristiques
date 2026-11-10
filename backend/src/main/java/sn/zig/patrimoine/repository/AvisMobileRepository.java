package sn.zig.patrimoine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.zig.patrimoine.model.AvisMobile;

import java.util.List;

@Repository
public interface AvisMobileRepository extends JpaRepository<AvisMobile, Long> {
    List<AvisMobile> findByPatrimoineIdOrderByIdDesc(Long patrimoineId);
}
