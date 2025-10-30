package com.fmahadybd.backend.entity;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "members")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = {"agents", "installments"})
@EqualsAndHashCode(exclude = {"agents", "installments"})
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank @Size(min = 2, max = 100)
    @Column(nullable = false)
    private String name;

    @NotBlank @Size(min = 10, max = 15)
    @Column(nullable = false, unique = true)
    private String phone;

    @NotBlank private String zila;
    @NotBlank private String village;

    @NotBlank @Column(nullable = false, unique = true)
    private String nidCardNumber;

    @Column(name = "nid_card_image_path")
    private String nidCardImagePath;

    @Column(name = "photo_path")
    private String photoPath;

    @NotBlank private String nomineeName;
    @NotBlank private String nomineePhone;

    @NotBlank @Column(name = "nominee_nid_card_number")
    private String nomineeNidCardNumber;

    @Column(name = "nominee_nid_card_image_path")
    private String nomineeNidCardImagePath;

    private LocalDate joinDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MemberStatus status = MemberStatus.ACTIVE;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "member_agents",
        joinColumns = @JoinColumn(name = "member_id"),
        inverseJoinColumns = @JoinColumn(name = "agent_id")
    )
    @JsonIgnoreProperties({"members", "installments"})
    @Builder.Default
    private List<Agent> agents = new ArrayList<>();

    @OneToMany(mappedBy = "member", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    @JsonManagedReference("member-installments")
    @Builder.Default
    private List<Installment> installments = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (joinDate == null) joinDate = LocalDate.now();
        if (status == null) status = MemberStatus.ACTIVE;
    }
}
