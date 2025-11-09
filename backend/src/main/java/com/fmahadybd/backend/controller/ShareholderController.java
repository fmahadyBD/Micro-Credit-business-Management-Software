package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.dto.*;
import com.fmahadybd.backend.service.ShareholderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
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

    @PostMapping
    @Operation(summary = "Create a new shareholder")
    public ResponseEntity<?> createShareholder(@Valid @RequestBody ShareholderCreateDTO shareholderDTO) {
        try {
            ShareholderDTO saved = shareholderService.saveShareholder(shareholderDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
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
    @Operation(summary = "Get shareholder dashboard",
        responses = @ApiResponse(
            responseCode = "200",
            description = "Shareholder dashboard data",
            content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = ShareholderDashboardDTO.class))
        )
    )
    public ResponseEntity<ShareholderDashboardDTO> getShareholderDashboard(@PathVariable Long id) {
        ShareholderDashboardDTO dashboard = shareholderService.getShareholderDashboard(id);
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/by-user/{userId}")
    @Operation(summary = "Get shareholder by user ID",
        responses = {
            @ApiResponse(responseCode = "200", description = "Shareholder fetched successfully",
                content = @Content(mediaType = "application/json",
                    schema = @Schema(implementation = ShareholderDTO.class))),
            @ApiResponse(responseCode = "404", description = "Shareholder not found")
        }
    )
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

    @GetMapping("/by-email/{email}")
@Operation(
    summary = "Get shareholder by email",
    responses = {
        @ApiResponse(
            responseCode = "200",
            description = "Shareholder fetched successfully",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ShareholderDTO.class))
        ),
        @ApiResponse(responseCode = "404", description = "Shareholder not found")
    }
)
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

}
