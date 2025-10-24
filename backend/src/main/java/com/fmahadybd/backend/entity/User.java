package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // User ID

    private String username; // Login username
    private String password; // Encrypted password

    @Enumerated(EnumType.STRING)
    private Role role; // ADMIN / AGENT / SHAREHOLDER

    private Long referenceId; // Links to Agent, Shareholder, etc.
    
    private String status; // Active / Inactive
}
