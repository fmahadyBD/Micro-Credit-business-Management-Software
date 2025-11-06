package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.TransactionHistory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TransactionHistoryRepository extends JpaRepository<TransactionHistory, Long> {
}
