package com.fmahadybd.backend.entity;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

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

    @NotBlank(message = "NID card number is mandatory")
    @Column(nullable = false, unique = true)
    private String nidCardNumber;

    @Column(name = "nid_card_image_path")
    private String nidCardImagePath;

    @Column(name = "photo_path")
    private String photoPath;

    @NotBlank(message = "Nominee name is mandatory")
    private String nomineeName;

    @NotBlank(message = "Nominee phone is mandatory")
    private String nomineePhone;

    @NotBlank(message = "Nominee NID card number is mandatory")
    @Column(name = "nominee_nid_card_number")
    private String nomineeNidCardNumber;

    @Column(name = "nominee_nid_card_image_path")
    private String nomineeNidCardImagePath;

    private LocalDate joinDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MemberStatus status = MemberStatus.ACTIVE;

    /** Many-to-Many with Agents */
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "member_agents",
        joinColumns = @JoinColumn(name = "member_id"),
        inverseJoinColumns = @JoinColumn(name = "agent_id")
    )
    @JsonIgnoreProperties({"members", "installments"})
    @Builder.Default
    private List<Agent> agents = new ArrayList<>();

    /** One-to-Many with Installments */
    @OneToMany(mappedBy = "member", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    @JsonManagedReference("member-installments")
    @Builder.Default
    private List<Installment> installments = new ArrayList<>();

    /** Set default values before persisting */
    @PrePersist
    protected void onCreate() {
        if (joinDate == null) joinDate = LocalDate.now();
        if (status == null) status = MemberStatus.ACTIVE;
    }
}