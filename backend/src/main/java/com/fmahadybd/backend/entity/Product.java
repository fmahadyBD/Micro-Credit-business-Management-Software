package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "products")
@ToString(exclude = {"installment"})
@EqualsAndHashCode(exclude = {"installment"})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@JsonInclude(JsonInclude.Include.ALWAYS)
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String category;
    private String description;
    private Double price;
    private Double costPrice;

    @Transient
    private Double totalPrice;

    private Boolean isDeliveryRequired = false;
    private LocalDate dateAdded;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sold_by_agent_id")
    @JsonIgnoreProperties({"members", "installments"})
    private Agent soldByAgent;

    // <-- CHANGE HERE: allow multiple products per member
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "who_request_member_id")
    private Member whoRequest;

    @OneToOne(mappedBy = "product", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"product"})
    private Installment installment;

    @ElementCollection
    private java.util.List<String> imageFilePaths = new java.util.ArrayList<>();

    @PrePersist
    @PreUpdate
    private void calculateTotalPrice() {
        this.totalPrice = (price != null ? price : 0.0) + (costPrice != null ? costPrice : 0.0);
    }

    public Double getTotalPrice() {
        if (this.totalPrice == null) {
            calculateTotalPrice();
        }
        return this.totalPrice;
    }
}
