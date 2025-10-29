package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.dto.ShareholderEarningDTO;
import com.fmahadybd.backend.service.ShareholderEarningService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.YearMonth;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/earnings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Slf4j
public class ShareholderEarningController {

    private final ShareholderEarningService earningService;

    @PostMapping("/calculate/{shareholderId}")
    public ResponseEntity<?> calculateMonthlyEarnings(
            @PathVariable Long shareholderId,
            @RequestParam Double totalBusinessProfit) {
        try {
            earningService.calculateMonthlyEarnings(shareholderId, totalBusinessProfit, true);
            return ResponseEntity.ok(Map.of("message", "Earnings calculated successfully"));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to calculate earnings: " + e.getMessage()));
        }
    }

    @PostMapping("/calculate-all")
    public ResponseEntity<?> calculateAllShareholdersEarnings(@RequestParam Double totalBusinessProfit) {
        try {
            earningService.calculateAllShareholdersEarnings(totalBusinessProfit);
            return ResponseEntity.ok(Map.of("message", "Earnings calculated for all shareholders"));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to calculate earnings: " + e.getMessage()));
        }
    }

    @PostMapping("/recalculate")
    public ResponseEntity<?> recalculateMonthEarnings(
            @RequestParam String month,
            @RequestParam Double totalBusinessProfit) {
        try {
            YearMonth yearMonth = YearMonth.parse(month);
            earningService.recalculateMonthEarnings(yearMonth, totalBusinessProfit);
            return ResponseEntity.ok(Map.of("message", "Earnings recalculated for month: " + month));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to recalculate earnings: " + e.getMessage()));
        }
    }

    @PostMapping("/{shareholderId}/add-historical")
    public ResponseEntity<?> addHistoricalEarning(
            @PathVariable Long shareholderId,
            @RequestParam String month,
            @RequestParam Double monthlyEarning,
            @RequestParam(required = false) String description) {
        try {
            YearMonth yearMonth = YearMonth.parse(month);
            earningService.addHistoricalEarning(shareholderId, yearMonth, monthlyEarning, description);
            return ResponseEntity.ok(Map.of("message", "Historical earning added successfully"));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to add historical earning: " + e.getMessage()));
        }
    }

    @GetMapping("/{shareholderId}")
    public ResponseEntity<?> getShareholderEarnings(@PathVariable Long shareholderId) {
        try {
            List<ShareholderEarningDTO> earnings = earningService.getShareholderEarnings(shareholderId);
            return ResponseEntity.ok(earnings);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch earnings: " + e.getMessage()));
        }
    }

    @GetMapping("/{shareholderId}/summary")
    public ResponseEntity<?> getEarningSummary(@PathVariable Long shareholderId) {
        try {
            log.info("Fetching earning summary for shareholder: {}", shareholderId);
            Map<String, Object> summary = earningService.getEarningSummary(shareholderId);
            log.info("Successfully fetched summary for shareholder: {}", shareholderId);
            return ResponseEntity.ok(summary);
        } catch (IllegalArgumentException e) {
            log.error("Invalid argument for shareholder {}: {}", shareholderId, e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            log.error("Shareholder not found: {}", shareholderId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            log.error("Unexpected error fetching summary for shareholder {}: ", shareholderId, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch summary: " + e.getMessage(),
                            "details", "Check server logs for more information"));
        }
    }

    @GetMapping("/{shareholderId}/last-12-months")
    public ResponseEntity<?> getLast12MonthsEarnings(@PathVariable Long shareholderId) {
        try {
            Map<String, Object> chartData = earningService.getLast12MonthsEarnings(shareholderId);
            return ResponseEntity.ok(chartData);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch chart data: " + e.getMessage()));
        }
    }

    @GetMapping("/dashboard")
    public ResponseEntity<?> getDashboardSummary() {
        try {
            Map<String, Object> summary = earningService.getDashboardSummary();
            return ResponseEntity.ok(summary);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch dashboard summary: " + e.getMessage()));
        }
    }

    @GetMapping("/last-month")
    public ResponseEntity<?> getLastMonthEarnings() {
        try {
            Map<String, Object> earnings = earningService.getLastMonthEarnings();
            return ResponseEntity.ok(earnings);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch last month earnings: " + e.getMessage()));
        }
    }
}