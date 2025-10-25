package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // User ID

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    @Column(nullable = false, unique = true, length = 50)
    private String username; // Login username

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters long")
    @Column(nullable = false)
    private String password; // Encrypted password

    @NotNull(message = "Role is required")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role; // ADMIN / AGENT / SHAREHOLDER

    @PositiveOrZero(message = "Reference ID must be zero or positive")
    private Long referenceId; // Links to Agent, Shareholder, etc.
    
    @NotBlank(message = "Status is required")
    @Pattern(regexp = "Active|Inactive", message = "Status must be either 'Active' or 'Inactive'")
    @Column(nullable = false, length = 10)
    private String status; // Active / Inactive
}
