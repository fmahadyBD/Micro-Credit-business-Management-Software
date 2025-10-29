package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.WithdrawalRequest;
import com.fmahadybd.backend.entity.WithdrawalStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WithdrawalRepository extends JpaRepository<WithdrawalRequest, Long> {
    
    List<WithdrawalRequest> findByShareholderIdOrderByRequestDateDesc(Long shareholderId);
    
    List<WithdrawalRequest> findTop5ByShareholderIdOrderByRequestDateDesc(Long shareholderId);
    
    List<WithdrawalRequest> findByStatusOrderByRequestDateDesc(WithdrawalStatus status);
    
    List<WithdrawalRequest> findByShareholderIdAndStatus(Long shareholderId, WithdrawalStatus status);
}