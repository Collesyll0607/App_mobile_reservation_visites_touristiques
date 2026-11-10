package sn.zig.patrimoine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.zig.patrimoine.model.UtilisateurBdd;

import java.util.Optional;

@Repository
public interface UtilisateurBddRepository extends JpaRepository<UtilisateurBdd, Long> {
    Optional<UtilisateurBdd> findByEmailIgnoreCase(String email);
    Optional<UtilisateurBdd> findByUsernameIgnoreCase(String username);
}
