package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.dto.InstallmentBalanceDTO;
import com.fmahadybd.backend.dto.PaymentScheduleRequestDTO;
import com.fmahadybd.backend.dto.PaymentScheduleResponseDTO;
import com.fmahadybd.backend.entity.*;
import com.fmahadybd.backend.repository.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PaymentScheduleService {

        private final PaymentScheduleRepository paymentScheduleRepository;
        private final InstallmentRepository installmentRepository;
        private final AgentRepository agentRepository;
        private final MainBalanceRepository mainBalanceRepository;

        public Double perMonth(long id) {
                Installment installment = installmentRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));
                return installment.getMonthlyInstallmentAmount();
        }

        @Transactional
        public PaymentScheduleResponseDTO savePayment(PaymentScheduleRequestDTO request) {
                // Validate installment and agent exist
                Installment installment = installmentRepository.findById(request.getInstallmentId())
                                .orElseThrow(() -> new RuntimeException("Installment not found with id: "
                                                + request.getInstallmentId()));

                Agent agent = agentRepository.findById(request.getAgentId())
                                .orElseThrow(() -> new RuntimeException("Agent not found with id: "
                                                + request.getAgentId()));

                // Calculate payment details
                double totalPaid = installment.getPaymentSchedules()
                                .stream()
                                .mapToDouble(PaymentSchedule::getPaidAmount)
                                .sum();

                double previousRemaining = Math.max(installment.getNeedPaidAmount() - totalPaid, 0.0);



                // Create payment schedule
                PaymentSchedule schedule = PaymentSchedule.builder()
                                .installment(installment)
                                .collectingAgent(agent)
                                .paidAmount(request.getAmount())
                                .totalAmount(installment.getNeedPaidAmount())
                                .remainingAmount(previousRemaining - request.getAmount())
                                .notes(request.getNotes() != null ? request.getNotes() : "")
                                .paymentDate(LocalDate.now())
                                .createdTime(LocalDateTime.now())
                                .updatedTime(LocalDateTime.now())
                                .build();

                // Set status
                if (schedule.getRemainingAmount() <= 0.01) {
                        schedule.setStatus(PaymentStatus.COMPLETED);
                        installment.setStatus(InstallmentStatus.COMPLETED);
                        installmentRepository.save(installment);
                } else {
                        schedule.setStatus(PaymentStatus.PAID);
                        if (installment.getStatus() == InstallmentStatus.PENDING) {
                                installment.setStatus(InstallmentStatus.ACTIVE);
                                installmentRepository.save(installment);
                        }
                }

                PaymentSchedule savedSchedule = paymentScheduleRepository.save(schedule);

                MainBalance mb = getMainBalance();

                mb.setTotalBalance(mb.getTotalBalance() + request.getAmount());
                mainBalanceRepository.save(mb);

                return mapToResponseDTO(savedSchedule, previousRemaining);
        }

        @Transactional(readOnly = true)
        public List<PaymentScheduleResponseDTO> getPaymentsByInstallmentId(Long installmentId) {
                List<PaymentSchedule> schedules = paymentScheduleRepository
                                .findByInstallmentIdOrderByCreatedTimeDesc(installmentId);

                return schedules.stream()
                                .map(s -> mapToResponseDTO(s, null))
                                .collect(Collectors.toList());
        }

        @Transactional(readOnly = true)
        public InstallmentBalanceDTO getRemainingBalanceByInstallmentId(Long installmentId) {
                Installment installment = installmentRepository.findById(installmentId)
                                .orElseThrow(() -> new RuntimeException(
                                                "Installment not found with id: " + installmentId));

                // Calculate total paid amount
                Double totalPaid = paymentScheduleRepository.findTotalPaidAmountByInstallmentId(installmentId);

                // Get total payments count
                List<PaymentSchedule> payments = paymentScheduleRepository
                                .findByInstallmentIdOrderByCreatedTimeDesc(installmentId);
                int totalPayments = payments.size();

                // Calculate remaining balance
                Double remainingBalance = Math.max(installment.getNeedPaidAmount() - totalPaid, 0.0);

                return InstallmentBalanceDTO.builder()
                                .installmentId(installmentId)
                                .totalAmount(installment.getNeedPaidAmount())
                                .totalPaid(totalPaid)
                                .remainingBalance(remainingBalance)
                                .totalPayments(totalPayments)
                                .status(installment.getStatus().toString())
                                .build();
        }

        @Transactional(readOnly = true)
        public PaymentScheduleResponseDTO getPaymentById(Long id) {
                PaymentSchedule schedule = paymentScheduleRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Payment schedule not found with id: " + id));

                return mapToResponseDTO(schedule, null);
        }

        @Transactional(readOnly = true)
        public List<PaymentScheduleResponseDTO> getPaymentsByAgentId(Long agentId) {
                // Verify agent exists
                agentRepository.findById(agentId)
                                .orElseThrow(() -> new RuntimeException("Agent not found with id: " + agentId));

                List<PaymentSchedule> schedules = paymentScheduleRepository
                                .findByCollectingAgentIdOrderByCreatedTimeDesc(agentId);

                return schedules.stream()
                                .map(s -> mapToResponseDTO(s, null))
                                .collect(Collectors.toList());
        }

        @Transactional(readOnly = true)
        public List<PaymentScheduleResponseDTO> getPaymentsByMemberId(Long memberId) {
                List<PaymentSchedule> schedules = paymentScheduleRepository
                                .findByInstallmentMemberIdOrderByCreatedTimeDesc(memberId);

                return schedules.stream()
                                .map(s -> mapToResponseDTO(s, null))
                                .collect(Collectors.toList());
        }

        @Transactional
        public void deletePayment(Long id) {
                PaymentSchedule schedule = paymentScheduleRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Payment schedule not found with id: " + id));

                // Recalculate installment status if deleting a payment
                Installment installment = schedule.getInstallment();
                paymentScheduleRepository.delete(schedule);

                // Recalculate remaining amount and status
                double totalPaid = installment.getPaymentSchedules()
                                .stream()
                                .filter(ps -> !ps.getId().equals(id))
                                .mapToDouble(PaymentSchedule::getPaidAmount)
                                .sum();

                double remaining = installment.getNeedPaidAmount() - totalPaid;

                if (remaining > 0.01) {
                        if (totalPaid > 0) {
                                installment.setStatus(InstallmentStatus.ACTIVE);
                        } else {
                                installment.setStatus(InstallmentStatus.PENDING);
                        }
                        installmentRepository.save(installment);
                }
        }

        private PaymentScheduleResponseDTO mapToResponseDTO(PaymentSchedule schedule,
                        Double previousRemaining) {
                Installment installment = schedule.getInstallment();
                Member member = installment.getMember();
                Agent agent = schedule.getCollectingAgent();

                int totalPayments = installment.getPaymentSchedules().size();

                return PaymentScheduleResponseDTO.builder()
                                .id(schedule.getId())
                                .installmentId(installment.getId())
                                .memberName(member.getName())
                                .memberPhone(member.getPhone())
                                .paidAmount(schedule.getPaidAmount())
                                .totalAmount(schedule.getTotalAmount())
                                .remainingAmount(schedule.getRemainingAmount())
                                .status(schedule.getStatus())
                                .agentName(agent.getName())
                                .agentId(agent.getId())
                                .paymentDate(schedule.getPaymentDate())
                                .notes(schedule.getNotes())
                                .createdTime(schedule.getCreatedTime())
                                .updatedTime(schedule.getUpdatedTime())
                                .previousRemainingAmount(previousRemaining)
                                .isFullyPaid(schedule.getRemainingAmount() <= 0.01)
                                .totalPaymentsMade(totalPayments)
                                .build();
        }

        private MainBalance getMainBalance() {
                return mainBalanceRepository.findAll().stream().findFirst()
                                .orElseGet(() -> mainBalanceRepository.save(
                                                MainBalance.builder()
                                                                .totalBalance(0.0)
                                                                .totalInvestment(0.0)
                                                                .totalWithdrawal(0.0)
                                                                .totalProductCost(0.0)
                                                                .totalMaintenanceCost(0.0)
                                                                .totalInstallmentReturn(0.0)
                                                                .build()));
        }

}