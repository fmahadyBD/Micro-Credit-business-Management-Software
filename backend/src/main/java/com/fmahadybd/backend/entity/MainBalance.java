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

    /** Money received from shareholders */
    @Min(0)
    @Column(nullable = false)
    private Double totalInvestment = 0.0;

    /** Total spent to purchase products */
    @Min(0)
    @Column(nullable = false)
    private Double totalProductCost = 0.0;

    /** Office/maintenance cost */
    @Min(0)
    @Column(nullable = false)
    private Double totalMaintenanceCost = 0.0;

    /** Customer installment return (including advanced payments) */
    @Min(0)
    @Column(nullable = false)
    private Double totalInstallmentReturn = 0.0;

    /** 15% interest earnings ONLY */
    @Min(0)
    @Column(nullable = false)
    private Double totalEarnings = 0.0;

    private LocalDateTime lastUpdated;

    @Column(name = "who_changed")
    private String whoChanged;

    private String reason;

    @PrePersist
    @PreUpdate
    public void updateTimestamp() {
        this.lastUpdated = LocalDateTime.now();
    }

    /** Total expense = product cost + maintenance */
    @Transient
    public Double getTotalExpenses() {
        return totalProductCost + totalMaintenanceCost;
    }

    /** Net profit = Only the 15% interest earnings */
    @Transient
    public Double getNetProfit() {
        return totalEarnings;
    }

    /** Validate that total balance matches the calculated balance */
    @Transient
    public boolean isBalanceValid() {
        Double calculatedBalance = totalInvestment + totalInstallmentReturn + totalEarnings - getTotalExpenses();
        return totalBalance.equals(calculatedBalance);
    }
}