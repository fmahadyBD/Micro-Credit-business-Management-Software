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
    @FutureOrPresent
    @Column(nullable = false)
    private LocalDate dueDate;

    @NotNull
    @Positive
    @Column(nullable = false)
    private Double monthlyAmount;

    @NotNull
    @PositiveOrZero
    @Column(nullable = false)
    private Double paidAmount;

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

    @OneToMany(mappedBy = "paymentSchedule", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties({ "paymentSchedule" })
    @Builder.Default
    private List<PaymentTransaction> paymentTransactions = new ArrayList<>();

    @Column(name = "created_time", nullable = false, updatable = false)
    private LocalDateTime createdTime;

    @Column(name = "updated_time")
    private LocalDateTime updatedTime;

    @PrePersist
    protected void onCreate() {
        this.createdTime = LocalDateTime.now();
        this.updatedTime = LocalDateTime.now();
        if (this.paidAmount == null)
            this.paidAmount = 0.0;
        if (this.remainingAmount == null)
            this.remainingAmount = this.monthlyAmount;
        if (this.status == null)
            this.status = PaymentStatus.PENDING;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedTime = LocalDateTime.now();
        calculateRemainingAmount();
        updatePaymentStatus();
    }

    public void calculateRemainingAmount() {
        this.remainingAmount = Math.max(this.monthlyAmount - this.paidAmount, 0.0);
    }

    public void updatePaymentStatus() {
        if (this.paidAmount >= this.monthlyAmount) {
            this.status = PaymentStatus.PAID;
            if (this.paymentDate == null)
                this.paymentDate = LocalDate.now();
        } else if (this.paidAmount > 0) {
            this.status = PaymentStatus.PARTIALLY_PAID;
        } else if (this.dueDate.isBefore(LocalDate.now())) {
            this.status = PaymentStatus.OVERDUE;
        } else {
            this.status = PaymentStatus.PENDING;
        }
    }

    public PaymentTransaction addPayment(Double amount, Agent agent, String notes) {
        PaymentTransaction transaction = PaymentTransaction.builder()
                .paymentSchedule(this)
                .amount(amount)
                .paidAmount(amount)
                .collectingAgent(agent)
                .paymentDate(LocalDate.now())
                .notes(notes)
                .paymentType(PaymentType.PAYMENT) // ✅ CHANGED: transactionType → paymentType
                .build();

        this.paidAmount += amount;
        this.collectingAgent = agent;
        this.notes = notes != null ? notes : this.notes;

        this.paymentTransactions.add(transaction);
        calculateRemainingAmount();
        updatePaymentStatus();

        return transaction;
    }

    public PaymentTransaction editPayment(Long transactionId, Double newAmount, Agent agent, String notes) {
        PaymentTransaction transaction = this.paymentTransactions.stream()
                .filter(t -> t.getId().equals(transactionId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Payment transaction not found"));

        Double difference = newAmount - transaction.getAmount();
        transaction.setAmount(newAmount);
        transaction.setPaidAmount(newAmount);
        transaction.setCollectingAgent(agent);
        transaction.setNotes(notes);
        transaction.setUpdatedTime(LocalDateTime.now());

        this.paidAmount += difference;
        this.collectingAgent = agent;
        this.notes = notes;

        calculateRemainingAmount();
        updatePaymentStatus();

        return transaction;
    }
}