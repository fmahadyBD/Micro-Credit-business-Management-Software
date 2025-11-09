package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "transaction_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String type; // INVESTMENT, WITHDRAWAL, PRODUCT_COST, MAINTENANCE, 
                         // INSTALLMENT_RETURN, ADVANCED_PAYMENT, INSTALLMENT_PAYMENT

    @Column(nullable = false)
    private Double amount;

    @Column(length = 500)
    private String description;

    @Column(name = "shareholder_id")
    private Long shareholderId; // For investment/withdrawal transactions

    @Column(name = "member_id")
    private Long memberId; // For installment-related transactions

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @PrePersist
    public void prePersist() {
        this.timestamp = LocalDateTime.now();
    }
}