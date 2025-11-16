package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
@Slf4j
public class PaymentScheduleService {

    private final PaymentScheduleRepository paymentScheduleRepository;
    private final InstallmentRepository installmentRepository;
    private final AgentRepository agentRepository;
    private final MainBalanceRepository mainBalanceRepository;
    private final TransactionHistoryRepository transactionHistoryRepository;
    private final MemberRepository memberRepository;

    public Double perMonth(long id) {
        Installment installment = installmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("ইন্সটলমেন্ট খুঁজে পাওয়া যায়নি ID: " + id));
        return installment.getMonthlyInstallmentAmount();
    }

    @Transactional
    public PaymentScheduleResponseDTO savePayment(PaymentScheduleRequestDTO request) {
        // Validate installment and agent exist
        Installment installment = installmentRepository.findById(request.getInstallmentId())
                .orElseThrow(() -> new RuntimeException("ইন্সটলমেন্ট খুঁজে পাওয়া যায়নি ID: " + request.getInstallmentId()));

        Agent agent = agentRepository.findById(request.getAgentId())
                .orElseThrow(() -> new RuntimeException("এজেন্ট খুঁজে পাওয়া যায়নি ID: " + request.getAgentId()));

        // Calculate payment details
        double totalPaid = installment.getPaymentSchedules()
                .stream()
                .mapToDouble(PaymentSchedule::getPaidAmount)
                .sum();

        double previousRemaining = Math.max(installment.getNeedPaidAmount() - totalPaid, 0.0);
        double newRemaining = Math.max(previousRemaining - request.getAmount(), 0.0);

        // Update Main Balance
        MainBalance currentBalance = getMainBalance();
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        newBalance.setTotalBalance(currentBalance.getTotalBalance() + request.getAmount());
        newBalance.setTotalInstallmentReturn(currentBalance.getTotalInstallmentReturn() + request.getAmount());
        newBalance.setTotalEarnings(currentBalance.getTotalEarnings() + (request.getAmount() * 0.15));
        newBalance.setWhoChanged("system");
        
        String memberName = memberRepository.findById(installment.getMember().getId())
                .map(Member::getName)
                .orElse("অজানা সদস্য");
        newBalance.setReason("ইন্সটলমেন্ট পেমেন্ট গ্রহণ করা হয়েছে: " + memberName + " | Amount: " + request.getAmount() + " টাকা");
        
        mainBalanceRepository.save(newBalance);

        // Create payment schedule
        PaymentSchedule schedule = PaymentSchedule.builder()
                .installment(installment)
                .collectingAgent(agent)
                .paidAmount(request.getAmount())
                .totalAmount(installment.getNeedPaidAmount())
                .remainingAmount(newRemaining)
                .notes(request.getNotes() != null ? request.getNotes() : "")
                .paymentDate(LocalDate.now())
                .createdTime(LocalDateTime.now())
                .updatedTime(LocalDateTime.now())
                .build();

        // Set status based on remaining amount
        if (newRemaining <= 0.01) {
            schedule.setStatus(PaymentStatus.COMPLETED);
            installment.setStatus(InstallmentStatus.COMPLETED);
            installmentRepository.save(installment);
            log.info("ইন্সটলমেন্ট {} কমপ্লিট হিসেবে মার্ক করা হয়েছে", installment.getId());
        } else {
            schedule.setStatus(PaymentStatus.PAID);
            if (installment.getStatus() == InstallmentStatus.PENDING) {
                installment.setStatus(InstallmentStatus.ACTIVE);
                installmentRepository.save(installment);
                log.info("ইন্সটলমেন্ট {} একটিভ হিসেবে মার্ক করা হয়েছে", installment.getId());
            }
        }

        PaymentSchedule savedSchedule = paymentScheduleRepository.save(schedule);

        // Create transaction history
        createTransactionHistory(
            "INSTALLMENT_PAYMENT",
            request.getAmount(),
            "ইন্সটলমেন্ট পেমেন্ট গ্রহণ: " + memberName + " | পরিশোধিত: " + request.getAmount() + " টাকা | বাকি: " + newRemaining + " টাকা",
            null,
            installment.getMember().getId(),
            "system"
        );

        log.info("ইন্সটলমেন্ট পেমেন্ট সফলভাবে সংরক্ষণ করা হয়েছে ID: {}", savedSchedule.getId());
        return mapToResponseDTO(savedSchedule, previousRemaining);
    }

    @Transactional(readOnly = true)
    public List<PaymentScheduleResponseDTO> getPaymentsByInstallmentId(Long installmentId) {
        List<PaymentSchedule> schedules = paymentScheduleRepository
                .findByInstallmentIdOrderByCreatedTimeDesc(installmentId);

        log.info("ইন্সটলমেন্ট ID {} এর জন্য {} টি পেমেন্ট পাওয়া গেছে", installmentId, schedules.size());
        return schedules.stream()
                .map(s -> mapToResponseDTO(s, null))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public InstallmentBalanceDTO getRemainingBalanceByInstallmentId(Long installmentId) {
        Installment installment = installmentRepository.findById(installmentId)
                .orElseThrow(() -> new RuntimeException("ইন্সটলমেন্ট খুঁজে পাওয়া যায়নি ID: " + installmentId));

        // Calculate total paid amount
        Double totalPaid = paymentScheduleRepository.findTotalPaidAmountByInstallmentId(installmentId);
        if (totalPaid == null) totalPaid = 0.0;

        // Get total payments count
        List<PaymentSchedule> payments = paymentScheduleRepository
                .findByInstallmentIdOrderByCreatedTimeDesc(installmentId);
        int totalPayments = payments.size();

        // Calculate remaining balance
        Double remainingBalance = Math.max(installment.getNeedPaidAmount() - totalPaid, 0.0);

        log.info("ইন্সটলমেন্ট ব্যালেন্স চেক করা হয়েছে ID: {} | বাকি: {} টাকা", installmentId, remainingBalance);
        return InstallmentBalanceDTO.builder()
                .installmentId(installmentId)
                .totalAmount(installment.getNeedPaidAmount())
                .totalPaid(totalPaid)
                .remainingBalance(remainingBalance)
                .totalPayments(totalPayments)
                .status(installment.getStatus().toString())
                .monthlyAmount(installment.getMonthlyInstallmentAmount())
                .build();
    }

    @Transactional(readOnly = true)
    public PaymentScheduleResponseDTO getPaymentById(Long id) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("পেমেন্ট শিডিউল খুঁজে পাওয়া যায়নি ID: " + id));

        return mapToResponseDTO(schedule, null);
    }

    @Transactional(readOnly = true)
    public List<PaymentScheduleResponseDTO> getPaymentsByAgentId(Long agentId) {
        agentRepository.findById(agentId)
                .orElseThrow(() -> new RuntimeException("এজেন্ট খুঁজে পাওয়া যায়নি ID: " + agentId));

        List<PaymentSchedule> schedules = paymentScheduleRepository
                .findByCollectingAgentIdOrderByCreatedTimeDesc(agentId);

        log.info("এজেন্ট ID {} এর জন্য {} টি পেমেন্ট পাওয়া গেছে", agentId, schedules.size());
        return schedules.stream()
                .map(s -> mapToResponseDTO(s, null))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PaymentScheduleResponseDTO> getPaymentsByMemberId(Long memberId) {
        List<PaymentSchedule> schedules = paymentScheduleRepository
                .findByInstallmentMemberIdOrderByCreatedTimeDesc(memberId);

        log.info("সদস্য ID {} এর জন্য {} টি পেমেন্ট পাওয়া গেছে", memberId, schedules.size());
        return schedules.stream()
                .map(s -> mapToResponseDTO(s, null))
                .collect(Collectors.toList());
    }

    @Transactional
    public void deletePayment(Long id) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("পেমেন্ট শিডিউল খুঁজে পাওয়া যায়নি ID: " + id));

        Installment installment = schedule.getInstallment();
        double deletedAmount = schedule.getPaidAmount();

        // Update Main Balance for deleted payment
        MainBalance currentBalance = getMainBalance();
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        newBalance.setTotalBalance(currentBalance.getTotalBalance() - deletedAmount);
        newBalance.setTotalInstallmentReturn(currentBalance.getTotalInstallmentReturn() - deletedAmount);
        newBalance.setTotalEarnings(currentBalance.getTotalEarnings() - (deletedAmount * 0.15));
        newBalance.setWhoChanged("system");
        
        String memberName = memberRepository.findById(installment.getMember().getId())
                .map(Member::getName)
                .orElse("অজানা সদস্য");
        newBalance.setReason("ইন্সটলমেন্ট পেমেন্ট ডিলিট করা হয়েছে: " + memberName + " | Amount: " + deletedAmount + " টাকা");
        
        mainBalanceRepository.save(newBalance);

        // Delete the payment
        paymentScheduleRepository.delete(schedule);

        // Recalculate installment status
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

        // Create transaction history for deletion
        createTransactionHistory(
            "PAYMENT_DELETED",
            deletedAmount,
            "ইন্সটলমেন্ট পেমেন্ট ডিলিট: " + memberName + " | Amount: " + deletedAmount + " টাকা | নতুন বাকি: " + remaining + " টাকা",
            null,
            installment.getMember().getId(),
            "system"
        );

        log.info("পেমেন্ট ডিলিট করা হয়েছে: {} টাকা ইন্সটলমেন্ট ID: {} থেকে", deletedAmount, installment.getId());
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

    /** Helper method to create new MainBalance record */
    private MainBalance createNewMainBalanceRecord(MainBalance currentBalance) {
        return MainBalance.builder()
                .totalBalance(currentBalance.getTotalBalance())
                .totalInvestment(currentBalance.getTotalInvestment())
                .totalProductCost(currentBalance.getTotalProductCost())
                .totalMaintenanceCost(currentBalance.getTotalMaintenanceCost())
                .totalInstallmentReturn(currentBalance.getTotalInstallmentReturn())
                .totalEarnings(currentBalance.getTotalEarnings())
                .whoChanged(currentBalance.getWhoChanged())
                .reason("পূর্ববর্তী ব্যালেন্স থেকে নতুন রেকর্ড তৈরি করা হয়েছে")
                .build();
    }

    /** Helper method to create transaction history */
    private void createTransactionHistory(String type, Double amount, String description,
            Long shareholderId, Long memberId, String performedBy) {
        TransactionHistory transaction = TransactionHistory.builder()
                .type(type)
                .amount(amount)
                .description(description)
                .shareholderId(shareholderId)
                .memberId(memberId)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
    }

    /** Helper method to get current main balance */
    private MainBalance getMainBalance() {
        return mainBalanceRepository.findTopByOrderByIdDesc()
                .orElseGet(() -> MainBalance.builder()
                        .totalBalance(0.0)
                        .totalInvestment(0.0)
                        .totalProductCost(0.0)
                        .totalMaintenanceCost(0.0)
                        .totalInstallmentReturn(0.0)
                        .totalEarnings(0.0)
                        .whoChanged("system")
                        .reason("প্রাথমিক ব্যালেন্স")
                        .build());
    }

    private void logTransaction(String type, double amount, String desc, Long memberId) {
        TransactionHistory txn = TransactionHistory.builder()
                .type(type)
                .amount(amount)
                .description(desc)
                .memberId(memberId)
                .timestamp(LocalDateTime.now())
                .build();
        transactionHistoryRepository.save(txn);
    }
}