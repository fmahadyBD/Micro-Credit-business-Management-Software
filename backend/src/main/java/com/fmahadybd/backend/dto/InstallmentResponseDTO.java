package com.fmahadybd.backend.dto;

import com.fmahadybd.backend.entity.Agent;
import com.fmahadybd.backend.entity.InstallmentStatus;
import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.entity.PaymentSchedule;
import com.fmahadybd.backend.entity.Product;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Installment response with all details")
public class InstallmentResponseDTO {
    
    @Schema(description = "Unique identifier", example = "1")
    private Long id;
    
    @Schema(description = "Product details", required = true)
    private Product product;
    
    @Schema(description = "Member information", required = true)
    private Member member;
    
    @Schema(description = "Total product amount", example = "50000.00", required = true)
    private Double totalAmountOfProduct;
    
    @Schema(description = "Additional costs", example = "500.00", required = true)
    private Double otherCost;
    
    @Schema(description = "Advance payment", example = "5000.00", required = true)
    private Double advanced_paid;
    
    @Schema(description = "Amount remaining to be paid", example = "52000.00")
    private Double needPaidAmount;
    
    @Schema(description = "Number of installment months", example = "12", required = true)
    private Integer installmentMonths;
    
    @Schema(description = "Interest rate percentage", example = "15.0", required = true)
    private Double interestRate;
    
    @Schema(description = "Installment status", example = "ACTIVE", required = true)
    private InstallmentStatus status;
    
    @Schema(description = "Image file paths")
    private List<String> imageFilePaths;
    
    @Schema(description = "Agent who provided the product", required = true)
    private Agent given_product_agent;
    
    @Schema(description = "Creation timestamp")
    private LocalDateTime createdTime;
    
    @Schema(description = "Payment schedules")
    private List<PaymentSchedule> paymentSchedules;
    
    @Schema(description = "Monthly payment amount")
    private Double monthlyInstallmentAmount;
    
    @Schema(description = "Total amount with interest")
    private Double totalAmountWithInterest;
}