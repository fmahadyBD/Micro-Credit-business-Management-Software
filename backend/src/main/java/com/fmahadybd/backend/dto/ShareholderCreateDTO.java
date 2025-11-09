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
@Schema(description = "Shareholder creation DTO")
public class ShareholderCreateDTO {
    
    @NotBlank(message = "Name is required")
    @Schema(description = "Shareholder full name", example = "John Doe", required = true)
    private String name;
    
    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is required")
    @Schema(description = "Email address", example = "john.doe@example.com", required = true)
    private String email;
    
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
    
    @Builder.Default
    @Min(value = 0, message = "Investment cannot be negative")
    @Schema(description = "Total investment amount", example = "100000.0")
    private Double investment = 0.0;
    
    @Schema(description = "Role in organization", example = "Investor")
    private String role;
    
    @Builder.Default
    @Schema(description = "Status", example = "Active", allowableValues = {"Active", "Inactive"})
    private String status = "Active";
    
    @Schema(description = "Join date", example = "2023-01-15")
    private LocalDate joinDate;
}