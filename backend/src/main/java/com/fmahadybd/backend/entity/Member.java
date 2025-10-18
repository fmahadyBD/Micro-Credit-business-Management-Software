package com.fmahadybd.backend.entity;

import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "members")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String phone;
    private String zila;
    private String village;
    private String nidCard;
    private String photo;
    private String nominee;
    private LocalDate joinDate;

    @OneToMany(mappedBy = "member", cascade = CascadeType.ALL)
    private List<Product> products;

    @OneToMany(mappedBy = "member", cascade = CascadeType.ALL)
    private List<Installment> installments;

    @ManyToMany
    @JoinTable(
        name = "member_agents",
        joinColumns = @JoinColumn(name = "member_id"),
        inverseJoinColumns = @JoinColumn(name = "agent_id")
    )
    private List<Agent> agents;
}
