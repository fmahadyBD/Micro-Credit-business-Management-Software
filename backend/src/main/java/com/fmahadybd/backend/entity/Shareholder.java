package com.fmahadybd.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "shareholders")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Shareholder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String phone;
    private String nidCard;
    private String nominee;
    private String zila;
    private String house;
    private Double investment; // total invested amount
    private Integer totalShare; // total number of shares owned
    private Double earning; // current or total earnings
    private String role; // e.g. “Shareholder”
    private String status; // Active / Inactive
    private LocalDate joinDate; // date of investment
}
