package com.fmahadybd.backend.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.fmahadybd.backend.entity.Agent;

import java.util.List;
import java.util.Optional;

@Repository
public interface AgentRepository extends JpaRepository<Agent, Long> {
    
    Optional<Agent> findByPhone(String phone);
    Optional<Agent> findByEmail(String email);
    Optional<Agent> findByNidCard(String nidCard);
    List<Agent> findByStatus(String status);
    List<Agent> findByZila(String zila);
    boolean existsByPhone(String phone);
    boolean existsByEmail(String email);
    boolean existsByNidCard(String nidCard);
}