package com.fmahadybd.backend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EarningsResponseDTO {
    private Double earnings; // Net earnings
    private Double totalEarningsFromInterest; // 15% interest earnings
    private Double totalRevenue; // Total income
    private Double totalExpenses; // Total costs
    private String message;
}