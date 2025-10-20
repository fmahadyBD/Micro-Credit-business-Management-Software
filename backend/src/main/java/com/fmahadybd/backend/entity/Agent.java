package com.fmahadybd.backend.entity;

import java.time.LocalDateTime;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "agents")
public class Agent {

   @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Name is mandatory")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    @Column(nullable = false)
    private String name;
    
    @NotBlank(message = "Phone is mandatory")
    @Size(min = 10, max = 15, message = "Phone must be between 10 and 15 characters")
    @Column(nullable = false, unique = true)
    private String phone;
    
    @Email(message = "Email should be valid")
    @Column(unique = true)
    private String email;
    
    @NotBlank(message = "District is mandatory")
    @Column(nullable = false)
    private String zila;
    
    @NotBlank(message = "Village is mandatory")
    @Column(nullable = false)
    private String village;
    
    @NotBlank(message = "NID card is mandatory")
    @Column(name = "nid_card", nullable = false, unique = true)
    private String nidCard;
    
    private String photo;

    @NotBlank(message = "Moninee is mandatory")
    private String nominee;
    
    private String role = "Agent";
    
    private String status = "Active";
    
    @Column(name = "join_date")
    private LocalDateTime joinDate; 
}