package com.fmahadybd.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.fmahadybd.backend.entity.Installment;

@Repository
public interface InstallmentRepository extends JpaRepository<Installment, Long> {
}