package com.fmahadybd.backend.dto;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fmahadybd.backend.entity.PaymentStatus;
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentScheduleResponseDTO {
    
    private Long id;
    private Long installmentId;
    private String memberName;
    private String memberPhone;
    private Double paidAmount;
    private Double totalAmount;
    private Double remainingAmount;
    private PaymentStatus status;
    private String agentName;
    private Long agentId;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate paymentDate;
    
    private String notes;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedTime;
    
    // Additional helpful fields for frontend
    private Double previousRemainingAmount;
    private Boolean isFullyPaid;
    private Integer totalPaymentsMade;
}