package com.fmahadybd.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Shareholder details DTO")
public class ShareholderDetailsDTO {
    
    @Schema(description = "Shareholder information")
    private ShareholderDTO shareholder;
    
    @Schema(description = "Total shares")
    private Integer totalShares;
    
    @Schema(description = "Total earnings")
    private Double totalEarnings;
    
    @Schema(description = "Current balance")
    private Double currentBalance;
    
    @Schema(description = "Active since date")
    private LocalDate activeSince;
    
    @Schema(description = "Investment amount")
    private Double investment;
    
    @Schema(description = "Total value")
    private Double totalValue;
}