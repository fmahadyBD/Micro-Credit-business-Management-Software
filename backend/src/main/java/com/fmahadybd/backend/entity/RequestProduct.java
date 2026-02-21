package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "request_products")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RequestProduct {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Request ID

    private String productName; // Requested product name
    private Integer quantity; // Requested amount

    // Agent who made the request
    @ManyToOne
    @JoinColumn(name = "agent_id", nullable = false)
    private Agent agent;

    // Optional member who requested (can be null)
    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    private LocalDate requestDate; // Date requested
    private String status; // Pending / Approved / Rejected
    private String approvedBy; // Admin who approved
}

