package com.fmahadybd.backend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InstallmentBalanceDTO {
    private Long installmentId;
    private Double totalAmount;
    private Double totalPaid;
    private Double remainingBalance;
    private Integer totalPayments;
    private String status;
    private Double monthlyAmount; // Added monthly amount
}