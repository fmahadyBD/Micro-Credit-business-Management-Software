package com.fmahadybd.backend.dto;

import com.fmahadybd.backend.entity.Role;
import com.fmahadybd.backend.entity.UserStatus;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDTO {
    private Long id;
    private String firstname;
    private String lastname;
    private String username;
    private Role role;
    private UserStatus status;
}
