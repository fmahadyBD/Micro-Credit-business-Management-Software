package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = "installments")
@EqualsAndHashCode(exclude = "installments")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Product ID

    private String name; // Product name
    private String category; // Product category/type
    private String description; // Short details about the product
    private Double price; // Total price
    private Double costPrice; // Company cost price
    private Integer stock; // Quantity in stock
    private String status; // Available / Sold / On Installment
    private String addedBy; // Agent or Admin who added the product
    private LocalDate dateAdded; // Date product added

    // One product can have multiple installment plans
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Installment> installments = new ArrayList<>();
}
