package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "main_balance")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MainBalance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Min(0)
    @Column(nullable = false)
    private Double totalBalance = 0.0;

    @Min(0)
    @Column(nullable = false)
    private Double totalInvestment = 0.0;

    @Min(0)
    @Column(nullable = false)
    private Double totalWithdrawal = 0.0;

    @Min(0)
    @Column(nullable = false)
    private Double totalProductCost = 0.0;

    @Min(0)
    @Column(nullable = false)
    private Double totalMaintenanceCost = 0.0;

    @Min(0)
    @Column(nullable = false)
    private Double totalInstallmentReturn = 0.0;

    @Min(0)
    @Column(nullable = false)
    private Double totalEarnings = 0.0; // 15% earnings tracked separately

    private LocalDateTime lastUpdated;

    @PrePersist
    @PreUpdate
    public void updateTimestamp() {
        this.lastUpdated = LocalDateTime.now();
    }

    @Transient
    public Double getTotalExpenses() {
        return (totalProductCost + totalMaintenanceCost + totalWithdrawal);
    }

    @Transient
    public Double getNetProfit() {
        // Net profit = Total earnings from interest
        return totalEarnings;
    }

    @Transient
    public Double getTotalRevenue() {
        // Total money coming in
        return totalInvestment + totalInstallmentReturn;
    }
}