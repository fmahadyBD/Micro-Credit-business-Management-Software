package com.fmahadybd.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionHistoryResponseDTO {
    private Long id;
    private String type;
    private Double amount;
    private String description;
    private LocalDateTime timestamp;
    private Long shareholderId;
    private String shareholderName;
}