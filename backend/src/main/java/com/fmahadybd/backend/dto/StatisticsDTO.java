package com.fmahadybd.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Shareholder statistics DTO")
public class StatisticsDTO {
    
    @Schema(description = "Total shareholders")
    private Integer totalShareholders;
    
    @Schema(description = "Active shareholders")
    private Long activeShareholders;
    
    @Schema(description = "Inactive shareholders")
    private Long inactiveShareholders;
    
    @Schema(description = "Total investment")
    private Double totalInvestment;
    
    @Schema(description = "Total earnings")
    private Double totalEarnings;
    
    @Schema(description = "Total balance")
    private Double totalBalance;
    
    @Schema(description = "Total shares")
    private Integer totalShares;
    
    @Schema(description = "Total value")
    private Double totalValue;
}