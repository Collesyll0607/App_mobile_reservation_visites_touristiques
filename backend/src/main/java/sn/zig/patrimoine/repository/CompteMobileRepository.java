package sn.zig.patrimoine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.zig.patrimoine.model.CompteMobile;

import java.util.Optional;

@Repository
public interface CompteMobileRepository extends JpaRepository<CompteMobile, Long> {
    Optional<CompteMobile> findByEmailIgnoreCase(String email);
}
