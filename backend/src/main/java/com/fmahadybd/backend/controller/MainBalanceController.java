package com.fmahadybd.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fmahadybd.backend.dto.AmountRequestDTO;
import com.fmahadybd.backend.dto.EarningsResponseDTO;
import com.fmahadybd.backend.dto.ErrorResponseDTO;
import com.fmahadybd.backend.dto.InvestmentRequestDTO;
import com.fmahadybd.backend.dto.MainBalanceResponseDTO;
import com.fmahadybd.backend.dto.TransactionHistoryResponseDTO;
import com.fmahadybd.backend.dto.WithdrawalRequestDTO;
import com.fmahadybd.backend.service.MainBalanceService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/main-balance")
@RequiredArgsConstructor
@Tag(name = "Main Balance Management", description = "APIs for managing the main balance of microcredit system")
public class MainBalanceController {

    private final MainBalanceService mainBalanceService;

    // 📊 Get current balance
    @GetMapping
    @Operation(summary = "Get current main balance", description = "Fetches the current main balance with all totals")
    @ApiResponse(responseCode = "200", description = "Main balance retrieved successfully",
            content = @Content(schema = @Schema(implementation = MainBalanceResponseDTO.class)))
    public ResponseEntity<MainBalanceResponseDTO> getBalance() {
        MainBalanceResponseDTO balance = mainBalanceService.getBalance();
        return ResponseEntity.ok(balance);
    }

    // 💰 Add Investment
    @PostMapping("/investment")
    @Operation(summary = "Add investment", description = "Adds investment from a shareholder to main balance")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Investment added successfully",
                    content = @Content(schema = @Schema(implementation = MainBalanceResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request data",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<MainBalanceResponseDTO> addInvestment(
            @Valid @RequestBody InvestmentRequestDTO request) {
        try {
            MainBalanceResponseDTO response = mainBalanceService.addInvestment(
                    request.getAmount(), 
                    request.getShareholderId()
            );
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Failed to add investment: " + e.getMessage());
        }
    }

    // 💸 Withdraw from main balance
    @PostMapping("/withdraw")
    @Operation(summary = "Withdraw funds", description = "Allows investor to withdraw money from main balance")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Withdrawal successful",
                    content = @Content(schema = @Schema(implementation = MainBalanceResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Insufficient funds or invalid request",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<MainBalanceResponseDTO> withdraw(
            @Valid @RequestBody WithdrawalRequestDTO request) {
        try {
            MainBalanceResponseDTO response = mainBalanceService.withdraw(
                    request.getAmount(), 
                    request.getShareholderId()
            );
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Withdrawal failed: " + e.getMessage());
        }
    }

    // 💵 Add Installment Return
    @PostMapping("/installment-return")
    @Operation(summary = "Add installment return", description = "Records installment payment received from borrowers")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Installment return added successfully",
                    content = @Content(schema = @Schema(implementation = MainBalanceResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request data",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<MainBalanceResponseDTO> addInstallmentReturn(
            @Valid @RequestBody AmountRequestDTO request) {
        try {
            MainBalanceResponseDTO response = mainBalanceService.addInstallmentReturn(request.getAmount());
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Failed to add installment: " + e.getMessage());
        }
    }

    // 🛒 Add Product Cost
    @PostMapping("/product-cost")
    @Operation(summary = "Add product cost", description = "Records product purchase expenses")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Product cost added successfully",
                    content = @Content(schema = @Schema(implementation = MainBalanceResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request data",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<MainBalanceResponseDTO> addProductCost(
            @Valid @RequestBody AmountRequestDTO request) {
        try {
            MainBalanceResponseDTO response = mainBalanceService.addProductCost(request.getAmount());
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Failed to add product cost: " + e.getMessage());
        }
    }

    // 🔧 Add Maintenance Cost
    @PostMapping("/maintenance-cost")
    @Operation(summary = "Add maintenance cost", description = "Records system maintenance expenses")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Maintenance cost added successfully",
                    content = @Content(schema = @Schema(implementation = MainBalanceResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request data",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<MainBalanceResponseDTO> addMaintenanceCost(
            @Valid @RequestBody AmountRequestDTO request) {
        try {
            MainBalanceResponseDTO response = mainBalanceService.addMaintenanceCost(request.getAmount());
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Failed to add maintenance cost: " + e.getMessage());
        }
    }

    // 📈 Calculate Investor Earnings
    @GetMapping("/earnings")
    @Operation(summary = "Calculate investor earnings", description = "Calculates total earnings for investors")
    @ApiResponse(responseCode = "200", description = "Earnings calculated successfully",
            content = @Content(schema = @Schema(implementation = EarningsResponseDTO.class)))
    public ResponseEntity<EarningsResponseDTO> calculateEarnings() {
        EarningsResponseDTO earnings = mainBalanceService.calculateInvestorEarnings();
        return ResponseEntity.ok(earnings);
    }

    // 📜 Get Transaction History
    @GetMapping("/transactions")
    @Operation(summary = "Get all transactions", description = "Fetches all transaction history records")
    @ApiResponse(responseCode = "200", description = "Transaction history retrieved successfully",
            content = @Content(schema = @Schema(implementation = TransactionHistoryResponseDTO.class)))
    public ResponseEntity<List<TransactionHistoryResponseDTO>> getAllTransactions() {
        List<TransactionHistoryResponseDTO> transactions = mainBalanceService.getAllTransactions();
        return ResponseEntity.ok(transactions);
    }
}