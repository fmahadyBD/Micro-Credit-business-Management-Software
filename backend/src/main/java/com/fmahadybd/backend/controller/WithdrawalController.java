package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.WithdrawalRequest;
import com.fmahadybd.backend.service.WithdrawalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/withdrawals")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class WithdrawalController {

    private final WithdrawalService withdrawalService;

    @PostMapping("/request")
    public ResponseEntity<?> requestWithdrawal(
            @RequestParam Long shareholderId,
            @RequestParam Double amount,
            @RequestParam(required = false) String reason) {
        try {
            WithdrawalRequest request = withdrawalService.requestWithdrawal(shareholderId, amount, reason);
            return ResponseEntity.status(HttpStatus.CREATED).body(request);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to create withdrawal request: " + e.getMessage()));
        }
    }

    @GetMapping("/shareholder/{shareholderId}")
    public ResponseEntity<?> getWithdrawalRequests(@PathVariable Long shareholderId) {
        try {
            List<WithdrawalRequest> requests = withdrawalService.getWithdrawalRequests(shareholderId);
            return ResponseEntity.ok(requests);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch withdrawal requests: " + e.getMessage()));
        }
    }

    @GetMapping("/shareholder/{shareholderId}/recent")
    public ResponseEntity<?> getRecentWithdrawals(@PathVariable Long shareholderId) {
        try {
            List<WithdrawalRequest> requests = withdrawalService.getRecentWithdrawals(shareholderId);
            return ResponseEntity.ok(requests);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch recent withdrawals: " + e.getMessage()));
        }
    }

    @GetMapping("/pending")
    public ResponseEntity<?> getPendingWithdrawals() {
        try {
            List<WithdrawalRequest> requests = withdrawalService.getPendingWithdrawals();
            return ResponseEntity.ok(requests);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch pending withdrawals: " + e.getMessage()));
        }
    }

    @GetMapping("/approved")
    public ResponseEntity<?> getApprovedWithdrawals() {
        try {
            List<WithdrawalRequest> requests = withdrawalService.getApprovedWithdrawals();
            return ResponseEntity.ok(requests);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch approved withdrawals: " + e.getMessage()));
        }
    }

    @GetMapping("/{requestId}")
    public ResponseEntity<?> getWithdrawalById(@PathVariable Long requestId) {
        try {
            WithdrawalRequest request = withdrawalService.getWithdrawalById(requestId);
            return ResponseEntity.ok(request);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch withdrawal: " + e.getMessage()));
        }
    }

    @PostMapping("/{requestId}/approve")
    public ResponseEntity<?> approveWithdrawal(
            @PathVariable Long requestId,
            @RequestParam String processedBy) {
        try {
            WithdrawalRequest request = withdrawalService.approveWithdrawal(requestId, processedBy);
            return ResponseEntity.ok(request);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to approve withdrawal: " + e.getMessage()));
        }
    }

    @PostMapping("/{requestId}/reject")
    public ResponseEntity<?> rejectWithdrawal(
            @PathVariable Long requestId,
            @RequestParam String processedBy,
            @RequestParam String reason) {
        try {
            WithdrawalRequest request = withdrawalService.rejectWithdrawal(requestId, processedBy, reason);
            return ResponseEntity.ok(request);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to reject withdrawal: " + e.getMessage()));
        }
    }

    @PostMapping("/{requestId}/process")
    public ResponseEntity<?> markAsProcessed(
            @PathVariable Long requestId,
            @RequestParam String processedBy) {
        try {
            WithdrawalRequest request = withdrawalService.markAsProcessed(requestId, processedBy);
            return ResponseEntity.ok(request);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to process withdrawal: " + e.getMessage()));
        }
    }

    @PostMapping("/{requestId}/cancel")
    public ResponseEntity<?> cancelWithdrawal(
            @PathVariable Long requestId,
            @RequestParam(required = false) String reason) {
        try {
            WithdrawalRequest request = withdrawalService.cancelWithdrawal(requestId, reason);
            return ResponseEntity.ok(request);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to cancel withdrawal: " + e.getMessage()));
        }
    }

    @GetMapping("/shareholder/{shareholderId}/statistics")
    public ResponseEntity<?> getWithdrawalStatistics(@PathVariable Long shareholderId) {
        try {
            Map<String, Object> stats = withdrawalService.getWithdrawalStatistics(shareholderId);
            return ResponseEntity.ok(stats);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch statistics: " + e.getMessage()));
        }
    }

    @GetMapping("/statistics")
    public ResponseEntity<?> getAllWithdrawalStatistics() {
        try {
            Map<String, Object> stats = withdrawalService.getAllWithdrawalStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch statistics: " + e.getMessage()));
        }
    }
}