package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.entity.*;
import com.fmahadybd.backend.repository.InstallmentRepository;
import com.fmahadybd.backend.repository.PaymentScheduleRepository;
import com.fmahadybd.backend.repository.PaymentTransactionRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class PaymentScheduleService {

    private final PaymentScheduleRepository paymentScheduleRepository;
    private final PaymentTransactionRepository paymentTransactionRepository;
    private final InstallmentRepository installmentRepository;

    /** Create payment schedules when an installment is created */
    public void createPaymentSchedules(Installment installment, Agent defaultAgent) {
        Double monthlyAmount = installment.getMonthlyInstallmentAmount();
        LocalDate startDate = LocalDate.now().plusMonths(1);

        for (int i = 0; i < installment.getInstallmentMonths(); i++) {
            PaymentSchedule schedule = PaymentSchedule.builder()
                    .installment(installment)
                    .dueDate(startDate.plusMonths(i))
                    .monthlyAmount(monthlyAmount)
                    .paidAmount(0.0)
                    .remainingAmount(monthlyAmount)
                    .status(PaymentStatus.PENDING)
                    .collectingAgent(defaultAgent)
                    .build();

            paymentScheduleRepository.save(schedule);
        }

        updateInstallmentRemainingAmount(installment.getId());
    }

    /** Add payment to a schedule */
    public PaymentSchedule addPayment(Long scheduleId, Double amount, Agent agent, String notes) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Payment schedule not found with id: " + scheduleId));

        PaymentTransaction transaction = schedule.addPayment(amount, agent, notes);
        paymentTransactionRepository.save(transaction);

        PaymentSchedule updatedSchedule = paymentScheduleRepository.save(schedule);
        updateInstallmentRemainingAmount(schedule.getInstallment().getId());

        return updatedSchedule;
    }

    /** Edit existing payment */
    public PaymentSchedule editPayment(Long scheduleId, Long transactionId, Double newAmount, Agent agent, String notes) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Payment schedule not found with id: " + scheduleId));

        PaymentTransaction transaction = schedule.editPayment(transactionId, newAmount, agent, notes);
        paymentTransactionRepository.save(transaction);

        PaymentSchedule updatedSchedule = paymentScheduleRepository.save(schedule);
        updateInstallmentRemainingAmount(schedule.getInstallment().getId());

        return updatedSchedule;
    }

    /** Handle partial payment with installment extension */
    public PaymentSchedule handlePartialPayment(Long scheduleId, Double paidAmount, Agent agent, String notes) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Payment schedule not found with id: " + scheduleId));

        Installment installment = schedule.getInstallment();

        if (paidAmount < schedule.getMonthlyAmount()) {
            Double remaining = schedule.getMonthlyAmount() - paidAmount;

            // Add current partial payment
            PaymentTransaction transaction = schedule.addPayment(paidAmount, agent, notes);
            paymentTransactionRepository.save(transaction);
            paymentScheduleRepository.save(schedule);

            // Apply remaining to next month
            addRemainingToNextMonth(installment.getId(), scheduleId, remaining, agent);
        } else {
            // Full payment
            PaymentTransaction transaction = schedule.addPayment(paidAmount, agent, notes);
            paymentTransactionRepository.save(transaction);
            paymentScheduleRepository.save(schedule);
        }

        updateInstallmentRemainingAmount(installment.getId());
        return schedule;
    }

    /** Update payment schedule details */
    public PaymentSchedule updatePaymentSchedule(Long scheduleId, PaymentSchedule scheduleDetails) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Payment schedule not found with id: " + scheduleId));

        if (scheduleDetails.getMonthlyAmount() != null) {
            schedule.setMonthlyAmount(scheduleDetails.getMonthlyAmount());
        }
        if (scheduleDetails.getDueDate() != null) {
            schedule.setDueDate(scheduleDetails.getDueDate());
        }
        if (scheduleDetails.getCollectingAgent() != null) {
            schedule.setCollectingAgent(scheduleDetails.getCollectingAgent());
        }
        if (scheduleDetails.getNotes() != null) {
            schedule.setNotes(scheduleDetails.getNotes());
        }

        schedule.calculateRemainingAmount();
        schedule.updatePaymentStatus();
        PaymentSchedule updatedSchedule = paymentScheduleRepository.save(schedule);

        updateInstallmentRemainingAmount(schedule.getInstallment().getId());
        return updatedSchedule;
    }

    /** Advance payment - pay future installments early */
    public PaymentSchedule advancePayment(Long scheduleId, Double amount, Agent agent, String notes) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Payment schedule not found with id: " + scheduleId));

        Installment installment = schedule.getInstallment();

        if (amount > schedule.getRemainingAmount()) {
            Double overpayment = amount - schedule.getRemainingAmount();

            // Pay current schedule fully
            PaymentTransaction transaction = schedule.addPayment(schedule.getRemainingAmount(), agent, notes);
            paymentTransactionRepository.save(transaction);
            paymentScheduleRepository.save(schedule);

            // Apply overpayment to next schedules
            applyOverpaymentToNextSchedules(installment.getId(), scheduleId, overpayment, agent, notes);
        } else {
            PaymentTransaction transaction = schedule.addPayment(amount, agent, notes);
            paymentTransactionRepository.save(transaction);
            paymentScheduleRepository.save(schedule);
        }

        updateInstallmentRemainingAmount(installment.getId());
        return schedule;
    }

    /** Add remaining amount to next month */
    private void addRemainingToNextMonth(Long installmentId, Long currentScheduleId, Double remainingAmount, Agent agent) {
        List<PaymentSchedule> schedules = paymentScheduleRepository.findByInstallmentIdOrderByDueDate(installmentId);

        int currentIndex = -1;
        for (int i = 0; i < schedules.size(); i++) {
            if (schedules.get(i).getId().equals(currentScheduleId)) {
                currentIndex = i;
                break;
            }
        }

        if (currentIndex != -1 && currentIndex < schedules.size() - 1) {
            PaymentSchedule nextSchedule = schedules.get(currentIndex + 1);
            nextSchedule.setMonthlyAmount(nextSchedule.getMonthlyAmount() + remainingAmount);
            nextSchedule.setRemainingAmount(nextSchedule.getRemainingAmount() + remainingAmount);
            nextSchedule.setCollectingAgent(agent);
            paymentScheduleRepository.save(nextSchedule);
        } else {
            // Create new month at the end
            Installment installment = installmentRepository.findById(installmentId)
                    .orElseThrow(() -> new RuntimeException("Installment not found"));

            PaymentSchedule newSchedule = PaymentSchedule.builder()
                    .installment(installment)
                    .dueDate(LocalDate.now().plusMonths(schedules.size() + 1))
                    .monthlyAmount(remainingAmount)
                    .paidAmount(0.0)
                    .remainingAmount(remainingAmount)
                    .status(PaymentStatus.PENDING)
                    .collectingAgent(agent)
                    .build();

            paymentScheduleRepository.save(newSchedule);

            installment.setInstallmentMonths(installment.getInstallmentMonths() + 1);
            installmentRepository.save(installment);
        }
    }

    /** Apply overpayment to next schedules */
    private void applyOverpaymentToNextSchedules(Long installmentId, Long currentScheduleId, Double overpayment, Agent agent, String notes) {
        List<PaymentSchedule> schedules = paymentScheduleRepository.findByInstallmentIdOrderByDueDate(installmentId);

        int currentIndex = -1;
        for (int i = 0; i < schedules.size(); i++) {
            if (schedules.get(i).getId().equals(currentScheduleId)) {
                currentIndex = i;
                break;
            }
        }

        if (currentIndex != -1) {
            for (int i = currentIndex + 1; i < schedules.size() && overpayment > 0; i++) {
                PaymentSchedule nextSchedule = schedules.get(i);
                Double paymentAmount = Math.min(overpayment, nextSchedule.getRemainingAmount());

                if (paymentAmount > 0) {
                    PaymentTransaction transaction = nextSchedule.addPayment(paymentAmount, agent,
                            notes + " (Advance from schedule " + currentScheduleId + ")");
                    paymentTransactionRepository.save(transaction);
                    paymentScheduleRepository.save(nextSchedule);

                    overpayment -= paymentAmount;
                }
            }
        }
    }

    /** Recalculate installment remaining amount from all schedules */
    private void updateInstallmentRemainingAmount(Long installmentId) {
        Installment installment = installmentRepository.findById(installmentId)
                .orElseThrow(() -> new RuntimeException("Installment not found"));

        double totalRemaining = installment.getPaymentSchedules().stream()
                .mapToDouble(PaymentSchedule::getRemainingAmount)
                .sum();

        installment.setTotalRemainingAmount(totalRemaining);
        installmentRepository.save(installment);
    }

    /** Get schedules for an installment */
    public List<PaymentSchedule> getPaymentSchedulesByInstallment(Long installmentId) {
        return paymentScheduleRepository.findByInstallmentIdOrderByDueDate(installmentId);
    }

    /** Get transactions for a schedule */
    public List<PaymentTransaction> getPaymentTransactionsBySchedule(Long scheduleId) {
        PaymentSchedule schedule = paymentScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Payment schedule not found"));
        return schedule.getPaymentTransactions();
    }

    public Optional<PaymentSchedule> findById(Long id) {
        return paymentScheduleRepository.findById(id);
    }

    public List<PaymentSchedule> getOverdueSchedules() {
        return paymentScheduleRepository.findOverdueSchedules(LocalDate.now());
    }
}
