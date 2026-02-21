package com.fmahadybd.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import com.fmahadybd.backend.entity.PaymentSchedule;
import java.util.List;

@Repository
public interface PaymentScheduleRepository extends JpaRepository<PaymentSchedule, Long> {

    List<PaymentSchedule> findByInstallmentIdOrderByCreatedTimeDesc(Long installmentId);

    List<PaymentSchedule> findByCollectingAgentIdOrderByCreatedTimeDesc(Long agentId);

    List<PaymentSchedule> findByInstallmentIdAndStatusOrderByCreatedTimeDesc(
            Long installmentId,
            com.fmahadybd.backend.entity.PaymentStatus status);

    List<PaymentSchedule> findByInstallmentMemberIdOrderByCreatedTimeDesc(Long memberId);


    @Query("SELECT COALESCE(SUM(ps.paidAmount), 0.0) FROM PaymentSchedule ps WHERE ps.installment.id = :installmentId")
    Double findTotalPaidAmountByInstallmentId(@Param("installmentId") Long installmentId);
}