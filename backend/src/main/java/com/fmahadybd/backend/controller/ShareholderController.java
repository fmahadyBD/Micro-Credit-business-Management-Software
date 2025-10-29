package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.service.ShareholderService;
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
public class ShareholderController {

    private final ShareholderService shareholderService;

    @PostMapping
    public ResponseEntity<?> createShareholder(@RequestBody Shareholder shareholder) {
        try {
            Shareholder saved = shareholderService.saveShareholder(shareholder);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to create shareholder: " + e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<?> getAllShareholders() {
        try {
            List<Shareholder> shareholders = shareholderService.getAllShareholders();
            return ResponseEntity.ok(shareholders);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch shareholders: " + e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getShareholderById(@PathVariable Long id) {
        try {
            return shareholderService.getShareholderById(id)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch shareholder: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateShareholder(@PathVariable Long id, @RequestBody Shareholder shareholder) {
        try {
            Shareholder updated = shareholderService.updateShareholder(id, shareholder);
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
    public ResponseEntity<?> getShareholderDetails(@PathVariable Long id) {
        try {
            Map<String, Object> details = shareholderService.getShareholderWithDetails(id);
            return ResponseEntity.ok(details);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch details: " + e.getMessage()));
        }
    }

    @GetMapping("/{id}/dashboard")
    public ResponseEntity<?> getShareholderDashboard(@PathVariable Long id) {
        try {
            Map<String, Object> dashboard = shareholderService.getShareholderDashboard(id);
            return ResponseEntity.ok(dashboard);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch dashboard: " + e.getMessage()));
        }
    }

    @GetMapping("/active")
    public ResponseEntity<?> getActiveShareholders() {
        try {
            List<Shareholder> shareholders = shareholderService.getActiveShareholders();
            return ResponseEntity.ok(shareholders);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch active shareholders: " + e.getMessage()));
        }
    }

    @GetMapping("/statistics")
    public ResponseEntity<?> getShareholderStatistics() {
        try {
            Map<String, Object> stats = shareholderService.getShareholderStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch statistics: " + e.getMessage()));
        }
    }
}