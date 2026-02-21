package com.fmahadybd.backend.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class UserDTO {
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