package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.entity.TransactionHistory;
import com.fmahadybd.backend.repository.MainBalanceRepository;
import com.fmahadybd.backend.repository.TransactionHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class FinancialService {

    private final MainBalanceRepository mainBalanceRepository;
    private final TransactionHistoryRepository transactionHistoryRepository;

    // Make this method PUBLIC so controller can access it
    public MainBalance getMainBalance() {
        return mainBalanceRepository.findTopByOrderByIdDesc() // Use this instead of findById(1L)
                .orElseGet(() -> MainBalance.builder()
                        .totalBalance(0.0)  // Change to 0.0 for Double
                        .totalInvestment(0.0)
                        .totalProductCost(0.0)
                        .totalMaintenanceCost(0.0)
                        .totalInstallmentReturn(0.0)
                        .totalEarnings(0.0)
                        .build());
    }

    @Transactional
    public void addInvestment(Double amount, String description, Long shareholderId, String performedBy) { // Change to Double
        MainBalance balance = getMainBalance();

        // Update main balance
        balance.setTotalInvestment(balance.getTotalInvestment() + amount);
        balance.setTotalBalance(balance.getTotalBalance() + amount);
        balance.setWhoChanged(performedBy);
        balance.setReason("Investment added");

        // Save transaction history
        TransactionHistory transaction = TransactionHistory.builder()
                .type("INVESTMENT")
                .amount(amount) // No need for .doubleValue()
                .description(description)
                .shareholderId(shareholderId)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
        mainBalanceRepository.save(balance);
    }

    @Transactional
    public void addProductCost(Double amount, String description, String performedBy) { // Change to Double
        MainBalance balance = getMainBalance();

        balance.setTotalProductCost(balance.getTotalProductCost() + amount);
        balance.setTotalBalance(balance.getTotalBalance() - amount);
        balance.setWhoChanged(performedBy);
        balance.setReason("Product cost added");

        TransactionHistory transaction = TransactionHistory.builder()
                .type("PRODUCT_COST")
                .amount(amount) // No need for .doubleValue()
                .description(description)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
        mainBalanceRepository.save(balance);
    }

    @Transactional
    public void addMaintenanceCost(Double amount, String description, String performedBy) { // Change to Double
        MainBalance balance = getMainBalance();

        balance.setTotalMaintenanceCost(balance.getTotalMaintenanceCost() + amount);
        balance.setTotalBalance(balance.getTotalBalance() - amount);
        balance.setWhoChanged(performedBy);
        balance.setReason("Maintenance cost added");

        TransactionHistory transaction = TransactionHistory.builder()
                .type("MAINTENANCE")
                .amount(amount) // No need for .doubleValue()
                .description(description)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
        mainBalanceRepository.save(balance);
    }

    @Transactional
    public void addInstallmentReturn(Double amount, String description, Long memberId, String performedBy) { // Change to Double
        MainBalance balance = getMainBalance();

        balance.setTotalInstallmentReturn(balance.getTotalInstallmentReturn() + amount);
        balance.setTotalBalance(balance.getTotalBalance() + amount);
        balance.setWhoChanged(performedBy);
        balance.setReason("Installment return added");

        TransactionHistory transaction = TransactionHistory.builder()
                .type("INSTALLMENT_RETURN")
                .amount(amount) // No need for .doubleValue()
                .description(description)
                .memberId(memberId)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
        mainBalanceRepository.save(balance);
    }

    @Transactional
    public void addEarnings(Double amount, String description, String performedBy) { // Change to Double
        MainBalance balance = getMainBalance();

        balance.setTotalEarnings(balance.getTotalEarnings() + amount);
        balance.setTotalBalance(balance.getTotalBalance() + amount);
        balance.setWhoChanged(performedBy);
        balance.setReason("Earnings added");

        TransactionHistory transaction = TransactionHistory.builder()
                .type("EARNINGS") // Changed to EARNINGS for clarity
                .amount(amount) // No need for .doubleValue()
                .description(description)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
        mainBalanceRepository.save(balance);
    }

    @Transactional
    public void addAdvancedPayment(Double amount, String description, Long memberId, String performedBy) { // Change to Double
        MainBalance balance = getMainBalance();

        balance.setTotalInstallmentReturn(balance.getTotalInstallmentReturn() + amount);
        balance.setTotalBalance(balance.getTotalBalance() + amount);
        balance.setWhoChanged(performedBy);
        balance.setReason("Advanced payment added");

        TransactionHistory transaction = TransactionHistory.builder()
                .type("ADVANCED_PAYMENT")
                .amount(amount) // No need for .doubleValue()
                .description(description)
                .memberId(memberId)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
        mainBalanceRepository.save(balance);
    }

    @Transactional
    public void addWithdrawal(Double amount, String description, Long shareholderId, String performedBy) { // Change to Double
        MainBalance balance = getMainBalance();

        // Check if sufficient balance exists
        if (amount > balance.getTotalBalance()) {
            throw new RuntimeException("Insufficient balance for withdrawal. Available: "
                    + balance.getTotalBalance() + ", Requested: " + amount);
        }

        balance.setTotalBalance(balance.getTotalBalance() - amount);
        balance.setWhoChanged(performedBy);
        balance.setReason("Withdrawal processed");

        TransactionHistory transaction = TransactionHistory.builder()
                .type("WITHDRAWAL")
                .amount(amount) // No need for .doubleValue()
                .description(description)
                .shareholderId(shareholderId)
                .timestamp(LocalDateTime.now())
                .build();

        transactionHistoryRepository.save(transaction);
        mainBalanceRepository.save(balance);
    }
}