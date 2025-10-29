package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fmahadybd.backend.entity.Agent;
import com.fmahadybd.backend.entity.PaymentSchedule;
import com.fmahadybd.backend.entity.PaymentTransaction;
import com.fmahadybd.backend.service.PaymentScheduleService;

import java.util.List;

@RestController
@RequestMapping("/api/payment-schedules")
@RequiredArgsConstructor
public class PaymentScheduleController {

    private final PaymentScheduleService paymentScheduleService;

    @PostMapping("/{scheduleId}/pay")
    public ResponseEntity<PaymentSchedule> addPayment(
            @PathVariable Long scheduleId,
            @RequestParam Double amount,
            @RequestParam Long agentId,
            @RequestParam(required = false) String notes) {
        
        Agent agent = new Agent();
        agent.setId(agentId);
        
        PaymentSchedule updatedSchedule = paymentScheduleService.addPayment(scheduleId, amount, agent, notes);
        return ResponseEntity.ok(updatedSchedule);
    }

    @PostMapping("/{scheduleId}/partial-pay")
    public ResponseEntity<PaymentSchedule> handlePartialPayment(
            @PathVariable Long scheduleId,
            @RequestParam Double amount,
            @RequestParam Long agentId,
            @RequestParam(required = false) String notes) {
        
        Agent agent = new Agent();
        agent.setId(agentId);
        
        PaymentSchedule updatedSchedule = paymentScheduleService.handlePartialPayment(scheduleId, amount, agent, notes);
        return ResponseEntity.ok(updatedSchedule);
    }

    @PostMapping("/{scheduleId}/advance-pay")
    public ResponseEntity<PaymentSchedule> advancePayment(
            @PathVariable Long scheduleId,
            @RequestParam Double amount,
            @RequestParam Long agentId,
            @RequestParam(required = false) String notes) {
        
        Agent agent = new Agent();
        agent.setId(agentId);
        
        PaymentSchedule updatedSchedule = paymentScheduleService.advancePayment(scheduleId, amount, agent, notes);
        return ResponseEntity.ok(updatedSchedule);
    }

    @PutMapping("/{scheduleId}/edit-payment")
    public ResponseEntity<PaymentSchedule> editPayment(
            @PathVariable Long scheduleId,
            @RequestParam Long transactionId,
            @RequestParam Double newAmount,
            @RequestParam Long agentId,
            @RequestParam(required = false) String notes) {
        
        Agent agent = new Agent();
        agent.setId(agentId);
        
        PaymentSchedule updatedSchedule = paymentScheduleService.editPayment(scheduleId, transactionId, newAmount, agent, notes);
        return ResponseEntity.ok(updatedSchedule);
    }

    @PutMapping("/{scheduleId}")
    public ResponseEntity<PaymentSchedule> updatePaymentSchedule(
            @PathVariable Long scheduleId,
            @RequestBody PaymentSchedule scheduleDetails) {
        
        PaymentSchedule updatedSchedule = paymentScheduleService.updatePaymentSchedule(scheduleId, scheduleDetails);
        return ResponseEntity.ok(updatedSchedule);
    }

    @GetMapping("/installment/{installmentId}")
    public ResponseEntity<List<PaymentSchedule>> getPaymentSchedules(
            @PathVariable Long installmentId) {
        
        List<PaymentSchedule> schedules = paymentScheduleService.getPaymentSchedulesByInstallment(installmentId);
        return ResponseEntity.ok(schedules);
    }

    @GetMapping("/{scheduleId}/transactions")
    public ResponseEntity<List<PaymentTransaction>> getPaymentTransactions(
            @PathVariable Long scheduleId) {
        
        List<PaymentTransaction> transactions = paymentScheduleService.getPaymentTransactionsBySchedule(scheduleId);
        return ResponseEntity.ok(transactions);
    }

    @GetMapping("/overdue")
    public ResponseEntity<List<PaymentSchedule>> getOverdueSchedules() {
        List<PaymentSchedule> overdueSchedules = paymentScheduleService.getOverdueSchedules();
        return ResponseEntity.ok(overdueSchedules);
    }
}