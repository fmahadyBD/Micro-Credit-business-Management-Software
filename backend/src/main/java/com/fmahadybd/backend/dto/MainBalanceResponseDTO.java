package com.fmahadybd.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MainBalanceResponseDTO {
    private Long id;
    private Double totalBalance;
    private Double totalInvestment;
    private Double totalWithdrawal;
    private Double totalProductCost;
    private Double totalMaintenanceCost;
    private Double totalInstallmentReturn;
    private Double earnings;
    private LocalDateTime lastUpdated;
    private String message;

}