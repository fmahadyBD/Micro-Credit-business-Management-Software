package com.fmahadybd.backend.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class EarningsResponseDTO {
    private Double totalEarnings;
    private Double thisMonthEarnings;
    private Double thisYearEarnings;
    private Double averageMonthlyEarnings;
}