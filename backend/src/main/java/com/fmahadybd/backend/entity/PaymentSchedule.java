package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Builder
@Table(name = "payment_schedules")
@ToString(exclude = { "installment", "collectingAgent" })
@EqualsAndHashCode(exclude = { "installment", "collectingAgent" })
@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
public class PaymentSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "installment_id", nullable = false)
    @JsonBackReference("installment-payments")
    private Installment installment;


    @NotNull
    @PositiveOrZero
    @Column(nullable = false)
    private Double paidAmount = 0.00;



    @NotNull
    @PositiveOrZero
    @Column(nullable = false)
    private Double totalAmount ;

    @NotNull
    @PositiveOrZero
    @Column(nullable = false)
    private Double remainingAmount;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PaymentStatus status;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    @JsonIgnoreProperties({ "paymentSchedules", "installments", "members" })
    private Agent collectingAgent;

    private LocalDate paymentDate;
    private String notes;


    @Column(name = "created_time", nullable = false, updatable = false)
    private LocalDateTime createdTime;

    @Column(name = "updated_time")
    private LocalDateTime updatedTime;

}