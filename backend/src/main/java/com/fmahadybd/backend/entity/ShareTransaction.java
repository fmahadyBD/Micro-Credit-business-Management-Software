package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "share_transactions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShareTransaction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shareholder_id", nullable = false)
    private Shareholder shareholder;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionType type; // BUY or SELL
    
    @Column(nullable = false)
    private Integer shareQuantity;
    
    @Column(nullable = false)
    private Double sharePrice;
    
    @Column(nullable = false)
    private Double totalAmount;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionStatus status; // PENDING, COMPLETED, etc.
    
    private String notes;
    
    @Column(nullable = false)
    private LocalDateTime transactionDate;
    
    private LocalDateTime processedDate;
    
    private String processedBy;
    
    @PrePersist
    protected void onCreate() {
        if (transactionDate == null) {
            transactionDate = LocalDateTime.now();
        }
        if (status == null) {
            status = TransactionStatus.PENDING;
        }
        if (totalAmount == null && shareQuantity != null && sharePrice != null) {
            totalAmount = shareQuantity * sharePrice;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        if (status == TransactionStatus.COMPLETED && processedDate == null) {
            processedDate = LocalDateTime.now();
        }
    }
}