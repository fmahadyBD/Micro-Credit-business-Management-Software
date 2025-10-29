package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "products")
@ToString(exclude = {"installments"})
@EqualsAndHashCode(exclude = {"installments"})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String category;
    private String description;
    private Double price;
    private Double costPrice;
    private Integer stock;
    private String status;
    private Boolean isDeliveryRequired = false;
    private LocalDate dateAdded;
    private String addedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sold_by_agent_id")
    @JsonIgnoreProperties({"members", "installments"})
    private Agent soldByAgent;

    @ElementCollection
    private List<String> imageFilePaths = new ArrayList<>();

    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"product"})
    private List<Installment> installments = new ArrayList<>();
}