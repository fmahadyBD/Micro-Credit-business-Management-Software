package com.fmahadybd.backend.dto;

import lombok.Data;

@Data
public class UpdateUserDTO {
    private String firstname;
    private String lastname;
    private String username;
    private String password;
    private String role;
    private String status;
    private Long referenceId;
}