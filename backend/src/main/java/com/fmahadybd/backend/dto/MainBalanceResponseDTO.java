package com.fmahadybd.backend.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class MainBalanceResponseDTO {
    private Double totalBalance;
    private Double totalInvestment;
    private Double totalProductCost;
    private Double totalMaintenanceCost;
    private Double totalInstallmentReturn;
    private Double totalEarnings;
    private Double totalExpenses;
    private Double netProfit;
    private LocalDateTime lastUpdated;
}