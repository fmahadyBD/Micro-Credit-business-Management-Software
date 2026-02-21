package com.fmahadybd.backend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MainBalanceUpdateDTO {
    private Double amount;
    private String description;
}
