package com.fmahadybd.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fmahadybd.backend.dto.AmountRequestDTO;
import com.fmahadybd.backend.dto.EarningsResponseDTO;
import com.fmahadybd.backend.dto.ErrorResponseDTO;
import com.fmahadybd.backend.dto.FinancialReport;
import com.fmahadybd.backend.dto.InvestmentRequestDTO;
import com.fmahadybd.backend.dto.MainBalanceResponseDTO;
import com.fmahadybd.backend.dto.ShareholderDTO;
import com.fmahadybd.backend.dto.TransactionHistoryResponseDTO;
import com.fmahadybd.backend.dto.WithdrawalRequestDTO;
import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.entity.TransactionHistory;
import com.fmahadybd.backend.repository.TransactionHistoryRepository;
import com.fmahadybd.backend.service.FinancialService;
import com.fmahadybd.backend.service.MemberService;
import com.fmahadybd.backend.service.ReportService;
import com.fmahadybd.backend.service.ShareholderService;

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

        private final FinancialService financialService;
        private final ReportService reportService;
        private final TransactionHistoryRepository transactionHistoryRepository;
        private final ShareholderService shareholderService;
        private final MemberService memberService;

        // 📊 Get current balance
        @GetMapping("/current")
        @Operation(summary = "Get current balance", description = "Fetches the current main balance details")
        @ApiResponse(responseCode = "200", description = "Balance retrieved successfully", content = @Content(schema = @Schema(implementation = MainBalanceResponseDTO.class)))
        public ResponseEntity<MainBalanceResponseDTO> getCurrentBalance() {
                MainBalance balance = financialService.getMainBalance();

                MainBalanceResponseDTO response = MainBalanceResponseDTO.builder()
                                .totalBalance(balance.getTotalBalance())
                                .totalInvestment(balance.getTotalInvestment())
                                .totalProductCost(balance.getTotalProductCost())
                                .totalMaintenanceCost(balance.getTotalMaintenanceCost())
                                .totalInstallmentReturn(balance.getTotalInstallmentReturn())
                                .totalEarnings(balance.getTotalEarnings())
                                .totalExpenses(balance.getTotalExpenses())
                                .netProfit(balance.getNetProfit())
                                .lastUpdated(balance.getLastUpdated())
                                .build();

                return ResponseEntity.ok(response);
        }

        // 💰 Add investment
        @PostMapping("/investment")
        @Operation(summary = "Add investment", description = "Adds investment from shareholders to main balance")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Investment added successfully"),
                        @ApiResponse(responseCode = "400", description = "Invalid input", content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
        })
        public ResponseEntity<String> addInvestment(@Valid @RequestBody InvestmentRequestDTO request) {
                financialService.addInvestment(request.getAmount(), request.getDescription(),
                                request.getShareholderId(), request.getPerformedBy());
                return ResponseEntity.ok("Investment added successfully");
        }

        // 💸 Add withdrawal
        // @PostMapping("/withdrawal")
        // @Operation(summary = "Add withdrawal", description = "Processes withdrawal
        // from main balance")
        // @ApiResponses({
        // @ApiResponse(responseCode = "200", description = "Withdrawal processed
        // successfully"),
        // @ApiResponse(responseCode = "400", description = "Insufficient balance or
        // invalid input", content = @Content(schema = @Schema(implementation =
        // ErrorResponseDTO.class)))
        // })
        // public ResponseEntity<String> addWithdrawal(@Valid @RequestBody
        // WithdrawalRequestDTO request) {
        // financialService.addWithdrawal(request.getAmount(), request.getDescription(),
        // request.getShareholderId(), request.getPerformedBy());
        // return ResponseEntity.ok("Withdrawal processed successfully");
        // }

        // 🏢 Add maintenance cost
        @PostMapping("/maintenance")
        @Operation(summary = "Add maintenance cost", description = "Adds maintenance/office cost to main balance")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Maintenance cost added successfully"),
                        @ApiResponse(responseCode = "400", description = "Insufficient balance or invalid input", content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
        })
        public ResponseEntity<String> addMaintenanceCost(@Valid @RequestBody AmountRequestDTO request) {
                financialService.addMaintenanceCost(request.getAmount(), request.getDescription(),
                                request.getPerformedBy());
                return ResponseEntity.ok("Maintenance cost added successfully");
        }

        // 💳 Add installment return
        @PostMapping("/installment-return")
        @Operation(summary = "Add installment return", description = "Adds customer installment return to main balance")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Installment return added successfully"),
                        @ApiResponse(responseCode = "400", description = "Invalid input", content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
        })
        public ResponseEntity<String> addInstallmentReturn(@Valid @RequestBody AmountRequestDTO request) {
                financialService.addInstallmentReturn(request.getAmount(), request.getDescription(),
                                request.getMemberId(), request.getPerformedBy());
                return ResponseEntity.ok("Installment return added successfully");
        }

        // 📈 Add earnings
        @PostMapping("/earnings")
        @Operation(summary = "Add earnings", description = "Adds 15% interest earnings to main balance")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Earnings added successfully"),
                        @ApiResponse(responseCode = "400", description = "Invalid input", content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
        })
        public ResponseEntity<String> addEarnings(@Valid @RequestBody AmountRequestDTO request) {
                financialService.addEarnings(request.getAmount(), request.getDescription(),
                                request.getPerformedBy());
                return ResponseEntity.ok("Earnings added successfully");
        }

        // 💰 Add advanced payment
        @PostMapping("/advanced-payment")
        @Operation(summary = "Add advanced payment", description = "Adds customer advanced payment to main balance")
        @ApiResponses({
                        @ApiResponse(responseCode = "200", description = "Advanced payment added successfully"),
                        @ApiResponse(responseCode = "400", description = "Invalid input", content = @Content(schema = @Schema(implementation = ErrorResponseDTO.class)))
        })
        public ResponseEntity<String> addAdvancedPayment(@Valid @RequestBody AmountRequestDTO request) {
                financialService.addAdvancedPayment(request.getAmount(), request.getDescription(),
                                request.getMemberId(), request.getPerformedBy());
                return ResponseEntity.ok("Advanced payment added successfully");
        }

        // 📊 Get earnings report
        @GetMapping("/earnings-report")
        @Operation(summary = "Get earnings report", description = "Fetches detailed earnings report")
        @ApiResponse(responseCode = "200", description = "Earnings report retrieved successfully", content = @Content(schema = @Schema(implementation = EarningsResponseDTO.class)))
        public ResponseEntity<EarningsResponseDTO> getEarningsReport() {
                MainBalance balance = financialService.getMainBalance();

                EarningsResponseDTO earningsReport = EarningsResponseDTO.builder()
                                .totalEarnings(balance.getTotalEarnings())
                                .thisMonthEarnings(0.0) // Implement logic to calculate this
                                .thisYearEarnings(0.0) // Implement logic to calculate this
                                .averageMonthlyEarnings(0.0) // Implement logic to calculate this
                                .build();

                return ResponseEntity.ok(earningsReport);
        }

        // 📜 Get Transaction History (ordered by newest first)
        @GetMapping("/transactions")
        @Operation(summary = "Get all transactions", description = "Fetches all transaction history records ordered by newest first")
        @ApiResponse(responseCode = "200", description = "Transaction history retrieved successfully", content = @Content(schema = @Schema(implementation = TransactionHistoryResponseDTO.class)))
        public ResponseEntity<List<TransactionHistoryResponseDTO>> getAllTransactions() {
                List<TransactionHistory> transactions = transactionHistoryRepository.findAllByOrderByTimestampDesc();

                List<TransactionHistoryResponseDTO> response = transactions.stream()
                                .map(this::mapToTransactionResponseDTO)
                                .toList();

                return ResponseEntity.ok(response);
        }

        // 📈 Generate Financial Report
        @GetMapping("/financial-report")
        @Operation(summary = "Generate financial report", description = "Generates comprehensive financial report")
        @ApiResponse(responseCode = "200", description = "Financial report generated successfully", content = @Content(schema = @Schema(implementation = FinancialReport.class)))
        public ResponseEntity<FinancialReport> generateFinancialReport() {
                FinancialReport report = reportService.generateFinancialReport();
                return ResponseEntity.ok(report);
        }

        // 🔍 Get transactions by type (ordered by newest first)
        @GetMapping("/transactions/type/{type}")
        @Operation(summary = "Get transactions by type", description = "Fetches transactions filtered by type")
        @ApiResponse(responseCode = "200", description = "Transactions retrieved successfully", content = @Content(schema = @Schema(implementation = TransactionHistoryResponseDTO.class)))
        public ResponseEntity<List<TransactionHistoryResponseDTO>> getTransactionsByType(@PathVariable String type) {
                List<TransactionHistory> transactions = transactionHistoryRepository
                                .findByTypeOrderByTimestampDesc(type);

                List<TransactionHistoryResponseDTO> response = transactions.stream()
                                .map(this::mapToTransactionResponseDTO)
                                .toList();

                return ResponseEntity.ok(response);
        }

        // 👤 Get transactions by shareholder (ordered by newest first)
        @GetMapping("/transactions/shareholder/{shareholderId}")
        @Operation(summary = "Get transactions by shareholder", description = "Fetches transactions for specific shareholder")
        @ApiResponse(responseCode = "200", description = "Transactions retrieved successfully", content = @Content(schema = @Schema(implementation = TransactionHistoryResponseDTO.class)))
        public ResponseEntity<List<TransactionHistoryResponseDTO>> getTransactionsByShareholder(
                        @PathVariable Long shareholderId) {
                List<TransactionHistory> transactions = transactionHistoryRepository
                                .findByShareholderIdOrderByTimestampDesc(shareholderId);

                List<TransactionHistoryResponseDTO> response = transactions.stream()
                                .map(this::mapToTransactionResponseDTO)
                                .toList();

                return ResponseEntity.ok(response);
        }

        // 👥 Get transactions by member (ordered by newest first)
        @GetMapping("/transactions/member/{memberId}")
        @Operation(summary = "Get transactions by member", description = "Fetches transactions for specific member")
        @ApiResponse(responseCode = "200", description = "Transactions retrieved successfully", content = @Content(schema = @Schema(implementation = TransactionHistoryResponseDTO.class)))
        public ResponseEntity<List<TransactionHistoryResponseDTO>> getTransactionsByMember(
                        @PathVariable Long memberId) {
                List<TransactionHistory> transactions = transactionHistoryRepository
                                .findByMemberIdOrderByTimestampDesc(memberId);

                List<TransactionHistoryResponseDTO> response = transactions.stream()
                                .map(this::mapToTransactionResponseDTO)
                                .toList();

                return ResponseEntity.ok(response);
        }

        // 📅 Get transactions by date range (ordered by newest first)
        @GetMapping("/transactions/date-range")
        @Operation(summary = "Get transactions by date range", description = "Fetches transactions within specific date range")
        @ApiResponse(responseCode = "200", description = "Transactions retrieved successfully", content = @Content(schema = @Schema(implementation = TransactionHistoryResponseDTO.class)))
        public ResponseEntity<List<TransactionHistoryResponseDTO>> getTransactionsByDateRange(
                        @jakarta.validation.constraints.NotNull String startDate,
                        @jakarta.validation.constraints.NotNull String endDate) {
                // You'll need to parse the dates from String to LocalDateTime
                // This is a simplified version - you might want to use @RequestParam with
                // proper date parsing
                // List<TransactionHistory> transactions =
                // transactionHistoryRepository.findByTimestampBetweenOrderByTimestampDesc(start,
                // end);

                // For now, return empty list - implement date parsing as needed
                List<TransactionHistoryResponseDTO> response = List.of();
                return ResponseEntity.ok(response);
        }

        // Helper method to map TransactionHistory to TransactionHistoryResponseDTO
        private TransactionHistoryResponseDTO mapToTransactionResponseDTO(TransactionHistory transaction) {

          String memberName = null;
          String shareholderName = null;

          if(transaction.getMemberId() !=null){
                memberName = memberService.getMemberById(transaction.getMemberId())
                                .map(Member::getName)
                                .orElse(null);
          }

          if(transaction.getShareholderId()!=null){
                shareholderName = shareholderService.getShareholderById(transaction.getShareholderId())
                .map(ShareholderDTO::getName)
                .orElse(null);
          }



                return TransactionHistoryResponseDTO.builder()
                                .id(transaction.getId())
                                .type(transaction.getType())
                                .amount(transaction.getAmount())
                                .description(transaction.getDescription())
                                .shareholderId(transaction.getShareholderId())
                                .memberId(transaction.getMemberId())
                                .memberName(memberName)
                                .shareholderName(shareholderName)
                                .timestamp(transaction.getTimestamp())
                                .build();
        }
}