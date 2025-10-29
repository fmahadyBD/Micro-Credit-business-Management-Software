package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.entity.ShareTransaction;
import com.fmahadybd.backend.entity.TransactionType;
import com.fmahadybd.backend.entity.TransactionStatus;
import com.fmahadybd.backend.repository.ShareholderRepository;
import com.fmahadybd.backend.repository.ShareTransactionRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShareTransactionService {

    private final ShareTransactionRepository transactionRepository;
    private final ShareholderRepository shareholderRepository;

    @Transactional
    public ShareTransaction requestBuyShares(Long shareholderId, Integer quantity, Double pricePerShare, String notes) {
        log.info("Processing buy share request for shareholder: {}", shareholderId);
        
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be a positive number");
        }
        
        if (pricePerShare == null || pricePerShare <= 0) {
            throw new IllegalArgumentException("Price per share must be a positive number");
        }
        
        Shareholder shareholder = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + shareholderId));
        
        if (!"Active".equalsIgnoreCase(shareholder.getStatus())) {
            throw new IllegalStateException("Cannot process transaction for inactive shareholder");
        }
        
        Double totalAmount = quantity * pricePerShare;
        
        ShareTransaction transaction = ShareTransaction.builder()
                .shareholder(shareholder)
                .type(TransactionType.BUY)
                .shareQuantity(quantity)
                .sharePrice(pricePerShare)
                .totalAmount(totalAmount)
                .notes(notes != null && !notes.trim().isEmpty() ? notes : "Share purchase request")
                .status(TransactionStatus.PENDING)
                .transactionDate(LocalDateTime.now())
                .build();
        
        ShareTransaction saved = transactionRepository.save(transaction);
        log.info("Buy share request created with id: {}", saved.getId());
        return saved;
    }

    @Transactional
    public ShareTransaction requestSellShares(Long shareholderId, Integer quantity, Double pricePerShare, String notes) {
        log.info("Processing sell share request for shareholder: {}", shareholderId);
        
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be a positive number");
        }
        
        if (pricePerShare == null || pricePerShare <= 0) {
            throw new IllegalArgumentException("Price per share must be a positive number");
        }
        
        Shareholder shareholder = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + shareholderId));
        
        if (!"Active".equalsIgnoreCase(shareholder.getStatus())) {
            throw new IllegalStateException("Cannot process transaction for inactive shareholder");
        }
        
        // Check if shareholder has enough shares to sell
        Integer currentShares = shareholder.getTotalShare() != null ? shareholder.getTotalShare() : 0;
        if (quantity > currentShares) {
            throw new IllegalStateException("Insufficient shares. Available: " + currentShares + ", Requested: " + quantity);
        }
        
        Double totalAmount = quantity * pricePerShare;
        
        ShareTransaction transaction = ShareTransaction.builder()
                .shareholder(shareholder)
                .type(TransactionType.SELL)
                .shareQuantity(quantity)
                .sharePrice(pricePerShare)
                .totalAmount(totalAmount)
                .notes(notes != null && !notes.trim().isEmpty() ? notes : "Share sale request")
                .status(TransactionStatus.PENDING)
                .transactionDate(LocalDateTime.now())
                .build();
        
        ShareTransaction saved = transactionRepository.save(transaction);
        log.info("Sell share request created with id: {}", saved.getId());
        return saved;
    }

    public List<ShareTransaction> getShareTransactions(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }
        
        log.info("Fetching share transactions for shareholder: {}", shareholderId);
        return transactionRepository.findByShareholderIdOrderByTransactionDateDesc(shareholderId);
    }

    public List<ShareTransaction> getRecentTransactions(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }
        
        log.info("Fetching recent transactions for shareholder: {}", shareholderId);
        return transactionRepository.findTop5ByShareholderIdOrderByTransactionDateDesc(shareholderId);
    }

    public List<ShareTransaction> getPendingTransactions() {
        log.info("Fetching all pending transactions");
        return transactionRepository.findByStatusOrderByTransactionDateDesc(TransactionStatus.PENDING);
    }

    public ShareTransaction getTransactionById(Long transactionId) {
        if (transactionId == null) {
            throw new IllegalArgumentException("Transaction ID cannot be null");
        }
        
        return transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + transactionId));
    }

    @Transactional
    public ShareTransaction completeTransaction(Long transactionId, String processedBy) {
        log.info("Completing transaction: {}", transactionId);
        
        if (transactionId == null) {
            throw new IllegalArgumentException("Transaction ID cannot be null");
        }
        
        if (processedBy == null || processedBy.trim().isEmpty()) {
            throw new IllegalArgumentException("Processed by information is required");
        }
        
        ShareTransaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + transactionId));
        
        if (transaction.getStatus() != TransactionStatus.PENDING) {
            throw new IllegalStateException("Transaction is not in pending status. Current status: " + transaction.getStatus());
        }
        
        Shareholder shareholder = transaction.getShareholder();
        
        if (!"Active".equalsIgnoreCase(shareholder.getStatus())) {
            throw new IllegalStateException("Cannot complete transaction for inactive shareholder");
        }
        
        if (transaction.getType() == TransactionType.BUY) {
            // Add shares and investment
            Integer currentShares = shareholder.getTotalShare() != null ? shareholder.getTotalShare() : 0;
            Double currentInvestment = shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0;
            
            shareholder.setTotalShare(currentShares + transaction.getShareQuantity());
            shareholder.setInvestment(currentInvestment + transaction.getTotalAmount());
            
            log.info("Added {} shares to shareholder {}", transaction.getShareQuantity(), shareholder.getId());
        } else if (transaction.getType() == TransactionType.SELL) {
            // Verify shares again before selling
            Integer currentShares = shareholder.getTotalShare() != null ? shareholder.getTotalShare() : 0;
            if (transaction.getShareQuantity() > currentShares) {
                throw new IllegalStateException("Insufficient shares for sale. Available: " + currentShares);
            }
            
            // Subtract shares
            shareholder.setTotalShare(currentShares - transaction.getShareQuantity());
            
            // Add sale amount to current balance
            Double currentBalance = shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0;
            shareholder.setCurrentBalance(currentBalance + transaction.getTotalAmount());
            
            // Reduce investment proportionally
            Double currentInvestment = shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0;
            if (currentShares > 0) {
                Double investmentToReduce = currentInvestment * (transaction.getShareQuantity().doubleValue() / currentShares);
                shareholder.setInvestment(currentInvestment - investmentToReduce);
            }
            
            log.info("Removed {} shares from shareholder {}", transaction.getShareQuantity(), shareholder.getId());
        }
        
        shareholderRepository.save(shareholder);
        
        transaction.setStatus(TransactionStatus.COMPLETED);
        transaction.setProcessedBy(processedBy);
        transaction.setProcessedDate(LocalDateTime.now());
        
        ShareTransaction completed = transactionRepository.save(transaction);
        log.info("Transaction {} completed successfully", transactionId);
        return completed;
    }

    @Transactional
    public ShareTransaction cancelTransaction(Long transactionId, String reason) {
        log.info("Cancelling transaction: {}", transactionId);
        
        if (transactionId == null) {
            throw new IllegalArgumentException("Transaction ID cannot be null");
        }
        
        ShareTransaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + transactionId));
        
        if (transaction.getStatus() != TransactionStatus.PENDING) {
            throw new IllegalStateException("Only pending transactions can be cancelled. Current status: " + transaction.getStatus());
        }
        
        transaction.setStatus(TransactionStatus.CANCELLED);
        
        String currentNotes = transaction.getNotes() != null ? transaction.getNotes() : "";
        String cancellationNote = reason != null && !reason.trim().isEmpty() ? "Cancelled: " + reason : "Cancelled";
        
        if (!currentNotes.isEmpty()) {
            transaction.setNotes(currentNotes + " | " + cancellationNote);
        } else {
            transaction.setNotes(cancellationNote);
        }
        
        transaction.setProcessedDate(LocalDateTime.now());
        
        ShareTransaction cancelled = transactionRepository.save(transaction);
        log.info("Transaction {} cancelled", transactionId);
        return cancelled;
    }

    public Map<String, Object> getTransactionStatistics(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }
        
        log.info("Fetching transaction statistics for shareholder: {}", shareholderId);
        
        List<ShareTransaction> allTransactions = getShareTransactions(shareholderId);
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalTransactions", allTransactions.size());
        
        int totalSharesBought = allTransactions.stream()
                .filter(t -> t.getType() == TransactionType.BUY && t.getStatus() == TransactionStatus.COMPLETED)
                .mapToInt(ShareTransaction::getShareQuantity)
                .sum();
        stats.put("totalSharesBought", totalSharesBought);
        
        int totalSharesSold = allTransactions.stream()
                .filter(t -> t.getType() == TransactionType.SELL && t.getStatus() == TransactionStatus.COMPLETED)
                .mapToInt(ShareTransaction::getShareQuantity)
                .sum();
        stats.put("totalSharesSold", totalSharesSold);
        
        long pendingTransactions = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.PENDING)
                .count();
        stats.put("pendingTransactions", pendingTransactions);
        
        long completedTransactions = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.COMPLETED)
                .count();
        stats.put("completedTransactions", completedTransactions);
        
        long cancelledTransactions = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.CANCELLED)
                .count();
        stats.put("cancelledTransactions", cancelledTransactions);
        
        double totalAmountInvested = allTransactions.stream()
                .filter(t -> t.getType() == TransactionType.BUY && t.getStatus() == TransactionStatus.COMPLETED)
                .mapToDouble(ShareTransaction::getTotalAmount)
                .sum();
        stats.put("totalAmountInvested", totalAmountInvested);
        
        double totalAmountReceived = allTransactions.stream()
                .filter(t -> t.getType() == TransactionType.SELL && t.getStatus() == TransactionStatus.COMPLETED)
                .mapToDouble(ShareTransaction::getTotalAmount)
                .sum();
        stats.put("totalAmountReceived", totalAmountReceived);
        
        return stats;
    }
    
    public Map<String, Object> getAllTransactionStatistics() {
        log.info("Fetching global transaction statistics");
        
        List<ShareTransaction> allTransactions = transactionRepository.findAll();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalTransactions", allTransactions.size());
        
        long pendingCount = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.PENDING)
                .count();
        stats.put("pendingTransactions", pendingCount);
        
        long completedCount = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.COMPLETED)
                .count();
        stats.put("completedTransactions", completedCount);
        
        long cancelledCount = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.CANCELLED)
                .count();
        stats.put("cancelledTransactions", cancelledCount);
        
        int totalSharesTraded = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.COMPLETED)
                .mapToInt(ShareTransaction::getShareQuantity)
                .sum();
        stats.put("totalSharesTraded", totalSharesTraded);
        
        double totalTransactionValue = allTransactions.stream()
                .filter(t -> t.getStatus() == TransactionStatus.COMPLETED)
                .mapToDouble(ShareTransaction::getTotalAmount)
                .sum();
        stats.put("totalTransactionValue", totalTransactionValue);
        
        return stats;
    }
}