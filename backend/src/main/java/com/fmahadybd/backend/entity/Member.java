package com.fmahadybd.backend.entity;

import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Entity
@Table(name = "members")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Name is mandatory")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    @Column(nullable = false)
    private String name;

    @NotBlank(message = "Phone is mandatory")
    @Size(min = 10, max = 15, message = "Phone must be between 10 and 15 characters")
    @Column(nullable = false, unique = true)
    private String phone;

    @NotBlank(message = "District (zila) is mandatory")
    private String zila;

    @NotBlank(message = "Village is mandatory")
    private String village;

    @NotBlank(message = "NID card is mandatory")
    @Column(nullable = false, unique = true)
    private String nidCard;

    private String photo;

    @NotBlank(message = "Nominee is mandatory")
    private String nominee;

    private LocalDate joinDate;

    // ✅ New field for status
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MemberStatus status = MemberStatus.ACTIVE;

    @ManyToMany
    @JoinTable(
        name = "member_agents",
        joinColumns = @JoinColumn(name = "member_id"),
        inverseJoinColumns = @JoinColumn(name = "agent_id")
    )
    private List<Agent> agents;

    @OneToMany(mappedBy = "member", cascade = CascadeType.ALL)
    private List<Installment> installments;
}
