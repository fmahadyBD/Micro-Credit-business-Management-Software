package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.TransactionHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TransactionHistoryRepository extends JpaRepository<TransactionHistory, Long> {

    // Keep only these ordered methods (remove the duplicates without ordering)
    List<TransactionHistory> findAllByOrderByTimestampDesc();

    List<TransactionHistory> findByTypeOrderByTimestampDesc(String type);

    List<TransactionHistory> findByShareholderIdOrderByTimestampDesc(Long shareholderId);

    List<TransactionHistory> findByMemberIdOrderByTimestampDesc(Long memberId);

    List<TransactionHistory> findByTimestampBetweenOrderByTimestampDesc(
            LocalDateTime start, LocalDateTime end);
}