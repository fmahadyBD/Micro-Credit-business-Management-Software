package com.fmahadybd.backend.dto;

import lombok.*;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductRequestDTO {
    private String name;
    private String category;
    private String description;
    private Double price;
    private Double costPrice;
    private Boolean isDeliveryRequired;
    private Long soldByAgentId;
    private Long whoRequestId;
}
