package com.fmahadybd.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Shareholder update DTO")
public class ShareholderUpdateDTO {


    @Schema(description = "Shareholder full name", example = "John Doe")
    private String name;
    
    @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "Invalid phone number format")
    @Schema(description = "Phone number", example = "+1234567890")
    private String phone;
    
    @Schema(description = "National ID card number", example = "1234567890123")
    private String nidCard;
    
    @Schema(description = "Nominee name", example = "Jane Doe")
    private String nominee;
    
    @Schema(description = "District", example = "Dhaka")
    private String zila;
    
    @Schema(description = "House address", example = "123 Main Street")
    private String house;
    
    @Min(value = 0, message = "Investment cannot be negative")
    @Schema(description = "Total investment amount", example = "100000.0")
    private Double investment;
    
    @Min(value = 0, message = "Total share cannot be negative")
    @Schema(description = "Total number of shares", example = "100")
    private Integer totalShare;
    
    @Min(value = 0, message = "Total earning cannot be negative")
    @Schema(description = "Total earnings", example = "15000.0")
    private Double totalEarning;
    
    @Min(value = 0, message = "Current balance cannot be negative")
    @Schema(description = "Current balance", example = "5000.0")
    private Double currentBalance;
    
    @Schema(description = "Role in organization", example = "Investor")
    private String role;
    
    @Schema(description = "Status", example = "Active", allowableValues = {"Active", "Inactive"})
    private String status;
    
    @Schema(description = "Join date", example = "2023-01-15")
    private LocalDate joinDate;
}