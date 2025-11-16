package com.fmahadybd.backend.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class FinancialReport {
    private Double totalBalance;
    private Double totalInvestment;
    private Double totalProductCost;
    private Double totalMaintenanceCost;
    private Double totalInstallmentReturn;
    private Double totalEarnings;
    private Double totalExpenses;
    private Double netProfit;
    private LocalDateTime reportDate;
    
    // Additional calculated fields
    private Double totalIncome;
    private Double profitMargin; // if needed as percentage
    
    public Double getTotalExpenses() {
        return totalProductCost + totalMaintenanceCost;
    }
    
    public Double getTotalIncome() {
        return totalInvestment + totalInstallmentReturn + totalEarnings;
    }
    
    public Double getNetProfit() {
        return totalEarnings; // As per your requirement
    }
}