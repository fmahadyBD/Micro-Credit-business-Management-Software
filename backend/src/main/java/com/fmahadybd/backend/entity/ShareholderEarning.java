package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.YearMonth;

import com.fasterxml.jackson.annotation.JsonIgnore;
@Entity
@Table(name = "shareholder_earnings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShareholderEarning {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shareholder_id", nullable = false)
    @JsonIgnore
    private Shareholder shareholder;
    
    @Column(nullable = false)
    private YearMonth month;
    
    @Column(nullable = false)
    private Double monthlyEarning;
    
    private String description;
    
    @Column(nullable = false)
    private LocalDate calculatedDate;
    
    @PrePersist
    protected void onCreate() {
        if (calculatedDate == null) {
            calculatedDate = LocalDate.now();
        }
    }
}