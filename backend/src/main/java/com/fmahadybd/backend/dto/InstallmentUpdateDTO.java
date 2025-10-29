package com.fmahadybd.backend.dto;

import com.fmahadybd.backend.entity.InstallmentStatus;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class InstallmentUpdateDTO {
    
    @Positive
    @DecimalMin("0.01")
    private Double totalAmountOfProduct;

    @PositiveOrZero
    private Double otherCost;

    @PositiveOrZero
    private Double advanced_paid;

    @Min(1)
    @Max(60)
    private Integer installmentMonths;

    @PositiveOrZero
    @DecimalMax("100.0")
    private Double interestRate;

    private InstallmentStatus status;
}