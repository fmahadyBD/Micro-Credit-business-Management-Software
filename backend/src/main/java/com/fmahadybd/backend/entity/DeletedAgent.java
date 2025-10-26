package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "deleted_agents")
public class DeletedAgent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long originalAgentId;
    private String name;
    private String phone;
    private String email;
    private String zila;
    private String village;
    private String nidCard;
    private String photo;
    private String nominee;
    private String role;
    private String status;
    private LocalDateTime joinDate;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}
