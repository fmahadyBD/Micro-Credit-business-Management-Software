package com.fmahadybd.backend.dto;

import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductResponseDTO {
    private Long id;
    private String name;
    private String category;
    private String description;
    private Double price;
    private Double costPrice;
    private Double totalPrice;
    private Boolean isDeliveryRequired;
    private LocalDate dateAdded;
    private List<String> imageFilePaths;
    private String soldByAgentName;
    private String whoRequestName;
}
