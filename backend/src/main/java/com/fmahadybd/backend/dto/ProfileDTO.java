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
public class ProfileDTO {
    private Long id;
    private String firstname;
    private String lastname;
    private String username;
    private String role;
    private String status;
    private Long referenceId;
    private LocalDateTime createdDate;
    private LocalDateTime lastModifiedDate;
}

