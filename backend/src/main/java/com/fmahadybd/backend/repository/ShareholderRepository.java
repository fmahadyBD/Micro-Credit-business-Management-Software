package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.Shareholder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShareholderRepository extends JpaRepository<Shareholder, Long> {
    
    List<Shareholder> findByStatus(String status);
    
    Long countByStatus(String status);
    
    // Add this method
    Optional<Shareholder> findByUserId(Long userId);
    
    // Add this method
    Optional<Shareholder> findByEmail(String email);
}
