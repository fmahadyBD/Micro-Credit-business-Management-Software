package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.PaymentTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, Long> {
    List<PaymentTransaction> findByPaymentScheduleIdOrderByPaymentDate(Long paymentScheduleId);
    List<PaymentTransaction> findByCollectingAgentId(Long agentId);
}