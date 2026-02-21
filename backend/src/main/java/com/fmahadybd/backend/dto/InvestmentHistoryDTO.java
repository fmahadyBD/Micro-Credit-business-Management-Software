package com.fmahadybd.backend.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InvestmentHistoryDTO {
    private Long id;
    private Long shareholderId;
    private Double amount;
    private LocalDateTime investmentDate;
    private String description;
    private String performedBy;
    private LocalDateTime createdAt;
}