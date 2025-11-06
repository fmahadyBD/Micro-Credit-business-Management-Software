package com.fmahadybd.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Dashboard metrics DTO")
public class DashboardMetricsDTO {
    
    @Schema(description = "ROI percentage")
    private Double roiPercentage;
    
    @Schema(description = "Monthly average earning")
    private Double monthlyAverageEarning;
    
    @Schema(description = "Months active")
    private Long monthsActive;
    
    @Schema(description = "Total value")
    private Double totalValue;
}
