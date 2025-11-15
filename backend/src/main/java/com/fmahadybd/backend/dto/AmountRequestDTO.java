package com.fmahadybd.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AmountRequestDTO {
    @NotNull(message = "Amount is required")
    @Min(value = 0, message = "Amount must be positive")
    private Double amount;

    private String description;

    private Long memberId; // For member-related transactions

    @NotBlank(message = "Performed by is required")
    private String performedBy;
}