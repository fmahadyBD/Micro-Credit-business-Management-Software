package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.DeletedAgent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeletedAgentRepository extends JpaRepository<DeletedAgent, Long> {
}
