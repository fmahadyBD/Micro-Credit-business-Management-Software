package com.fmahadybd.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "Main Balance DTO")
public class MainBalanceDTO {
    private Long id;
    private Double totalBalance;
    private Double totalInvestment;
    private Double totalWithdrawal;
    private Double totalProductCost;
    private Double totalMaintenanceCost;
    private Double totalInstallmentReturn;
    private Double totalExpenses;
    private Double earnings;
    private LocalDateTime lastUpdated;
}
