package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

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
    
    @Column(nullable = false)
    private String name;
    
    @Column(unique = true)
    private String phone;
    
    @Column(name = "nid_card", unique = true)
    private String nidCard;
    
    private String nominee;
    
    private String zila;
    
    private String house;
    
    @Column(nullable = false)
    private Double investment = 0.0;
    
    @Column(name = "total_share")
    private Integer totalShare = 0;
    
    @Column(name = "total_earning")
    private Double totalEarning = 0.0;
    
    @Column(name = "current_balance")
    private Double currentBalance = 0.0;
    
    private String role;
    
    private String status = "Active"; 
    
    @Column(name = "join_date")
    private LocalDate joinDate;
    
  
    
    // Calculate ROI
    @Transient
    public Double getROI() {
        if (investment != null && investment > 0 && totalEarning != null) {
            return (totalEarning / investment) * 100;
        }
        return 0.0;
    }
    
    // Calculate total value
    @Transient
    public Double getTotalValue() {
        Double inv = investment != null ? investment : 0.0;
        Double earning = totalEarning != null ? totalEarning : 0.0;
        return inv + earning;
    }
}