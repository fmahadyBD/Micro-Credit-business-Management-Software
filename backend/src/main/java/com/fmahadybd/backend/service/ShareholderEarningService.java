package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.dto.ShareholderEarningDTO;
import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.entity.ShareholderEarning;
import com.fmahadybd.backend.repository.ShareholderRepository;
import com.fmahadybd.backend.repository.ShareholderEarningRepository;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShareholderEarningService {

    private final ShareholderEarningRepository earningRepository;
    private final ShareholderRepository shareholderRepository;

    private static final double INTEREST_RATE = 0.15; // 15% annual
    private static final double MONTHLY_RATE = INTEREST_RATE / 12; // 1.25% monthly

    /**
     * Auto-calculate earnings monthly (runs on 1st of each month at 1 AM)
     * Uncomment @Scheduled when you want automatic calculation
     */
    @Scheduled(cron = "0 0 1 1 * ?") // 1st day of month at 1 AM
    public void autoCalculateMonthlyEarnings() {
        log.info("Auto-calculating monthly earnings...");
        try {
            // You need to implement logic to get total business profit
            // For now, this is a placeholder - you should store monthly profit in a
            // separate table
            Double totalBusinessProfit = 100000.0; // TODO: Get from business profit table
            calculateAllShareholdersEarningsForce(totalBusinessProfit, false);
            log.info("Auto-calculation completed successfully");
        } catch (Exception e) {
            log.error("Auto-calculation failed: ", e);
        }
    }

    @Transactional
    public ShareholderEarning calculateMonthlyEarnings(Long shareholderId, Double totalBusinessProfit,
            boolean forceRecalculate) {
        log.info("Calculating monthly earnings for shareholder: {}", shareholderId);

        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (totalBusinessProfit == null || totalBusinessProfit < 0) {
            throw new IllegalArgumentException("Total business profit must be a positive number");
        }

        Shareholder shareholder = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + shareholderId));

        if (!"Active".equalsIgnoreCase(shareholder.getStatus())) {
            throw new IllegalStateException("Cannot calculate earnings for inactive shareholder");
        }

        YearMonth currentMonth = YearMonth.now();

        // Check if already calculated for this month
        Optional<ShareholderEarning> existingEarning = earningRepository.findByShareholderIdAndMonth(shareholderId,
                currentMonth);

        if (existingEarning.isPresent() && !forceRecalculate) {
            log.info("Earnings already calculated for shareholder {} in month {}", shareholderId, currentMonth);
            return existingEarning.get();
        }

        Integer totalShares = getTotalShares();
        if (totalShares == 0) {
            throw new IllegalStateException("No shares exist in the system");
        }

        // Calculate monthly earning based on share percentage
        Double shareholderPercentage = (double) shareholder.getTotalShare() / totalShares * 100;
        Double monthlyEarning = totalBusinessProfit * MONTHLY_RATE * (shareholderPercentage / 100);

        ShareholderEarning earning;

        if (existingEarning.isPresent() && forceRecalculate) {
            // Update existing
            earning = existingEarning.get();

            // Adjust shareholder balances (remove old, add new)
            Double oldEarning = earning.getMonthlyEarning();
            Double currentTotalEarning = shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0;
            Double currentBalance = shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0;

            shareholder.setTotalEarning(currentTotalEarning - oldEarning + monthlyEarning);
            shareholder.setCurrentBalance(currentBalance - oldEarning + monthlyEarning);

            // Update earning
            earning.setMonthlyEarning(monthlyEarning);
            earning.setDescription(
                    String.format("Monthly profit share (%.2f%%) - Recalculated", shareholderPercentage));
            earning.setCalculatedDate(LocalDate.now());
        } else {
            // Create new
            earning = ShareholderEarning.builder()
                    .shareholder(shareholder)
                    .month(currentMonth)
                    .monthlyEarning(monthlyEarning)
                    .description(String.format("Monthly profit share (%.2f%%)", shareholderPercentage))
                    .calculatedDate(LocalDate.now())
                    .build();

            // Update shareholder balances
            Double currentTotalEarning = shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0;
            Double currentBalance = shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0;

            shareholder.setTotalEarning(currentTotalEarning + monthlyEarning);
            shareholder.setCurrentBalance(currentBalance + monthlyEarning);
        }

        earningRepository.save(earning);
        shareholderRepository.save(shareholder);

        log.info("Successfully calculated earnings for shareholder: {}, amount: {}", shareholderId, monthlyEarning);
        return earning;
    }

    @Transactional
    public List<ShareholderEarning> calculateAllShareholdersEarnings(Double totalBusinessProfit) {
        return calculateAllShareholdersEarningsForce(totalBusinessProfit, false);
    }

    @Transactional
    public List<ShareholderEarning> calculateAllShareholdersEarningsForce(Double totalBusinessProfit,
            boolean forceRecalculate) {
        log.info("Calculating earnings for all shareholders (force: {})", forceRecalculate);

        if (totalBusinessProfit == null || totalBusinessProfit < 0) {
            throw new IllegalArgumentException("Total business profit must be a positive number");
        }

        List<Shareholder> shareholders = shareholderRepository.findByStatus("Active");

        if (shareholders.isEmpty()) {
            throw new IllegalStateException("No active shareholders found");
        }

        YearMonth currentMonth = YearMonth.now();

        // Check if any earnings already exist for this month
        if (!forceRecalculate) {
            boolean anyCalculated = shareholders.stream()
                    .anyMatch(sh -> earningRepository.existsByShareholderIdAndMonth(sh.getId(), currentMonth));

            if (anyCalculated) {
                throw new IllegalStateException("Earnings for some shareholders already calculated for month: "
                        + currentMonth + ". Use forceRecalculate=true to recalculate.");
            }
        }

        Integer totalShares = getTotalShares();
        if (totalShares == 0) {
            throw new IllegalStateException("No shares exist in the system");
        }

        List<ShareholderEarning> earnings = new ArrayList<>();

        for (Shareholder shareholder : shareholders) {
            try {
                ShareholderEarning earning = calculateMonthlyEarnings(shareholder.getId(), totalBusinessProfit,
                        forceRecalculate);
                earnings.add(earning);
            } catch (Exception e) {
                log.error("Failed to calculate earnings for shareholder {}: {}", shareholder.getId(), e.getMessage());
            }
        }

        log.info("Successfully calculated earnings for {} shareholders", earnings.size());
        return earnings;
    }

    @Transactional
    public void recalculateMonthEarnings(YearMonth month, Double totalBusinessProfit) {
        log.info("Recalculating earnings for month: {}", month);

        if (month == null) {
            throw new IllegalArgumentException("Month cannot be null");
        }

        if (totalBusinessProfit == null || totalBusinessProfit < 0) {
            throw new IllegalArgumentException("Total business profit must be a positive number");
        }

        if (month.isAfter(YearMonth.now())) {
            throw new IllegalArgumentException("Cannot calculate earnings for future months");
        }

        List<Shareholder> shareholders = shareholderRepository.findByStatus("Active");

        if (shareholders.isEmpty()) {
            throw new IllegalStateException("No active shareholders found");
        }

        Integer totalShares = getTotalShares();
        if (totalShares == 0) {
            throw new IllegalStateException("No shares exist in the system");
        }

        // Get existing earnings for this month
        List<ShareholderEarning> existingEarnings = earningRepository.findByMonth(month);
        Map<Long, ShareholderEarning> earningMap = existingEarnings.stream()
                .collect(Collectors.toMap(e -> e.getShareholder().getId(), e -> e));

        for (Shareholder shareholder : shareholders) {
            ShareholderEarning existingEarning = earningMap.get(shareholder.getId());

            Double shareholderPercentage = (double) shareholder.getTotalShare() / totalShares * 100;
            Double newMonthlyEarning = totalBusinessProfit * MONTHLY_RATE * (shareholderPercentage / 100);

            if (existingEarning != null) {
                // Update existing earning
                Double oldEarning = existingEarning.getMonthlyEarning();
                Double difference = newMonthlyEarning - oldEarning;

                existingEarning.setMonthlyEarning(newMonthlyEarning);
                existingEarning.setDescription(
                        String.format("Monthly profit share (%.2f%%) - Recalculated", shareholderPercentage));
                existingEarning.setCalculatedDate(LocalDate.now());

                // Adjust shareholder balances
                shareholder.setTotalEarning(shareholder.getTotalEarning() + difference);
                shareholder.setCurrentBalance(shareholder.getCurrentBalance() + difference);

                earningRepository.save(existingEarning);
            } else {
                // Create new earning for this shareholder
                ShareholderEarning newEarning = ShareholderEarning.builder()
                        .shareholder(shareholder)
                        .month(month)
                        .monthlyEarning(newMonthlyEarning)
                        .description(String.format("Monthly profit share (%.2f%%)", shareholderPercentage))
                        .calculatedDate(LocalDate.now())
                        .build();

                shareholder.setTotalEarning(shareholder.getTotalEarning() + newMonthlyEarning);
                shareholder.setCurrentBalance(shareholder.getCurrentBalance() + newMonthlyEarning);

                earningRepository.save(newEarning);
            }
        }

        shareholderRepository.saveAll(shareholders);
        log.info("Successfully recalculated earnings for {} shareholders for month: {}", shareholders.size(), month);
    }

    @Transactional
    public ShareholderEarning addHistoricalEarning(Long shareholderId, YearMonth month, Double monthlyEarning,
            String description) {
        log.info("Adding historical earning for shareholder: {} for month: {}", shareholderId, month);

        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (month == null) {
            throw new IllegalArgumentException("Month cannot be null");
        }

        if (monthlyEarning == null || monthlyEarning < 0) {
            throw new IllegalArgumentException("Monthly earning must be a non-negative number");
        }

        if (month.isAfter(YearMonth.now())) {
            throw new IllegalArgumentException("Cannot add earnings for future months");
        }

        Shareholder shareholder = shareholderRepository.findById(shareholderId)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + shareholderId));

        // Check if earning already exists
        Optional<ShareholderEarning> existingEarning = earningRepository.findByShareholderIdAndMonth(shareholderId,
                month);
        if (existingEarning.isPresent()) {
            throw new IllegalStateException(
                    "Earning already exists for month: " + month + ". Use recalculate method to update.");
        }

        ShareholderEarning earning = ShareholderEarning.builder()
                .shareholder(shareholder)
                .month(month)
                .monthlyEarning(monthlyEarning)
                .description(description != null && !description.isEmpty() ? description : "Historical earning")
                .calculatedDate(LocalDate.now())
                .build();

        earningRepository.save(earning);

        // Update shareholder balances
        Double currentTotalEarning = shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0;
        Double currentBalance = shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0;

        shareholder.setTotalEarning(currentTotalEarning + monthlyEarning);
        shareholder.setCurrentBalance(currentBalance + monthlyEarning);

        shareholderRepository.save(shareholder);

        log.info("Successfully added historical earning for shareholder: {}", shareholderId);
        return earning;
    }

    public List<ShareholderEarningDTO> getShareholderEarnings(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }

        List<ShareholderEarning> earnings = earningRepository.findByShareholderIdOrderByMonthDesc(shareholderId);
        return earnings.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private ShareholderEarningDTO convertToDTO(ShareholderEarning earning) {
        return ShareholderEarningDTO.builder()
                .id(earning.getId())
                .shareholderId(earning.getShareholder().getId())
                .shareholderName(earning.getShareholder().getName())
                .month(earning.getMonth().toString()) // Convert to String
                .monthlyEarning(earning.getMonthlyEarning())
                .description(earning.getDescription())
                .calculatedDate(earning.getCalculatedDate())
                .build();
    }

    public Optional<ShareholderEarning> getMonthlyEarning(Long shareholderId, YearMonth month) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (month == null) {
            throw new IllegalArgumentException("Month cannot be null");
        }

        return earningRepository.findByShareholderIdAndMonth(shareholderId, month);
    }

    public Map<String, Object> getEarningSummary(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }

        List<ShareholderEarning> allEarnings = earningRepository.findByShareholderIdOrderByMonthDesc(shareholderId);

        Map<String, Object> summary = new HashMap<>();
        summary.put("totalEarnings", allEarnings.stream()
                .mapToDouble(ShareholderEarning::getMonthlyEarning)
                .sum());
        summary.put("averageMonthlyEarning", allEarnings.stream()
                .mapToDouble(ShareholderEarning::getMonthlyEarning)
                .average()
                .orElse(0.0));
        summary.put("totalMonths", allEarnings.size());
        summary.put("lastEarningMonth", allEarnings.stream()
                .findFirst()
                .map(e -> e.getMonth().toString())
                .orElse(null));

        return summary;
    }

    public Map<String, Object> getLast12MonthsEarnings(Long shareholderId) {
        if (shareholderId == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (!shareholderRepository.existsById(shareholderId)) {
            throw new RuntimeException("Shareholder not found with id: " + shareholderId);
        }

        YearMonth currentMonth = YearMonth.now();
        List<Map<String, Object>> monthlyData = new ArrayList<>();

        for (int i = 11; i >= 0; i--) {
            YearMonth month = currentMonth.minusMonths(i);
            Map<String, Object> monthData = new HashMap<>();
            monthData.put("month", month.toString());

            Optional<ShareholderEarning> earning = getMonthlyEarning(shareholderId, month);
            monthData.put("earning", earning.map(ShareholderEarning::getMonthlyEarning).orElse(0.0));
            monthData.put("calculated", earning.isPresent());

            monthlyData.add(monthData);
        }

        Map<String, Object> chartData = new HashMap<>();
        chartData.put("labels", monthlyData.stream()
                .map(m -> m.get("month").toString())
                .collect(Collectors.toList()));
        chartData.put("earnings", monthlyData.stream()
                .map(m -> (Double) m.get("earning"))
                .collect(Collectors.toList()));
        chartData.put("detailedData", monthlyData);

        return chartData;
    }

    public Map<String, Object> getDashboardSummary() {
        Map<String, Object> summary = new HashMap<>();

        long totalShareholders = shareholderRepository.count();
        summary.put("totalShareholders", totalShareholders);

        long activeShareholders = shareholderRepository.countByStatus("Active");
        summary.put("activeShareholders", activeShareholders);

        Double totalInvestment = shareholderRepository.findAll().stream()
                .mapToDouble(sh -> sh.getInvestment() != null ? sh.getInvestment() : 0.0)
                .sum();
        summary.put("totalInvestment", totalInvestment);

        Integer totalShares = getTotalShares();
        summary.put("totalShares", totalShares);

        Double totalValue = shareholderRepository.findAll().stream()
                .mapToDouble(sh -> {
                    Double investment = sh.getInvestment() != null ? sh.getInvestment() : 0.0;
                    Double earnings = sh.getTotalEarning() != null ? sh.getTotalEarning() : 0.0;
                    return investment + earnings;
                })
                .sum();
        summary.put("totalValue", totalValue);

        YearMonth currentMonth = YearMonth.now();
        Double thisMonthEarnings = earningRepository.findByMonth(currentMonth)
                .stream()
                .mapToDouble(ShareholderEarning::getMonthlyEarning)
                .sum();
        summary.put("thisMonthEarnings", thisMonthEarnings);

        YearMonth lastMonth = currentMonth.minusMonths(1);
        Double lastMonthEarnings = earningRepository.findByMonth(lastMonth)
                .stream()
                .mapToDouble(ShareholderEarning::getMonthlyEarning)
                .sum();
        summary.put("lastMonthEarnings", lastMonthEarnings);

        if (lastMonthEarnings > 0) {
            double growth = ((thisMonthEarnings - lastMonthEarnings) / lastMonthEarnings) * 100;
            summary.put("growthPercentage", Math.round(growth * 100.0) / 100.0);
        } else {
            summary.put("growthPercentage", 0.0);
        }

        return summary;
    }

    public Map<String, Object> getLastMonthEarnings() {
        YearMonth lastMonth = YearMonth.now().minusMonths(1);
        List<ShareholderEarning> lastMonthEarnings = earningRepository.findByMonth(lastMonth);

        Map<String, Object> result = new HashMap<>();
        result.put("month", lastMonth.toString());
        result.put("totalEarnings", lastMonthEarnings.stream()
                .mapToDouble(ShareholderEarning::getMonthlyEarning)
                .sum());
        result.put("shareholderCount", lastMonthEarnings.size());
        result.put("shareholderEarnings", lastMonthEarnings.stream()
                .collect(Collectors.toMap(
                        e -> e.getShareholder().getName(),
                        ShareholderEarning::getMonthlyEarning)));

        return result;
    }

    private Integer getTotalShares() {
        return shareholderRepository.findAll().stream()
                .mapToInt(sh -> sh.getTotalShare() != null ? sh.getTotalShare() : 0)
                .sum();
    }
}