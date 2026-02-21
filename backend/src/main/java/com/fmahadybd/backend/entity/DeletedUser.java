package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Getter
@Setter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "deleted_users")
public class DeletedUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Deleted record ID

    private Long originalUserId; // Original user ID

    private String username;
    private String password;
    private String role;
    private Long referenceId;
    private String status;

    private LocalDateTime deletedAt; // Time of deletion
}
