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
    
    // Updated fields to match new Member entity
    @Column(name = "nid_card_number")
    private String nidCardNumber;
    
    @Column(name = "nid_card_image_path")
    private String nidCardImagePath;
    
    @Column(name = "photo_path")
    private String photoPath;
    
    // Nominee information
    @Column(name = "nominee_name")
    private String nomineeName;
    
    @Column(name = "nominee_phone")
    private String nomineePhone;
    
    @Column(name = "nominee_nid_card_number")
    private String nomineeNidCardNumber;
    
    @Column(name = "nominee_nid_card_image_path")
    private String nomineeNidCardImagePath;
    
    private LocalDate joinDate;
    
    // Status field
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private MemberStatus status;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}