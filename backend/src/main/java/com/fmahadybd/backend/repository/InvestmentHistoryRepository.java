package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.InvestmentHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface InvestmentHistoryRepository extends JpaRepository<InvestmentHistory, Long> {
    List<InvestmentHistory> findByShareholderIdOrderByInvestmentDateDesc(Long shareholderId);
}