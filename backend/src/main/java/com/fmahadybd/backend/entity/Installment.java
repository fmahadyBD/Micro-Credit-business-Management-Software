package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Builder
@Table(name = "installments")
@ToString(exclude = { "product", "member", "given_product_agent", "paymentSchedules" })
@EqualsAndHashCode(exclude = { "product", "member", "given_product_agent", "paymentSchedules" })
@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
public class Installment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    @JsonIgnoreProperties({ "installments" })
    private Product product;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    @JsonBackReference("member-installments")
    private Member member;

    @NotNull
    @Positive
    @DecimalMin("0.01")
    @Column(nullable = false)
    private Double totalAmountOfProduct;

    @NotNull
    @PositiveOrZero
    @Column(nullable = false)
    private Double otherCost;

    @NotNull
    @PositiveOrZero
    @Column(nullable = false)
    private Double advanced_paid;

    @Column(nullable = false)
    private Double needPaidAmount;

    @NotNull
    @Min(1)
    @Max(60)
    @Column(nullable = false)
    private Integer installmentMonths;

    @NotNull
    @PositiveOrZero
    @DecimalMax("100.0")
    @Column(nullable = false)
    private Double interestRate = 15.0;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private InstallmentStatus status;

    @ElementCollection
    @CollectionTable(name = "installment_images", joinColumns = @JoinColumn(name = "installment_id"))
    @Column(name = "image_file_path")
    private List<String> imageFilePaths = new ArrayList<>();

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    @JsonIgnoreProperties({ "members", "installments" })
    private Agent given_product_agent;

    @Column(name = "created_time", nullable = false, updatable = false)
    private LocalDateTime createdTime;

    @OneToMany(mappedBy = "installment", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("installment-payments")
    private List<PaymentSchedule> paymentSchedules = new ArrayList<>();

    @Column(nullable = false)
    private Double totalRemainingAmount;

    @PrePersist
    @PreUpdate
    private void calculateAmounts() {
        Double totalWithInterest = totalAmountOfProduct
                + (totalAmountOfProduct * (interestRate != null ? interestRate : 15.0) / 100);
        Double calculatedNeedPaid = totalWithInterest + (otherCost != null ? otherCost : 0.0)
                - (advanced_paid != null ? advanced_paid : 0.0);

        this.needPaidAmount = Math.max(calculatedNeedPaid, 0.0);
        this.totalRemainingAmount = this.needPaidAmount;

        if (status == null)
            status = InstallmentStatus.PENDING;
        if (createdTime == null)
            createdTime = LocalDateTime.now();
        if (imageFilePaths == null)
            imageFilePaths = new ArrayList<>();
    }

    @Transient
    public Double getMonthlyInstallmentAmount() {
        if (installmentMonths == null || installmentMonths <= 0) return 0.0;
        if (needPaidAmount == null) return 0.0;
        return needPaidAmount / installmentMonths;
    }

    @AssertTrue(message = "Advanced payment cannot exceed total amount with interest")
    private boolean isAdvancedPaymentValid() {
        if (advanced_paid == null || totalAmountOfProduct == null) return true;
        Double totalWithInterest = getTotalAmountWithInterest() + (otherCost != null ? otherCost : 0.0);
        return advanced_paid <= totalWithInterest;
    }

    @AssertTrue(message = "Need paid amount should match calculation")
    private boolean isNeedPaidAmountValid() {
        if (needPaidAmount == null || totalAmountOfProduct == null) return true;
        Double expected = getTotalAmountWithInterest() + (otherCost != null ? otherCost : 0.0)
                - (advanced_paid != null ? advanced_paid : 0.0);
        return Math.abs(needPaidAmount - Math.max(expected, 0.0)) < 0.01;
    }

    public Double getTotalAmountWithInterest() {
        return totalAmountOfProduct + (totalAmountOfProduct * (interestRate != null ? interestRate : 15.0) / 100);
    }
}
