package com.fmahadybd.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.fmahadybd.backend.entity.Product;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    @Query("SELECT p FROM Product p LEFT JOIN FETCH p.soldByAgent")
    List<Product> findAllWithAgent();
    
    @Query("SELECT p FROM Product p LEFT JOIN FETCH p.soldByAgent WHERE p.id = :id")
    Optional<Product> findByIdWithAgent(Long id);
}