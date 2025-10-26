package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "deleted_members")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DeletedMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long originalMemberId;
    private String name;
    private String phone;
    private String zila;
    private String village;
    private String nidCard;
    private String photo;
    private String nominee;
    private LocalDate joinDate;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}
