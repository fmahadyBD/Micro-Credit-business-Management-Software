package com.fmahadybd.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.YearMonth;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShareholderEarningDTO {
    private Long id;
    private Long shareholderId;
    private String shareholderName;
    private String month; // Store as String for JSON compatibility
    private Double monthlyEarning;
    private String description;
    private LocalDate calculatedDate;
    
    // Helper method to get YearMonth
    public YearMonth getYearMonth() {
        return month != null ? YearMonth.parse(month) : null;
    }
    
    // Helper method to set YearMonth
    public void setYearMonth(YearMonth yearMonth) {
        this.month = yearMonth != null ? yearMonth.toString() : null;
    }
}