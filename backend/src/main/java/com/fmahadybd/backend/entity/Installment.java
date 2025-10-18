package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "installments")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Installment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Installment ID

    // Many installments can belong to one product
    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    // Many installments can belong to one member
    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    private Double totalAmount; // Total payable amount
    private Double paidAmount; // Amount paid so far
    private Double dueAmount; // Remaining balance
    private Integer installmentMonths; // Duration (e.g., 12 months)
    private LocalDate nextPaymentDate; // Next due date
    private String status; // Running / Completed / Overdue
}