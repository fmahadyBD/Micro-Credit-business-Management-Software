package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.ShareTransaction;
import com.fmahadybd.backend.entity.TransactionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShareTransactionRepository extends JpaRepository<ShareTransaction, Long> {
    
    List<ShareTransaction> findByShareholderIdOrderByTransactionDateDesc(Long shareholderId);
    
    List<ShareTransaction> findTop5ByShareholderIdOrderByTransactionDateDesc(Long shareholderId);
    
    List<ShareTransaction> findByStatusOrderByTransactionDateDesc(TransactionStatus status);
}