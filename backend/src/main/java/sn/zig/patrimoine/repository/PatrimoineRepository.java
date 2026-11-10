package sn.zig.patrimoine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.zig.patrimoine.model.Patrimoine;

import java.util.Optional;

/**
 * Interface Repository JPA pour ms-patrimoine (Slide 16 du TP1).
 */
@Repository
public interface PatrimoineRepository extends JpaRepository<Patrimoine, Long> {

    Optional<Patrimoine> findByCodePatrimoine(String codePatrimoine);
}
