package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.PaymentSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface PaymentScheduleRepository extends JpaRepository<PaymentSchedule, Long> {
    List<PaymentSchedule> findByInstallmentIdOrderByDueDate(Long installmentId);
    List<PaymentSchedule> findByInstallmentIdAndStatus(Long installmentId, String status);
    
    @Query("SELECT ps FROM PaymentSchedule ps WHERE ps.dueDate < :currentDate AND ps.status IN ('PENDING', 'PARTIALLY_PAID')")
    List<PaymentSchedule> findOverdueSchedules(@Param("currentDate") LocalDate currentDate);
    
    List<PaymentSchedule> findByCollectingAgentId(Long agentId);
}