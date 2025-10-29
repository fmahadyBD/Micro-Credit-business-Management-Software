package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.ShareTransaction;
import com.fmahadybd.backend.service.ShareTransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ShareTransactionController {

    private final ShareTransactionService transactionService;

    @PostMapping("/buy")
    public ResponseEntity<?> requestBuyShares(
            @RequestParam Long shareholderId,
            @RequestParam Integer quantity,
            @RequestParam Double pricePerShare,
            @RequestParam(required = false) String notes) {
        try {
            ShareTransaction transaction = transactionService.requestBuyShares(
                    shareholderId, quantity, pricePerShare, notes);
            return ResponseEntity.status(HttpStatus.CREATED).body(transaction);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to create buy request: " + e.getMessage()));
        }
    }

    @PostMapping("/sell")
    public ResponseEntity<?> requestSellShares(
            @RequestParam Long shareholderId,
            @RequestParam Integer quantity,
            @RequestParam Double pricePerShare,
            @RequestParam(required = false) String notes) {
        try {
            ShareTransaction transaction = transactionService.requestSellShares(
                    shareholderId, quantity, pricePerShare, notes);
            return ResponseEntity.status(HttpStatus.CREATED).body(transaction);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to create sell request: " + e.getMessage()));
        }
    }

    @GetMapping("/shareholder/{shareholderId}")
    public ResponseEntity<?> getShareTransactions(@PathVariable Long shareholderId) {
        try {
            List<ShareTransaction> transactions = transactionService.getShareTransactions(shareholderId);
            return ResponseEntity.ok(transactions);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch transactions: " + e.getMessage()));
        }
    }

    @GetMapping("/shareholder/{shareholderId}/recent")
    public ResponseEntity<?> getRecentTransactions(@PathVariable Long shareholderId) {
        try {
            List<ShareTransaction> transactions = transactionService.getRecentTransactions(shareholderId);
            return ResponseEntity.ok(transactions);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch recent transactions: " + e.getMessage()));
        }
    }

    @GetMapping("/pending")
    public ResponseEntity<?> getPendingTransactions() {
        try {
            List<ShareTransaction> transactions = transactionService.getPendingTransactions();
            return ResponseEntity.ok(transactions);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch pending transactions: " + e.getMessage()));
        }
    }

    @GetMapping("/{transactionId}")
    public ResponseEntity<?> getTransactionById(@PathVariable Long transactionId) {
        try {
            ShareTransaction transaction = transactionService.getTransactionById(transactionId);
            return ResponseEntity.ok(transaction);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch transaction: " + e.getMessage()));
        }
    }

    @PostMapping("/{transactionId}/complete")
    public ResponseEntity<?> completeTransaction(
            @PathVariable Long transactionId,
            @RequestParam String processedBy) {
        try {
            ShareTransaction transaction = transactionService.completeTransaction(transactionId, processedBy);
            return ResponseEntity.ok(transaction);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to complete transaction: " + e.getMessage()));
        }
    }

    @PostMapping("/{transactionId}/cancel")
    public ResponseEntity<?> cancelTransaction(
            @PathVariable Long transactionId,
            @RequestParam(required = false) String reason) {
        try {
            ShareTransaction transaction = transactionService.cancelTransaction(transactionId, reason);
            return ResponseEntity.ok(transaction);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to cancel transaction: " + e.getMessage()));
        }
    }

    @GetMapping("/shareholder/{shareholderId}/statistics")
    public ResponseEntity<?> getTransactionStatistics(@PathVariable Long shareholderId) {
        try {
            Map<String, Object> stats = transactionService.getTransactionStatistics(shareholderId);
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
    public ResponseEntity<?> getAllTransactionStatistics() {
        try {
            Map<String, Object> stats = transactionService.getAllTransactionStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch statistics: " + e.getMessage()));
        }
    }
}