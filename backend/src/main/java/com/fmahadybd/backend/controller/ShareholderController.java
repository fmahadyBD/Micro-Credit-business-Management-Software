package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.dto.*;
import com.fmahadybd.backend.service.FinancialService;
import com.fmahadybd.backend.service.ShareholderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/shareholders")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Shareholders", description = "Shareholder management APIs")
public class ShareholderController {

    private final ShareholderService shareholderService;
    private final FinancialService financialService;

    @PostMapping
    @Operation(summary = "Create a new shareholder")
    public ResponseEntity<?> createShareholder(@Valid @RequestBody ShareholderCreateDTO shareholderDTO) {
        try {
            // 🔍 DEBUG: Log the incoming DTO
            System.out.println("📥 Received ShareholderCreateDTO:");
            System.out.println("   Name: " + shareholderDTO.getName());
            System.out.println("   Email: " + shareholderDTO.getEmail());
            System.out.println("   Investment: " + shareholderDTO.getInvestment());
            System.out.println("   TotalShare: " + shareholderDTO.getTotalShare());
            System.out.println("   TotalEarning: " + shareholderDTO.getTotalEarning());
            System.out.println("   CurrentBalance: " + shareholderDTO.getCurrentBalance());
            System.out.println("   Status: " + shareholderDTO.getStatus());

            ShareholderDTO saved = shareholderService.saveShareholder(shareholderDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace(); // Print full stack trace
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to create shareholder: " + e.getMessage()));
        }
    }

    @GetMapping
    @Operation(summary = "Get all shareholders", description = "Retrieve a list of all shareholders")
    @ApiResponse(responseCode = "200", description = "List of shareholders", content = @Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = ShareholderDTO.class))))
    public ResponseEntity<List<ShareholderDTO>> getAllShareholders() {
        try {
            List<ShareholderDTO> shareholders = shareholderService.getAllShareholders();
            return ResponseEntity.ok(shareholders);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(List.of());
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get shareholder by ID", responses = {
            @ApiResponse(responseCode = "200", description = "Shareholder found", content = @Content(mediaType = "application/json", schema = @Schema(implementation = ShareholderDTO.class))),
            @ApiResponse(responseCode = "404", description = "Shareholder not found")
    })
    public ResponseEntity<ShareholderDTO> getShareholderById(@PathVariable Long id) {
        return shareholderService.getShareholderById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update shareholder")
    public ResponseEntity<?> updateShareholder(@PathVariable Long id,
            @Valid @RequestBody ShareholderUpdateDTO shareholderDTO) {
        try {
            ShareholderDTO updated = shareholderService.updateShareholder(id, shareholderDTO);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to update shareholder: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete shareholder")
    public ResponseEntity<?> deleteShareholder(@PathVariable Long id) {
        try {
            shareholderService.deleteShareholder(id);
            return ResponseEntity.ok(Map.of("message", "Shareholder deleted successfully"));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to delete shareholder: " + e.getMessage()));
        }
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

    @GetMapping("/by-email/{email}")
    @Operation(summary = "Get shareholder by email", responses = {
            @ApiResponse(responseCode = "200", description = "Shareholder fetched successfully", content = @Content(mediaType = "application/json", schema = @Schema(implementation = ShareholderDTO.class))),
            @ApiResponse(responseCode = "404", description = "Shareholder not found")
    })
    public ResponseEntity<?> getShareholderByEmail(@PathVariable String email) {
        try {
            ShareholderDTO shareholder = shareholderService.getShareholderByEmail(email);
            return ResponseEntity.ok(shareholder);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch shareholder: " + e.getMessage()));
        }
    }

    // TODO: Need to
    @GetMapping("/{id}/details")
    @Operation(summary = "Get shareholder details", responses = {
            @ApiResponse(responseCode = "200", description = "Shareholder details fetched successfully", content = @Content(mediaType = "application/json", schema = @Schema(implementation = ShareholderDetailsDTO.class))),
            @ApiResponse(responseCode = "400", description = "Bad request"),
            @ApiResponse(responseCode = "404", description = "Shareholder not found")
    })
    public ResponseEntity<ShareholderDetailsDTO> getShareholderDetails(@PathVariable Long id) {
        ShareholderDetailsDTO details = shareholderService.getShareholderWithDetails(id);
        return ResponseEntity.ok(details);
    }

    @GetMapping("/{id}/dashboard")
    @Operation(summary = "Get shareholder dashboard", responses = @ApiResponse(responseCode = "200", description = "Shareholder dashboard data", content = @Content(mediaType = "application/json", schema = @Schema(implementation = ShareholderDashboardDTO.class))))
    public ResponseEntity<ShareholderDashboardDTO> getShareholderDashboard(@PathVariable Long id) {
        ShareholderDashboardDTO dashboard = shareholderService.getShareholderDashboard(id);
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/by-user/{userId}")
    @Operation(summary = "Get shareholder by user ID", responses = {
            @ApiResponse(responseCode = "200", description = "Shareholder fetched successfully", content = @Content(mediaType = "application/json", schema = @Schema(implementation = ShareholderDTO.class))),
            @ApiResponse(responseCode = "404", description = "Shareholder not found")
    })
    public ResponseEntity<?> getShareholderByUserId(@PathVariable Long userId) {
        try {
            ShareholderDTO shareholder = shareholderService.getShareholderByUserId(userId);
            return ResponseEntity.ok(shareholder);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch shareholder: " + e.getMessage()));
        }
    }

    @GetMapping("/active")
    @Operation(summary = "Get active shareholders")
    public ResponseEntity<?> getActiveShareholders() {
        try {
            List<ShareholderDTO> shareholders = shareholderService.getActiveShareholders();
            return ResponseEntity.ok(shareholders);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch active shareholders: " + e.getMessage()));
        }
    }

    @GetMapping("/inactive")
    @Operation(summary = "Get inactive shareholders")
    public ResponseEntity<?> getInactiveShareholders() {
        try {
            List<ShareholderDTO> shareholders = shareholderService.getInactiveShareholders();
            return ResponseEntity.ok(shareholders);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch inactive shareholders: " + e.getMessage()));
        }
    }

    @GetMapping("/statistics")
    @Operation(summary = "Get shareholder statistics")
    public ResponseEntity<?> getShareholderStatistics() {
        try {
            StatisticsDTO stats = shareholderService.getShareholderStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch statistics: " + e.getMessage()));
        }
    }

    // Add these methods to ShareholderController

    @PostMapping("/{id}/add-investment")
    @Operation(summary = "Add investment to existing shareholder")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Investment added successfully"),
            @ApiResponse(responseCode = "404", description = "Shareholder not found"),
            @ApiResponse(responseCode = "400", description = "Invalid input")
    })
    public ResponseEntity<?> addInvestment(
            @PathVariable Long id,
            @Valid @RequestBody AddInvestmentDTO investmentDTO) {
        try {
            // ✅ Set shareholderId from path variable BEFORE validation issues
            ShareholderDTO updated = shareholderService.addInvestment(id, investmentDTO);
            return ResponseEntity.ok(Map.of(
                    "message", "Investment added successfully",
                    "shareholder", updated));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to add investment: " + e.getMessage()));
        }
    }

    @GetMapping("/{id}/investment-history")
    @Operation(summary = "Get investment history for shareholder")
    public ResponseEntity<?> getInvestmentHistory(@PathVariable Long id) {
        try {
            List<InvestmentHistoryDTO> history = shareholderService.getInvestmentHistory(id);
            return ResponseEntity.ok(history);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch investment history: " + e.getMessage()));
        }
    }

    @GetMapping("/search")
    @Operation(summary = "Search shareholder by email or ID")
    public ResponseEntity<?> searchShareholder(
            @RequestParam(required = false) String email,
            @RequestParam(required = false) Long id) {
        try {
            if (email != null && !email.isEmpty()) {
                ShareholderDTO shareholder = shareholderService.getShareholderByEmail(email);
                return ResponseEntity.ok(shareholder);
            } else if (id != null) {
                return shareholderService.getShareholderById(id)
                        .map(ResponseEntity::ok)
                        .orElse(ResponseEntity.notFound().build());
            } else {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Please provide either email or id"));
            }
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Search failed: " + e.getMessage()));
        }
    }

}
