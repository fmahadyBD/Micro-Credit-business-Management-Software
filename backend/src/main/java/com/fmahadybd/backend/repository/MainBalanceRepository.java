package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.MainBalance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface MainBalanceRepository extends JpaRepository<MainBalance, Long> {
    
    // Add this method to get the latest balance record
    Optional<MainBalance> findTopByOrderByIdDesc();
}