package com.fmahadybd.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddInvestmentDTO {
    
    // @NotNull(message = "Shareholder ID is required")
    private Long shareholderId;
    
    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    private Double amount;
    
    @NotBlank(message = "Description is required")
    private String description;
    
    private String performedBy;
}