package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import com.fmahadybd.backend.dto.PaymentScheduleRequestDTO;
import com.fmahadybd.backend.dto.PaymentScheduleResponseDTO;
import com.fmahadybd.backend.service.PaymentScheduleService;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/payment-schedules")
@RequiredArgsConstructor
public class PaymentScheduleController {

    private final PaymentScheduleService paymentScheduleService;

    @PostMapping("/pay")
    public ResponseEntity<?> payInstallment(
            @Valid @RequestBody PaymentScheduleRequestDTO request,
            BindingResult bindingResult) {

        // Manual validation error handling
        if (bindingResult.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            bindingResult.getFieldErrors().forEach(error -> errors.put(error.getField(), error.getDefaultMessage()));
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("errors", errors, "message", "Validation failed"));
        }

        try {
            PaymentScheduleResponseDTO response = paymentScheduleService.savePayment(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "Invalid payment", "message", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Resource not found", "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Internal server error", "message", e.getMessage()));
        }
    }

    @GetMapping("/installment/{installmentId}/monthly-amount")
    public ResponseEntity<?> getMonthlyInstallmentAmount(@PathVariable Long installmentId) {
        try {
            Double monthlyAmount = paymentScheduleService.perMonth(installmentId);
            return ResponseEntity.ok(Map.of(
                    "installmentId", installmentId,
                    "monthlyAmount", monthlyAmount));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Installment not found", "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Internal server error", "message", e.getMessage()));
        }
    }

    @GetMapping("/installment/{installmentId}")
    public ResponseEntity<?> getPaymentsByInstallment(@PathVariable Long installmentId) {
        try {
            List<PaymentScheduleResponseDTO> payments = paymentScheduleService
                    .getPaymentsByInstallmentId(installmentId);
            return ResponseEntity.ok(payments);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Installment not found", "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Internal server error", "message", e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getPaymentById(@PathVariable Long id) {
        try {
            PaymentScheduleResponseDTO payment = paymentScheduleService.getPaymentById(id);
            return ResponseEntity.ok(payment);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Payment not found", "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Internal server error", "message", e.getMessage()));
        }
    }

    @GetMapping("/agent/{agentId}")
    public ResponseEntity<?> getPaymentsByAgent(@PathVariable Long agentId) {
        try {
            List<PaymentScheduleResponseDTO> payments = paymentScheduleService
                    .getPaymentsByAgentId(agentId);
            return ResponseEntity.ok(payments);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Agent not found", "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Internal server error", "message", e.getMessage()));
        }
    }

    @GetMapping("/member/{memberId}")
    public ResponseEntity<?> getPaymentsByMember(@PathVariable Long memberId) {
        try {
            List<PaymentScheduleResponseDTO> payments = paymentScheduleService
                    .getPaymentsByMemberId(memberId);
            return ResponseEntity.ok(payments);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Member not found", "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Internal server error", "message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePayment(@PathVariable Long id) {
        try {
            paymentScheduleService.deletePayment(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Payment not found", "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Internal server error", "message", e.getMessage()));
        }
    }
}