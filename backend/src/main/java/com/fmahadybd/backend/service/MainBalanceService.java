package com.fmahadybd.backend.service;

import com.fmahadybd.backend.dto.MainBalanceResponseDTO;
import com.fmahadybd.backend.dto.EarningsResponseDTO;
import com.fmahadybd.backend.dto.TransactionHistoryResponseDTO;
import com.fmahadybd.backend.entity.*;
import com.fmahadybd.backend.mapper.MainBalanceMapper;
import com.fmahadybd.backend.repository.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MainBalanceService {

    private final MainBalanceRepository mainBalanceRepository;
    private final TransactionHistoryRepository transactionHistoryRepository;
    private final ShareholderRepository shareholderRepository;
    private final MainBalanceMapper mapper;

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

    private void logTransaction(String type, double amount, String desc, Long shareholderId) {
        TransactionHistory txn = TransactionHistory.builder()
                .type(type)
                .amount(amount)
                .description(desc)
                .timestamp(LocalDateTime.now())
                .shareholder(shareholderId != null ? shareholderRepository.findById(shareholderId).orElse(null) : null)
                .build();
        transactionHistoryRepository.save(txn);
    }

    @Transactional
    public MainBalanceResponseDTO addInvestment(double amount, Long shareholderId) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Investment amount must be positive");
        }

        // Verify shareholder exists
        Shareholder old_investor = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new IllegalArgumentException("Shareholder not found with ID: " + shareholderId));

        MainBalance mb = getMainBalance();
        old_investor.setInvestment(old_investor.getInvestment() + amount);
        old_investor.setInvestment(old_investor.getCurrentBalance() + amount);

        mb.setTotalInvestment(mb.getTotalInvestment() + amount);
        mb.setTotalBalance(mb.getTotalBalance() + amount);

        logTransaction("INVESTMENT", amount, "Investment added", shareholderId);

        MainBalance saved = mainBalanceRepository.save(mb);
        shareholderRepository.save(old_investor);
        return mapper.toResponseDTO(saved, "Investment added successfully");
    }

    @Transactional
    public MainBalanceResponseDTO withdraw(double amount, Long shareholderId) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be positive");
        }

        MainBalance mb = getMainBalance();

        if (mb.getTotalBalance() < amount) {
            throw new IllegalArgumentException("Insufficient balance. Available: " + mb.getTotalBalance());
        }

        // Verify shareholder exists
        shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new IllegalArgumentException("Shareholder not found with ID: " + shareholderId));

        mb.setTotalWithdrawal(mb.getTotalWithdrawal() + amount);
        mb.setTotalBalance(mb.getTotalBalance() - amount);

        logTransaction("WITHDRAWAL", amount, "Investor withdrawal", shareholderId);

        MainBalance saved = mainBalanceRepository.save(mb);
        return mapper.toResponseDTO(saved, "Withdrawal successful");
    }

    @Transactional
    public MainBalanceResponseDTO addProductCost(double cost) {
        if (cost <= 0) {
            throw new IllegalArgumentException("Product cost must be positive");
        }

        MainBalance mb = getMainBalance();

        if (mb.getTotalBalance() < cost) {
            throw new IllegalArgumentException(
                    "Insufficient balance for product cost. Available: " + mb.getTotalBalance());
        }

        mb.setTotalProductCost(mb.getTotalProductCost() + cost);
        mb.setTotalBalance(mb.getTotalBalance() - cost);

        logTransaction("PRODUCT_COST", cost, "Product purchase cost", null);

        MainBalance saved = mainBalanceRepository.save(mb);
        return mapper.toResponseDTO(saved, "Product cost added successfully");
    }

    @Transactional
    public MainBalanceResponseDTO addMaintenanceCost(double cost) {
        if (cost <= 0) {
            throw new IllegalArgumentException("Maintenance cost must be positive");
        }

        MainBalance mb = getMainBalance();

        if (mb.getTotalBalance() < cost) {
            throw new IllegalArgumentException(
                    "Insufficient balance for maintenance cost. Available: " + mb.getTotalBalance());
        }

        mb.setTotalMaintenanceCost(mb.getTotalMaintenanceCost() + cost);
        mb.setTotalBalance(mb.getTotalBalance() - cost);

        logTransaction("MAINTENANCE", cost, "Maintenance expense", null);

        MainBalance saved = mainBalanceRepository.save(mb);
        return mapper.toResponseDTO(saved, "Maintenance cost added successfully");
    }

    @Transactional
    public MainBalanceResponseDTO addInstallmentReturn(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Installment amount must be positive");
        }

        MainBalance mb = getMainBalance();
        mb.setTotalInstallmentReturn(mb.getTotalInstallmentReturn() + amount);
        mb.setTotalBalance(mb.getTotalBalance() + amount);

        logTransaction("INSTALLMENT_RETURN", amount, "Installment return", null);

        MainBalance saved = mainBalanceRepository.save(mb);
        return mapper.toResponseDTO(saved, "Installment return recorded successfully");
    }

    public EarningsResponseDTO calculateInvestorEarnings() {
        MainBalance mb = getMainBalance();
        Double earnings = mb.getEarnings();

        return EarningsResponseDTO.builder()
                .earnings(earnings)
                .message("Earnings calculated successfully")
                .build();
    }

    public List<TransactionHistoryResponseDTO> getAllTransactions() {
        List<TransactionHistory> transactions = transactionHistoryRepository.findAll();
        return mapper.toTransactionDTOList(transactions);
    }

    public MainBalanceResponseDTO getBalance() {
        MainBalance mb = getMainBalance();
        return mapper.toResponseDTO(mb, "Balance retrieved successfully");
    }
}