package com.fmahadybd.backend.service;

import com.fmahadybd.backend.dto.MainBalanceResponseDTO;
import com.fmahadybd.backend.dto.EarningsResponseDTO;
import com.fmahadybd.backend.dto.TransactionHistoryResponseDTO;
import com.fmahadybd.backend.entity.*;
import com.fmahadybd.backend.mapper.MainBalanceMapper;
import com.fmahadybd.backend.repository.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class MainBalanceService {

    private final MainBalanceRepository mainBalanceRepository;
    private final TransactionHistoryRepository transactionHistoryRepository;
    private final ShareholderRepository shareholderRepository;
    private final MainBalanceMapper mapper;

    /**
     * Get current main balance (always returns the latest single record)
     */
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
                                .totalEarnings(0.0)
                                .build()));
    }

    /**
     * Log transaction with proper details
     */
    private void logTransaction(String type, double amount, String desc, Long shareholderId) {
        TransactionHistory txn = TransactionHistory.builder()
                .type(type)
                .amount(amount)
                .description(desc)
                .shareholderId(shareholderId)
                .timestamp(LocalDateTime.now())
                .build();
        transactionHistoryRepository.save(txn);
        log.info("Transaction logged: {} - Amount: {} - Shareholder: {}", type, amount, shareholderId);
    }

    /**
     * Add investment to main balance
     */
    @Transactional
    public MainBalanceResponseDTO addInvestment(double amount, Long shareholderId) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Investment amount must be positive");
        }

        // Verify shareholder exists
        Shareholder investor = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new IllegalArgumentException("Shareholder not found with ID: " + shareholderId));

        MainBalance mb = getMainBalance();

        // Update shareholder
        investor.setInvestment(investor.getInvestment() + amount);
        investor.setCurrentBalance(investor.getCurrentBalance() + amount);
        shareholderRepository.save(investor);

        // Update main balance
        mb.setTotalInvestment(mb.getTotalInvestment() + amount);
        mb.setTotalBalance(mb.getTotalBalance() + amount);
        
        MainBalance saved = mainBalanceRepository.save(mb);

        // Log transaction
        logTransaction("INVESTMENT", amount, 
            "Investment added by shareholder: " + investor.getName(), shareholderId);

        log.info("Investment added: {} by shareholder ID: {}", amount, shareholderId);
        return mapper.toResponseDTO(saved, "Investment added successfully");
    }

    /**
     * Process withdrawal from main balance
     */
    @Transactional
    public MainBalanceResponseDTO withdraw(double amount, Long shareholderId) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be positive");
        }

        MainBalance mb = getMainBalance();

        if (mb.getTotalBalance() < amount) {
            throw new IllegalArgumentException(
                "Insufficient balance. Available: " + mb.getTotalBalance() + ", Requested: " + amount);
        }

        // Verify shareholder exists
        Shareholder shareholder = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new IllegalArgumentException("Shareholder not found with ID: " + shareholderId));

        // Update shareholder balance
        shareholder.setCurrentBalance(shareholder.getCurrentBalance() - amount);
        shareholderRepository.save(shareholder);

        // Update main balance
        mb.setTotalWithdrawal(mb.getTotalWithdrawal() + amount);
        mb.setTotalBalance(mb.getTotalBalance() - amount);

        MainBalance saved = mainBalanceRepository.save(mb);

        // Log transaction
        logTransaction("WITHDRAWAL", amount, 
            "Withdrawal by shareholder: " + shareholder.getName(), shareholderId);

        log.info("Withdrawal processed: {} for shareholder ID: {}", amount, shareholderId);
        return mapper.toResponseDTO(saved, "Withdrawal successful");
    }

    /**
     * Add product cost (deduct from balance)
     */
    @Transactional
    public MainBalanceResponseDTO addProductCost(double cost) {
        if (cost <= 0) {
            throw new IllegalArgumentException("Product cost must be positive");
        }

        MainBalance mb = getMainBalance();

        if (mb.getTotalBalance() < cost) {
            throw new IllegalArgumentException(
                "Insufficient balance for product cost. Available: " + mb.getTotalBalance() + ", Required: " + cost);
        }

        mb.setTotalProductCost(mb.getTotalProductCost() + cost);
        mb.setTotalBalance(mb.getTotalBalance() - cost);

        MainBalance saved = mainBalanceRepository.save(mb);

        // Log transaction
        logTransaction("PRODUCT_COST", cost, "Product purchase cost", null);

        log.info("Product cost added: {}", cost);
        return mapper.toResponseDTO(saved, "Product cost added successfully");
    }

    /**
     * Add maintenance cost (deduct from balance)
     */
    @Transactional
    public MainBalanceResponseDTO addMaintenanceCost(double cost) {
        if (cost <= 0) {
            throw new IllegalArgumentException("Maintenance cost must be positive");
        }

        MainBalance mb = getMainBalance();

        if (mb.getTotalBalance() < cost) {
            throw new IllegalArgumentException(
                "Insufficient balance for maintenance cost. Available: " + mb.getTotalBalance() + ", Required: " + cost);
        }

        mb.setTotalMaintenanceCost(mb.getTotalMaintenanceCost() + cost);
        mb.setTotalBalance(mb.getTotalBalance() - cost);

        MainBalance saved = mainBalanceRepository.save(mb);

        // Log transaction
        logTransaction("MAINTENANCE", cost, "Maintenance expense", null);

        log.info("Maintenance cost added: {}", cost);
        return mapper.toResponseDTO(saved, "Maintenance cost added successfully");
    }

    /**
     * Add installment return (increase balance + earnings)
     * This method is for manual/direct installment returns
     */
    @Transactional
    public MainBalanceResponseDTO addInstallmentReturn(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Installment amount must be positive");
        }

        MainBalance mb = getMainBalance();

        // Calculate 15% earnings on the amount
        double earningsAmount = amount * 0.15;

        mb.setTotalInstallmentReturn(mb.getTotalInstallmentReturn() + amount);
        mb.setTotalBalance(mb.getTotalBalance() + amount);
        mb.setTotalEarnings(mb.getTotalEarnings() + earningsAmount);

        MainBalance saved = mainBalanceRepository.save(mb);

        // Log transaction
        logTransaction("INSTALLMENT_RETURN", amount, 
            "Manual installment return - Earnings: " + earningsAmount, null);

        log.info("Installment return recorded: {} (Earnings: {})", amount, earningsAmount);
        return mapper.toResponseDTO(saved, "Installment return recorded successfully");
    }

    /**
     * Add installment return with specific principal and earnings calculation
     * Used internally by payment schedule service
     */
    @Transactional
    public MainBalanceResponseDTO addInstallmentReturnWithPrincipal(double amount, double principalAmount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Installment amount must be positive");
        }

        MainBalance mb = getMainBalance();

        // Calculate 15% earnings on the principal
        double earningsAmount = principalAmount * 0.15;

        mb.setTotalInstallmentReturn(mb.getTotalInstallmentReturn() + amount);
        mb.setTotalBalance(mb.getTotalBalance() + amount);
        mb.setTotalEarnings(mb.getTotalEarnings() + earningsAmount);

        MainBalance saved = mainBalanceRepository.save(mb);

        // Log transaction
        logTransaction("INSTALLMENT_RETURN", amount, 
            "Installment return - Principal: " + principalAmount + " - Earnings: " + earningsAmount, null);

        log.info("Installment return recorded: {} (Principal: {}, Earnings: {})", amount, principalAmount, earningsAmount);
        return mapper.toResponseDTO(saved, "Installment return recorded successfully");
    }

    /**
     * Calculate investor earnings
     */
    public EarningsResponseDTO calculateInvestorEarnings() {
        MainBalance mb = getMainBalance();
        
        // Total earnings = Total returns - Total expenses
        Double totalIncome = mb.getTotalInstallmentReturn() + mb.getTotalInvestment();
        Double totalExpenses = mb.getTotalProductCost() + mb.getTotalMaintenanceCost() + mb.getTotalWithdrawal();
        Double netEarnings = totalIncome - totalExpenses;

        return EarningsResponseDTO.builder()
                .earnings(netEarnings)
                .totalEarningsFromInterest(mb.getTotalEarnings())
                .message("Earnings calculated successfully")
                .build();
    }

    /**
     * Get all transactions
     */
    public List<TransactionHistoryResponseDTO> getAllTransactions() {
        List<TransactionHistory> transactions = transactionHistoryRepository.findAllByOrderByTimestampDesc();
        return mapper.toTransactionDTOList(transactions);
    }

    /**
     * Get transactions by type
     */
    public List<TransactionHistoryResponseDTO> getTransactionsByType(String type) {
        List<TransactionHistory> transactions = transactionHistoryRepository.findByTypeOrderByTimestampDesc(type);
        return mapper.toTransactionDTOList(transactions);
    }

    /**
     * Get transactions by shareholder
     */
    public List<TransactionHistoryResponseDTO> getTransactionsByShareholder(Long shareholderId) {
        List<TransactionHistory> transactions = 
            transactionHistoryRepository.findByShareholderIdOrderByTimestampDesc(shareholderId);
        return mapper.toTransactionDTOList(transactions);
    }

    /**
     * Get current balance
     */
    public MainBalanceResponseDTO getBalance() {
        MainBalance mb = getMainBalance();
        return mapper.toResponseDTO(mb, "Balance retrieved successfully");
    }
}