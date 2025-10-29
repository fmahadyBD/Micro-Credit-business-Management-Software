package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.entity.WithdrawalRequest;
import com.fmahadybd.backend.entity.WithdrawalStatus;
import com.fmahadybd.backend.repository.ShareholderRepository;
import com.fmahadybd.backend.repository.WithdrawalRepository;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class WithdrawalService {

    private final WithdrawalRepository withdrawalRepository;
    private final ShareholderRepository shareholderRepository;

    @Transactional
    public WithdrawalRequest requestWithdrawal(Long shareholderId, Double amount, String reason) {
        log.info("Processing withdrawal request for shareholder: {}", shareholderId);
        
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be a positive number");
        }
        
        Shareholder shareholder = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + shareholderId));
        
        if (!"Active".equalsIgnoreCase(shareholder.getStatus())) {
            throw new IllegalStateException("Cannot process withdrawal for inactive shareholder");
        }
        
        Double currentBalance = shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0;
        
        if (amount > currentBalance) {
            throw new IllegalStateException(String.format("Insufficient balance. Available: %.2f, Requested: %.2f", 
                    currentBalance, amount));
        }
        
        // Check for pending withdrawals
        List<WithdrawalRequest> pendingWithdrawals = withdrawalRepository
                .findByShareholderIdAndStatus(shareholderId, WithdrawalStatus.PENDING);
        
        if (!pendingWithdrawals.isEmpty()) {
            double pendingAmount = pendingWithdrawals.stream()
                    .mapToDouble(WithdrawalRequest::getAmount)
                    .sum();
            
            if (amount + pendingAmount > currentBalance) {
                throw new IllegalStateException(String.format(
                        "Insufficient balance considering pending withdrawals. Available: %.2f, Pending: %.2f, Requested: %.2f", 
                        currentBalance, pendingAmount, amount));
            }
        }
        
        WithdrawalRequest request = WithdrawalRequest.builder()
                .shareholder(shareholder)
                .amount(amount)
                .reason(reason != null && !reason.trim().isEmpty() ? reason : "Withdrawal request")
                .status(WithdrawalStatus.PENDING)
                .requestDate(LocalDateTime.now())
                .build();
        
        WithdrawalRequest saved = withdrawalRepository.save(request);
        log.info("Withdrawal request created with id: {}", saved.getId());
        return saved;
    }

    public List<WithdrawalRequest> getWithdrawalRequests(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }
        
        log.info("Fetching withdrawal requests for shareholder: {}", shareholderId);
        return withdrawalRepository.findByShareholderIdOrderByRequestDateDesc(shareholderId);
    }

    public List<WithdrawalRequest> getRecentWithdrawals(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }
        
        log.info("Fetching recent withdrawals for shareholder: {}", shareholderId);
        return withdrawalRepository.findTop5ByShareholderIdOrderByRequestDateDesc(shareholderId);
    }

    public List<WithdrawalRequest> getPendingWithdrawals() {
        log.info("Fetching all pending withdrawal requests");
        return withdrawalRepository.findByStatusOrderByRequestDateDesc(WithdrawalStatus.PENDING);
    }
    
    public List<WithdrawalRequest> getApprovedWithdrawals() {
        log.info("Fetching all approved withdrawal requests");
        return withdrawalRepository.findByStatusOrderByRequestDateDesc(WithdrawalStatus.APPROVED);
    }

    public WithdrawalRequest getWithdrawalById(Long requestId) {
        if (requestId == null) {
            throw new IllegalArgumentException("Withdrawal request ID cannot be null");
        }
        
        return withdrawalRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Withdrawal request not found with id: " + requestId));
    }

    @Transactional
    public WithdrawalRequest approveWithdrawal(Long requestId, String processedBy) {
        log.info("Approving withdrawal request: {}", requestId);
        
        if (requestId == null) {
            throw new IllegalArgumentException("Withdrawal request ID cannot be null");
        }
        
        if (processedBy == null || processedBy.trim().isEmpty()) {
            throw new IllegalArgumentException("Processed by information is required");
        }
        
        WithdrawalRequest request = withdrawalRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Withdrawal request not found with id: " + requestId));
        
        if (request.getStatus() != WithdrawalStatus.PENDING) {
            throw new IllegalStateException("Withdrawal request is not in pending status. Current status: " + request.getStatus());
        }
        
        Shareholder shareholder = request.getShareholder();
        
        if (!"Active".equalsIgnoreCase(shareholder.getStatus())) {
            throw new IllegalStateException("Cannot approve withdrawal for inactive shareholder");
        }
        
        // Verify sufficient balance again (in case it changed)
        Double currentBalance = shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0;
        
        if (request.getAmount() > currentBalance) {
            throw new IllegalStateException(String.format(
                    "Shareholder has insufficient balance for this withdrawal. Available: %.2f, Requested: %.2f", 
                    currentBalance, request.getAmount()));
        }
        
        // Deduct from balance
        shareholder.setCurrentBalance(currentBalance - request.getAmount());
        shareholderRepository.save(shareholder);
        
        // Update request
        request.setStatus(WithdrawalStatus.APPROVED);
        request.setProcessedBy(processedBy);
        request.setProcessedDate(LocalDateTime.now());
        
        WithdrawalRequest approved = withdrawalRepository.save(request);
        log.info("Withdrawal request {} approved and balance deducted", requestId);
        return approved;
    }

    @Transactional
    public WithdrawalRequest rejectWithdrawal(Long requestId, String processedBy, String reason) {
        log.info("Rejecting withdrawal request: {}", requestId);
        
        if (requestId == null) {
            throw new IllegalArgumentException("Withdrawal request ID cannot be null");
        }
        
        if (processedBy == null || processedBy.trim().isEmpty()) {
            throw new IllegalArgumentException("Processed by information is required");
        }
        
        if (reason == null || reason.trim().isEmpty()) {
            throw new IllegalArgumentException("Rejection reason is required");
        }
        
        WithdrawalRequest request = withdrawalRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Withdrawal request not found with id: " + requestId));
        
        if (request.getStatus() != WithdrawalStatus.PENDING) {
            throw new IllegalStateException("Withdrawal request is not in pending status. Current status: " + request.getStatus());
        }
        
        request.setStatus(WithdrawalStatus.REJECTED);
        request.setProcessedBy(processedBy);
        request.setProcessedDate(LocalDateTime.now());
        request.setRejectionReason(reason);
        
        WithdrawalRequest rejected = withdrawalRepository.save(request);
        log.info("Withdrawal request {} rejected", requestId);
        return rejected;
    }

    @Transactional
    public WithdrawalRequest markAsProcessed(Long requestId, String processedBy) {
        log.info("Marking withdrawal request as processed: {}", requestId);
        
        if (requestId == null) {
            throw new IllegalArgumentException("Withdrawal request ID cannot be null");
        }
        
        if (processedBy == null || processedBy.trim().isEmpty()) {
            throw new IllegalArgumentException("Processed by information is required");
        }
        
        WithdrawalRequest request = withdrawalRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Withdrawal request not found with id: " + requestId));
        
        if (request.getStatus() != WithdrawalStatus.APPROVED) {
            throw new IllegalStateException("Only approved withdrawals can be marked as processed. Current status: " + request.getStatus());
        }
        
        request.setStatus(WithdrawalStatus.PROCESSED);
        request.setProcessedBy(processedBy);
        request.setProcessedDate(LocalDateTime.now());
        
        WithdrawalRequest processed = withdrawalRepository.save(request);
        log.info("Withdrawal request {} marked as processed", requestId);
        return processed;
    }

    @Transactional
    public WithdrawalRequest cancelWithdrawal(Long requestId, String reason) {
        log.info("Cancelling withdrawal request: {}", requestId);
        
        if (requestId == null) {
            throw new IllegalArgumentException("Withdrawal request ID cannot be null");
        }
        
        WithdrawalRequest request = withdrawalRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Withdrawal request not found with id: " + requestId));
        
        if (request.getStatus() != WithdrawalStatus.PENDING) {
            throw new IllegalStateException("Only pending withdrawal requests can be cancelled. Current status: " + request.getStatus());
        }
        
        request.setStatus(WithdrawalStatus.CANCELLED);
        request.setProcessedDate(LocalDateTime.now());
        
        String cancellationReason = reason != null && !reason.trim().isEmpty() ? reason : "Cancelled by user";
        request.setRejectionReason(cancellationReason);
        
        WithdrawalRequest cancelled = withdrawalRepository.save(request);
        log.info("Withdrawal request {} cancelled", requestId);
        return cancelled;
    }

    public Map<String, Object> getWithdrawalStatistics(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }
        
        log.info("Fetching withdrawal statistics for shareholder: {}", shareholderId);
        
        List<WithdrawalRequest> allWithdrawals = getWithdrawalRequests(shareholderId);
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalWithdrawals", allWithdrawals.size());
        
        double totalAmountWithdrawn = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.APPROVED || w.getStatus() == WithdrawalStatus.PROCESSED)
                .mapToDouble(WithdrawalRequest::getAmount)
                .sum();
        stats.put("totalAmountWithdrawn", totalAmountWithdrawn);
        
        long pendingWithdrawals = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.PENDING)
                .count();
        stats.put("pendingWithdrawals", pendingWithdrawals);
        
        double pendingAmount = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.PENDING)
                .mapToDouble(WithdrawalRequest::getAmount)
                .sum();
        stats.put("pendingAmount", pendingAmount);
        
        long approvedWithdrawals = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.APPROVED)
                .count();
        stats.put("approvedWithdrawals", approvedWithdrawals);
        
        long processedWithdrawals = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.PROCESSED)
                .count();
        stats.put("processedWithdrawals", processedWithdrawals);
        
        long rejectedWithdrawals = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.REJECTED)
                .count();
        stats.put("rejectedWithdrawals", rejectedWithdrawals);
        
        long cancelledWithdrawals = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.CANCELLED)
                .count();
        stats.put("cancelledWithdrawals", cancelledWithdrawals);
        
        return stats;
    }
    
    public Map<String, Object> getAllWithdrawalStatistics() {
        log.info("Fetching global withdrawal statistics");
        
        List<WithdrawalRequest> allWithdrawals = withdrawalRepository.findAll();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalWithdrawals", allWithdrawals.size());
        
        double totalAmountWithdrawn = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.APPROVED || w.getStatus() == WithdrawalStatus.PROCESSED)
                .mapToDouble(WithdrawalRequest::getAmount)
                .sum();
        stats.put("totalAmountWithdrawn", totalAmountWithdrawn);
        
        long pendingCount = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.PENDING)
                .count();
        stats.put("pendingWithdrawals", pendingCount);
        
        double pendingAmount = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.PENDING)
                .mapToDouble(WithdrawalRequest::getAmount)
                .sum();
        stats.put("pendingAmount", pendingAmount);
        
        long approvedCount = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.APPROVED)
                .count();
        stats.put("approvedWithdrawals", approvedCount);
        
        long processedCount = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.PROCESSED)
                .count();
        stats.put("processedWithdrawals", processedCount);
        
        long rejectedCount = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.REJECTED)
                .count();
        stats.put("rejectedWithdrawals", rejectedCount);
        
        long cancelledCount = allWithdrawals.stream()
                .filter(w -> w.getStatus() == WithdrawalStatus.CANCELLED)
                .count();
        stats.put("cancelledWithdrawals", cancelledCount);
        
        return stats;
    }
}