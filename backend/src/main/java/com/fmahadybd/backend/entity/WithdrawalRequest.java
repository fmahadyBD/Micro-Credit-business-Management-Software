package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "withdrawal_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WithdrawalRequest {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shareholder_id", nullable = false)
    private Shareholder shareholder;
    
    @Column(nullable = false)
    private Double amount;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private WithdrawalStatus status; // PENDING, APPROVED, etc.
    
    private String reason;
    
    @Column(nullable = false)
    private LocalDateTime requestDate;
    
    private LocalDateTime processedDate;
    
    private String processedBy;
    
    private String rejectionReason;
    
    @PrePersist
    protected void onCreate() {
        if (requestDate == null) {
            requestDate = LocalDateTime.now();
        }
        if (status == null) {
            status = WithdrawalStatus.PENDING;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        if ((status == WithdrawalStatus.APPROVED || status == WithdrawalStatus.REJECTED || 
             status == WithdrawalStatus.PROCESSED) && processedDate == null) {
            processedDate = LocalDateTime.now();
        }
    }
}