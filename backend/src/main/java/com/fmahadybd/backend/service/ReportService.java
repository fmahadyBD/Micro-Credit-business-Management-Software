package com.fmahadybd.backend.service;

import com.fmahadybd.backend.dto.FinancialReport;
import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.repository.MainBalanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final MainBalanceRepository mainBalanceRepository;

    public FinancialReport generateFinancialReport() {
        MainBalance balance = mainBalanceRepository.findTopByOrderByIdDesc()
                .orElse(MainBalance.builder()
                        .totalBalance(0.0)
                        .totalInvestment(0.0)
                        .totalProductCost(0.0)
                        .totalMaintenanceCost(0.0)
                        .totalInstallmentReturn(0.0)
                        .totalEarnings(0.0)
                        .build());

        return FinancialReport.builder()
                .totalBalance(balance.getTotalBalance())
                .totalInvestment(balance.getTotalInvestment())
                .totalProductCost(balance.getTotalProductCost())
                .totalMaintenanceCost(balance.getTotalMaintenanceCost())
                .totalInstallmentReturn(balance.getTotalInstallmentReturn())
                .totalEarnings(balance.getTotalEarnings())
                .totalExpenses(balance.getTotalExpenses())
                .netProfit(balance.getNetProfit())
                .reportDate(LocalDateTime.now())
                .build();
    }
}