package com.fmahadybd.backend.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "agents")
@ToString(exclude = {"members", "installments"})
@EqualsAndHashCode(exclude = {"members", "installments"})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Agent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String phone;

    @Column(unique = true)
    private String email;

    @Column(nullable = false)
    private String zila;

    @Column(nullable = false)
    private String village;

    @Column(name = "nid_card", nullable = false, unique = true)
    private String nidCard;

    private String photo;

    @Column(nullable = false)
    private String nominee;

    private String role = "Agent";
    private String status = "Active";

    @Column(name = "join_date")
    private LocalDateTime joinDate;

    @ManyToMany(mappedBy = "agents", fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"agents", "installments"})  // ✅ Correct - breaks Member cycle
    @Builder.Default
    private List<Member> members = new ArrayList<>();

    @OneToMany(mappedBy = "given_product_agent", fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"given_product_agent"})  // ✅ Correct - breaks Installment cycle
    @Builder.Default
    private List<Installment> installments = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (joinDate == null) joinDate = LocalDateTime.now();
        if (role == null) role = "Agent";
        if (status == null) status = "Active";
    }
}