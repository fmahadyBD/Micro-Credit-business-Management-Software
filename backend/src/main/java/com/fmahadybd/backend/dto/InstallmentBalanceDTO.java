package com.fmahadybd.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InstallmentBalanceDTO {
    private Long installmentId;
    private Double totalAmount; // Total amount needed to pay
    private Double totalPaid;   // Total amount already paid
    private Double remainingBalance; // Remaining amount to pay
    private Integer totalPayments; // Number of payments made
    private String status;
}