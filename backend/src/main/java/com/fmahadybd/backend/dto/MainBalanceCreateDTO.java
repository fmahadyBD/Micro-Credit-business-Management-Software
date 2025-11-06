package com.fmahadybd.backend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MainBalanceCreateDTO {
    private Double amount;
    private String description;
}
