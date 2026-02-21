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
@Schema(description = "Shareholder dashboard DTO")
public class ShareholderDashboardDTO {
    
    @Schema(description = "Basic shareholder information")
    private ShareholderDTO basicInfo;
    
    @Schema(description = "Performance metrics")
    private DashboardMetricsDTO performanceMetrics;
}