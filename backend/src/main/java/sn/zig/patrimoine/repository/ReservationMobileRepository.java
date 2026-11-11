package sn.zig.patrimoine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.zig.patrimoine.model.ReservationMobile;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationMobileRepository extends JpaRepository<ReservationMobile, Long> {
    List<ReservationMobile> findAllByOrderByIdDesc();
    Optional<ReservationMobile> findByCodeReservation(String codeReservation);
    List<ReservationMobile> findByStatutOrderByIdDesc(String statut);
}
