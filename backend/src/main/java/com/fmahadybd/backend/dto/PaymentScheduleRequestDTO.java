package com.fmahadybd.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentScheduleRequestDTO {
    
    @NotNull(message = "Agent ID is required")
    private Long agentId;
    
    @NotNull(message = "Installment ID is required")
    private Long installmentId;
    
    @NotNull(message = "Payment amount is required")
    @Positive(message = "Payment amount must be positive")
    @DecimalMin(value = "0.01", message = "Minimum payment amount is 0.01")
    private Double amount;
    
    @Size(max = 500, message = "Notes cannot exceed 500 characters")
    private String notes;
}