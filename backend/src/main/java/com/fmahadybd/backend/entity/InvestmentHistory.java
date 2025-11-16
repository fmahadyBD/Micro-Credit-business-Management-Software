package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "investment_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvestmentHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "shareholder_id", nullable = false)
    private Long shareholderId;

    @Column(nullable = false)
    private Double amount;

    @Column(name = "investment_date", nullable = false)
    private LocalDateTime investmentDate;

    @Column(length = 500)
    private String description;

    @Column(name = "performed_by")
    private String performedBy;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}