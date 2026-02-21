package com.fmahadybd.backend.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InstallmentCreateDTO {
    
    @NotNull(message = "Product ID is required")
    private Long productId;
    
    @NotNull(message = "Member ID is required")  // ADD THIS
    private Long memberId;                       // ADD THIS
    
    @NotNull(message = "Total amount is required")
    @Positive(message = "Total amount must be positive")
    private Double totalAmountOfProduct;
    
    @PositiveOrZero(message = "Other cost cannot be negative")
    private Double otherCost;
    
    @NotNull(message = "Advanced payment is required")
    @PositiveOrZero(message = "Advanced payment cannot be negative")
    private Double advanced_paid;
    
    @NotNull(message = "Installment months is required")
    @Min(value = 1, message = "Installment months must be at least 1")
    @Max(value = 60, message = "Installment months cannot exceed 60")
    private Integer installmentMonths;
    
    @NotNull(message = "Interest rate is required")
    @PositiveOrZero(message = "Interest rate cannot be negative")
    @DecimalMax(value = "100.0", message = "Interest rate cannot exceed 100%")
    private Double interestRate;
    
    private String status;
    
    @NotNull(message = "Agent ID is required")
    private Long agentId;
}