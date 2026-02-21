package com.fmahadybd.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "Transaction History DTO")
public class TransactionHistoryDTO {
    private Long id;

    @Schema(description = "Transaction type", example = "INVESTMENT")
    @NotBlank
    private String type;

    @Schema(description = "Amount involved in transaction")
    @Min(1)
    private Double amount;

    @Schema(description = "Optional description", example = "Investor added funds")
    private String description;

    private LocalDateTime timestamp;

    private Long shareholderId;
}
