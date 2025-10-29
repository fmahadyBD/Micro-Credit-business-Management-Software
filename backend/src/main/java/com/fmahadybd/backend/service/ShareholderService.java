package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.repository.ShareholderRepository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShareholderService {

    private final ShareholderRepository shareholderRepository;

    @Transactional
    public Shareholder saveShareholder(Shareholder shareholder) {
        log.info("Saving shareholder: {}", shareholder.getName());
        
        if (shareholder == null) {
            throw new IllegalArgumentException("Shareholder cannot be null");
        }
        
        // Validate required fields
        if (shareholder.getName() == null || shareholder.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Shareholder name cannot be empty");
        }
        
        if (shareholder.getPhone() != null && !shareholder.getPhone().matches("^\\+?[0-9]{10,15}$")) {
            throw new IllegalArgumentException("Invalid phone number format");
        }
        
        if (shareholder.getInvestment() != null && shareholder.getInvestment() < 0) {
            throw new IllegalArgumentException("Investment cannot be negative");
        }
        
        if (shareholder.getTotalShare() != null && shareholder.getTotalShare() < 0) {
            throw new IllegalArgumentException("Total shares cannot be negative");
        }
        
        // Initialize null values
        if (shareholder.getInvestment() == null) {
            shareholder.setInvestment(0.0);
        }
        if (shareholder.getTotalShare() == null) {
            shareholder.setTotalShare(0);
        }
        if (shareholder.getTotalEarning() == null) {
            shareholder.setTotalEarning(0.0);
        }
        if (shareholder.getCurrentBalance() == null) {
            shareholder.setCurrentBalance(0.0);
        }
        if (shareholder.getStatus() == null || shareholder.getStatus().trim().isEmpty()) {
            shareholder.setStatus("Active");
        }
        
        Shareholder saved = shareholderRepository.save(shareholder);
        log.info("Successfully saved shareholder with id: {}", saved.getId());
        return saved;
    }

    public List<Shareholder> getAllShareholders() {
        log.info("Fetching all shareholders");
        return shareholderRepository.findAll();
    }

    public Optional<Shareholder> getShareholderById(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        log.info("Fetching shareholder with id: {}", id);
        return shareholderRepository.findById(id);
    }

    @Transactional
    public Shareholder updateShareholder(Long id, Shareholder shareholderDetails) {
        log.info("Updating shareholder with id: {}", id);
        
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (shareholderDetails == null) {
            throw new IllegalArgumentException("Shareholder details cannot be null");
        }
        
        // Validate fields
        if (shareholderDetails.getName() != null && shareholderDetails.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Shareholder name cannot be empty");
        }
        
        if (shareholderDetails.getPhone() != null && !shareholderDetails.getPhone().trim().isEmpty() 
                && !shareholderDetails.getPhone().matches("^\\+?[0-9]{10,15}$")) {
            throw new IllegalArgumentException("Invalid phone number format");
        }
        
        if (shareholderDetails.getInvestment() != null && shareholderDetails.getInvestment() < 0) {
            throw new IllegalArgumentException("Investment cannot be negative");
        }
        
        if (shareholderDetails.getTotalShare() != null && shareholderDetails.getTotalShare() < 0) {
            throw new IllegalArgumentException("Total shares cannot be negative");
        }
        
        if (shareholderDetails.getTotalEarning() != null && shareholderDetails.getTotalEarning() < 0) {
            throw new IllegalArgumentException("Total earning cannot be negative");
        }
        
        if (shareholderDetails.getCurrentBalance() != null && shareholderDetails.getCurrentBalance() < 0) {
            throw new IllegalArgumentException("Current balance cannot be negative");
        }

        return shareholderRepository.findById(id)
                .map(shareholder -> {
                    if (shareholderDetails.getName() != null) {
                        shareholder.setName(shareholderDetails.getName());
                    }
                    if (shareholderDetails.getPhone() != null) {
                        shareholder.setPhone(shareholderDetails.getPhone());
                    }
                    if (shareholderDetails.getNidCard() != null) {
                        shareholder.setNidCard(shareholderDetails.getNidCard());
                    }
                    if (shareholderDetails.getNominee() != null) {
                        shareholder.setNominee(shareholderDetails.getNominee());
                    }
                    if (shareholderDetails.getZila() != null) {
                        shareholder.setZila(shareholderDetails.getZila());
                    }
                    if (shareholderDetails.getHouse() != null) {
                        shareholder.setHouse(shareholderDetails.getHouse());
                    }
                    if (shareholderDetails.getInvestment() != null) {
                        shareholder.setInvestment(shareholderDetails.getInvestment());
                    }
                    if (shareholderDetails.getTotalShare() != null) {
                        shareholder.setTotalShare(shareholderDetails.getTotalShare());
                    }
                    if (shareholderDetails.getTotalEarning() != null) {
                        shareholder.setTotalEarning(shareholderDetails.getTotalEarning());
                    }
                    if (shareholderDetails.getCurrentBalance() != null) {
                        shareholder.setCurrentBalance(shareholderDetails.getCurrentBalance());
                    }
                    if (shareholderDetails.getRole() != null) {
                        shareholder.setRole(shareholderDetails.getRole());
                    }
                    if (shareholderDetails.getStatus() != null) {
                        shareholder.setStatus(shareholderDetails.getStatus());
                    }
                    if (shareholderDetails.getJoinDate() != null) {
                        shareholder.setJoinDate(shareholderDetails.getJoinDate());
                    }
                    
                    Shareholder updated = shareholderRepository.save(shareholder);
                    log.info("Successfully updated shareholder with id: {}", id);
                    return updated;
                })
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));
    }

    @Transactional
    public void deleteShareholder(Long id) {
        log.info("Deleting shareholder with id: {}", id);
        
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        if (!shareholderRepository.existsById(id)) {
            throw new RuntimeException("Shareholder not found with id: " + id);
        }
        
        Shareholder shareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));
        
        // Check if shareholder has balance
        if (shareholder.getCurrentBalance() != null && shareholder.getCurrentBalance() > 0) {
            throw new IllegalStateException("Cannot delete shareholder with outstanding balance: " + shareholder.getCurrentBalance());
        }
        
        // Check if shareholder has shares
        if (shareholder.getTotalShare() != null && shareholder.getTotalShare() > 0) {
            throw new IllegalStateException("Cannot delete shareholder with active shares: " + shareholder.getTotalShare());
        }
        
        shareholderRepository.deleteById(id);
        log.info("Successfully deleted shareholder with id: {}", id);
    }

    public Map<String, Object> getShareholderWithDetails(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        log.info("Fetching details for shareholder with id: {}", id);
        
        Shareholder shareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));

        Map<String, Object> details = new HashMap<>();
        details.put("shareholder", shareholder);
        details.put("totalShares", shareholder.getTotalShare() != null ? shareholder.getTotalShare() : 0);
        details.put("totalEarnings", shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0);
        details.put("currentBalance", shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0);
        details.put("activeSince", shareholder.getJoinDate());
        details.put("investment", shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0);
        
        // Calculate total value
        Double totalValue = (shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0) 
                + (shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0);
        details.put("totalValue", totalValue);

        return details;
    }

    public Map<String, Object> getShareholderDashboard(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }
        
        log.info("Fetching dashboard for shareholder with id: {}", id);
        
        Shareholder shareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));

        Map<String, Object> dashboard = new HashMap<>();
        dashboard.put("basicInfo", shareholder);
        dashboard.put("performanceMetrics", calculatePerformanceMetrics(shareholder));

        return dashboard;
    }

    private Map<String, Object> calculatePerformanceMetrics(Shareholder shareholder) {
        Map<String, Object> metrics = new HashMap<>();

        Double investment = shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0;
        Double totalEarning = shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0;

        // Return on Investment
        if (investment > 0) {
            double roi = (totalEarning / investment) * 100;
            metrics.put("roiPercentage", Math.round(roi * 100.0) / 100.0);
        } else {
            metrics.put("roiPercentage", 0.0);
        }

        // Monthly average earning
        if (shareholder.getJoinDate() != null) {
            long monthsActive = java.time.temporal.ChronoUnit.MONTHS.between(
                    shareholder.getJoinDate(),
                    java.time.LocalDate.now());
            
            if (monthsActive > 0) {
                double monthlyAverage = totalEarning / monthsActive;
                metrics.put("monthlyAverageEarning", Math.round(monthlyAverage * 100.0) / 100.0);
            } else {
                metrics.put("monthlyAverageEarning", 0.0);
            }
            
            metrics.put("monthsActive", monthsActive);
        } else {
            metrics.put("monthlyAverageEarning", 0.0);
            metrics.put("monthsActive", 0);
        }
        
        // Total value
        metrics.put("totalValue", investment + totalEarning);
        
        return metrics;
    }
    
    public List<Shareholder> getActiveShareholders() {
        log.info("Fetching active shareholders");
        return shareholderRepository.findByStatus("Active");
    }
    
    public List<Shareholder> getInactiveShareholders() {
        log.info("Fetching inactive shareholders");
        return shareholderRepository.findByStatus("Inactive");
    }
    
    public Map<String, Object> getShareholderStatistics() {
        log.info("Fetching shareholder statistics");
        
        List<Shareholder> allShareholders = shareholderRepository.findAll();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalShareholders", allShareholders.size());
        stats.put("activeShareholders", shareholderRepository.countByStatus("Active"));
        stats.put("inactiveShareholders", shareholderRepository.countByStatus("Inactive"));
        
        Double totalInvestment = allShareholders.stream()
                .mapToDouble(sh -> sh.getInvestment() != null ? sh.getInvestment() : 0.0)
                .sum();
        stats.put("totalInvestment", totalInvestment);
        
        Double totalEarnings = allShareholders.stream()
                .mapToDouble(sh -> sh.getTotalEarning() != null ? sh.getTotalEarning() : 0.0)
                .sum();
        stats.put("totalEarnings", totalEarnings);
        
        Double totalBalance = allShareholders.stream()
                .mapToDouble(sh -> sh.getCurrentBalance() != null ? sh.getCurrentBalance() : 0.0)
                .sum();
        stats.put("totalBalance", totalBalance);
        
        Integer totalShares = allShareholders.stream()
                .mapToInt(sh -> sh.getTotalShare() != null ? sh.getTotalShare() : 0)
                .sum();
        stats.put("totalShares", totalShares);
        
        Double totalValue = totalInvestment + totalEarnings;
        stats.put("totalValue", totalValue);
        
        return stats;
    }
}