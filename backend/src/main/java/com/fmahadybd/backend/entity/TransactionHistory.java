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

    private String type; // INVESTMENT, WITHDRAWAL, PRODUCT_COST, MAINTENANCE, INSTALLMENT_RETURN

    private Double amount;

    private String description;

    private LocalDateTime timestamp;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shareholder_id")
    private Shareholder shareholder; // optional link to investor

    @PrePersist
    public void prePersist() {
        this.timestamp = LocalDateTime.now();
    }
}
