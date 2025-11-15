package com.fmahadybd.backend.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class TransactionHistoryResponseDTO {
    private Long id;
    private String type;
    private Double amount;
    private String description;
    private Long shareholderId;
    private String shareholderName;
    private Long memberId;
    private String memberName;
    private LocalDateTime timestamp;
}