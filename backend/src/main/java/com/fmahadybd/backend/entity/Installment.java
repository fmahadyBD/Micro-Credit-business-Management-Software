package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

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
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    @JsonIgnoreProperties({ "installment" })
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

    // ✅ ADD THIS FIELD - Store monthly installment amount
    @Column(name = "monthly_installment_amount")
    private Double monthlyInstallmentAmount = 0.0;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private InstallmentStatus status;

    @ElementCollection
    @CollectionTable(name = "installment_images", joinColumns = @JoinColumn(name = "installment_id"))
    @Column(name = "image_file_path")
    @Builder.Default
    private List<String> imageFilePaths = new ArrayList<>();

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    @JsonIgnoreProperties({ "members", "installments" })
    private Agent given_product_agent;

    @CreationTimestamp
    @Column(name = "created_time", nullable = false, updatable = false)
    private LocalDateTime createdTime;

    @UpdateTimestamp
    @Column(name = "updated_time")
    private LocalDateTime updatedTime;

    @OneToMany(mappedBy = "installment", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("installment-payments") 
    @JsonIgnore 
    @Builder.Default
    private List<PaymentSchedule> paymentSchedules = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        // Ensure status is set
        if (status == null) {
            status = InstallmentStatus.PENDING;
        }
        
        // Ensure collections are initialized
        if (imageFilePaths == null) {
            imageFilePaths = new ArrayList<>();
        }
        if (paymentSchedules == null) {
            paymentSchedules = new ArrayList<>();
        }
    }

    @Transient
    public Double getTotalAmountWithInterest() {
        double safeTotal = totalAmountOfProduct != null ? totalAmountOfProduct : 0.0;
        double safeInterest = interestRate != null ? interestRate : 15.0;
        return safeTotal + (safeTotal * safeInterest / 100);
    }

    @Transient
    public Double getCalculatedTotalAmount() {
        return getTotalAmountWithInterest() + (otherCost != null ? otherCost : 0.0);
    }
}