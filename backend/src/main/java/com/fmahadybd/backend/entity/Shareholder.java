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

    @Column(nullable = false, unique = true)
    private String email;

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
    @Builder.Default
    private Double investment = 0.0;

    @Column(name = "total_share")
    @Builder.Default
    private Integer totalShare = 0;
    
    @Column(name = "total_earnings", nullable = false)
    @Builder.Default
    private Double totalEarning = 0.0;

    @Column(name = "current_balance")
    @Builder.Default
    private Double currentBalance = 0.0;

    private String role;

    @Builder.Default
    private String status = "Active";

    @Column(name = "join_date")
    private LocalDate joinDate;

    @Column(name = "user_id", unique = true)
    private Long userId;

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