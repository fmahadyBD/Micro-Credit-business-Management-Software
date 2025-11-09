package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.TransactionHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionHistoryRepository extends JpaRepository<TransactionHistory, Long> {
    
    // Find all transactions ordered by timestamp (newest first)
    List<TransactionHistory> findAllByOrderByTimestampDesc();
    
    // Find transactions by type
    List<TransactionHistory> findByTypeOrderByTimestampDesc(String type);
    
    // Find transactions by shareholder
    List<TransactionHistory> findByShareholderIdOrderByTimestampDesc(Long shareholderId);
    
    // Find transactions by member
    List<TransactionHistory> findByMemberIdOrderByTimestampDesc(Long memberId);
    
    // Find transactions by date range
    List<TransactionHistory> findByTimestampBetweenOrderByTimestampDesc(
        java.time.LocalDateTime start, java.time.LocalDateTime end);
}