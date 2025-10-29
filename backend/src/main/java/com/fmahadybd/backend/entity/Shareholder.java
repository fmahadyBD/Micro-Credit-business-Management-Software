package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "shareholders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Shareholder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String phone;
    private String nidCard;
    private String nominee;
    private String zila;
    private String house;
    
    @Column(nullable = false)
    @Builder.Default
    private Double investment = 0.0;
    
    @Column(nullable = false)
    @Builder.Default
    private Integer totalShare = 0;
    
    @Column(nullable = false)
    @Builder.Default
    private Double totalEarning = 0.0;
    
    @Column(nullable = false)
    @Builder.Default
    private Double currentBalance = 0.0;
    
    private String role;
    
    @Builder.Default
    private String status = "Active";
    
    private LocalDate joinDate;

    @OneToMany(mappedBy = "shareholder", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    @JsonIgnore // Add this to prevent circular reference
    private List<ShareholderEarning> earnings = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (joinDate == null) {
            joinDate = LocalDate.now();
        }
    }
}