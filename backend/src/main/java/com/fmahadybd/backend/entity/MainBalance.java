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
    private Double totalBalance = 0.0;

    @Min(0)
    private Double totalInvestment = 0.0;

    @Min(0)
    private Double totalWithdrawal = 0.0;

    @Min(0)
    private Double totalProductCost = 0.0;

    @Min(0)
    private Double totalMaintenanceCost = 0.0;

    @Min(0)
    private Double totalInstallmentReturn = 0.0;

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
    public Double getEarnings() {
        return (totalInstallmentReturn + totalInvestment) - getTotalExpenses();
    }
}
