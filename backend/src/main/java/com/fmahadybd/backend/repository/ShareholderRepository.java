package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.Shareholder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShareholderRepository extends JpaRepository<Shareholder, Long> {
    
    List<Shareholder> findByStatus(String status);
    
    long countByStatus(String status);
}