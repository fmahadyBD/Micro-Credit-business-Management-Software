// ShareholderService.java (Fixed Math.abs & Added Logged-in User)
package com.fmahadybd.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.dto.AddInvestmentDTO;
import com.fmahadybd.backend.dto.InvestmentHistoryDTO;
import com.fmahadybd.backend.dto.ShareholderCreateDTO;
import com.fmahadybd.backend.dto.ShareholderDTO;
import com.fmahadybd.backend.dto.ShareholderDashboardDTO;
import com.fmahadybd.backend.dto.ShareholderDetailsDTO;
import com.fmahadybd.backend.dto.ShareholderUpdateDTO;
import com.fmahadybd.backend.dto.StatisticsDTO;
import com.fmahadybd.backend.entity.InvestmentHistory;
import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.entity.TransactionHistory;
import com.fmahadybd.backend.mapper.ShareholderMapper;
import com.fmahadybd.backend.repository.InvestmentHistoryRepository;
import com.fmahadybd.backend.repository.MainBalanceRepository;
import com.fmahadybd.backend.repository.ShareholderRepository;
import com.fmahadybd.backend.repository.TransactionHistoryRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShareholderService {

    private final ShareholderRepository shareholderRepository;
    private final ShareholderMapper shareholderMapper;
    private final MainBalanceRepository mainBalanceRepository;
    private final TransactionHistoryRepository transactionHistoryRepository;
    private final InvestmentHistoryRepository investmentHistoryRepository;

    @Transactional
    public ShareholderDTO saveShareholder(ShareholderCreateDTO shareholderDTO) {
        if (shareholderDTO == null) {
            throw new IllegalArgumentException("Shareholder data cannot be null");
        }

        log.info("Saving shareholder: {}", shareholderDTO.getName());
        
        // Get logged-in user
        String performedBy = getLoggedInUsername();

        // Convert DTO to entity
        Shareholder shareholder = shareholderMapper.toEntity(shareholderDTO);

        // ✅ Forceful null check
        if (shareholder.getTotalEarning() == null) {
            shareholder.setTotalEarning(0.0);
        }
        if (shareholder.getTotalShare() == null) {
            shareholder.setTotalShare(0);
        }
        if (shareholder.getCurrentBalance() == null) {
            shareholder.setCurrentBalance(0.0);
        }

        // Save shareholder
        Shareholder savedShareholder = shareholderRepository.save(shareholder);
        log.info("Successfully saved shareholder with id: {}", savedShareholder.getId());

        // ✅ Update MainBalance for investment
        Double investmentAmount = shareholderDTO.getInvestment() != null ? shareholderDTO.getInvestment() : 0.0;
        
        if (investmentAmount > 0) {
            updateMainBalanceForInvestment(
                investmentAmount, 
                savedShareholder.getName(),
                performedBy
            );

            // Create transaction history
            createTransactionHistory(
                "INVESTMENT",
                investmentAmount,
                "শেয়ারহোল্ডার যোগ করা হয়েছে: " + savedShareholder.getName() + " | বিনিয়োগ: ৳" + investmentAmount,
                savedShareholder.getId(),
                null,
                performedBy
            );
        }

        return shareholderMapper.toDTO(savedShareholder);
    }

    @Transactional
    public ShareholderDTO updateShareholder(Long id, ShareholderUpdateDTO shareholderDTO) {
        log.info("Updating shareholder with id: {}", id);

        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (shareholderDTO == null) {
            throw new IllegalArgumentException("Shareholder details cannot be null");
        }

        // Get logged-in user
        String performedBy = getLoggedInUsername();

        // Fetch existing shareholder
        Shareholder existingShareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));

        // Store old investment for balance adjustment
        Double oldInvestment = existingShareholder.getInvestment() != null ? existingShareholder.getInvestment() : 0.0;
        Double newInvestment = shareholderDTO.getInvestment() != null ? shareholderDTO.getInvestment() : 0.0;
        
        // ✅ FIXED: Calculate difference correctly
        Double investmentDifference = newInvestment - oldInvestment;
        
        // Update current balance based on investment change
        Double oldBalance = existingShareholder.getCurrentBalance() != null ? existingShareholder.getCurrentBalance() : 0.0;
        Double newBalance = oldBalance + investmentDifference;
        
        // Update shareholder entity
        Shareholder updatedEntity = shareholderMapper.toEntity(shareholderDTO, existingShareholder);
        updatedEntity.setCurrentBalance(newBalance);
        Shareholder savedShareholder = shareholderRepository.save(updatedEntity);

        // ✅ Update MainBalance if investment changed
        if (investmentDifference != 0) {
            String transactionType = investmentDifference > 0 ? "INVESTMENT" : "WITHDRAWAL";
            
            if (investmentDifference > 0) {
                // Investment increased
                updateMainBalanceForInvestment(
                    investmentDifference,
                    savedShareholder.getName(),
                    performedBy
                );
            } else {
                // Investment decreased (withdrawal)
                // ✅ FIXED: Use Math.abs() correctly for Double
                updateMainBalanceForWithdrawal(
                    Math.abs(investmentDifference),
                    savedShareholder.getName(),
                    performedBy
                );
            }

            // Create transaction history
            createTransactionHistory(
                transactionType,
                Math.abs(investmentDifference),
                String.format("শেয়ারহোল্ডার আপডেট: %s | পুরাতন বিনিয়োগ: ৳%.2f | নতুন বিনিয়োগ: ৳%.2f | পরিবর্তন: ৳%.2f",
                    savedShareholder.getName(), oldInvestment, newInvestment, investmentDifference),
                savedShareholder.getId(),
                null,
                performedBy
            );
        }

        log.info("Successfully updated shareholder with id: {}", id);
        return shareholderMapper.toDTO(savedShareholder);
    }

    @Transactional
    public void deleteShareholder(Long id) {
        log.info("Deleting shareholder with id: {}", id);

        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        // Get logged-in user
        String performedBy = getLoggedInUsername();

        Shareholder shareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));

        // Check if shareholder has balance
        if (shareholder.getCurrentBalance() != null && shareholder.getCurrentBalance() > 0) {
            throw new IllegalStateException(
                    "Cannot delete shareholder with outstanding balance: " + shareholder.getCurrentBalance());
        }

        // Check if shareholder has shares
        if (shareholder.getTotalShare() != null && shareholder.getTotalShare() > 0) {
            throw new IllegalStateException(
                    "Cannot delete shareholder with active shares: " + shareholder.getTotalShare());
        }

        // ✅ Update MainBalance for investment withdrawal (refund)
        Double investmentAmount = shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0;
        
        if (investmentAmount > 0) {
            updateMainBalanceForWithdrawal(
                investmentAmount,
                shareholder.getName(),
                performedBy
            );

            // Create transaction history
            createTransactionHistory(
                "WITHDRAWAL",
                investmentAmount,
                "শেয়ারহোল্ডার মুছে ফেলা হয়েছে: " + shareholder.getName() + " | ফেরত: ৳" + investmentAmount,
                shareholder.getId(),
                null,
                performedBy
            );
        }

        shareholderRepository.deleteById(id);
        log.info("Successfully deleted shareholder with id: {}", id);
    }

    // ========== HELPER METHODS ==========

    /** Get logged-in username from SecurityContext */
    private String getLoggedInUsername() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated() 
                && !authentication.getPrincipal().equals("anonymousUser")) {
                return authentication.getName();
            }
        } catch (Exception e) {
            log.warn("Could not get logged-in user, using 'system': {}", e.getMessage());
        }
        return "system";
    }

    /** Update MainBalance for new investment */
    private void updateMainBalanceForInvestment(Double amount, String shareholderName, String performedBy) {
        MainBalance currentBalance = getMainBalance();
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        // Update balances
        newBalance.setTotalBalance(currentBalance.getTotalBalance() + amount);
        newBalance.setTotalInvestment(currentBalance.getTotalInvestment() + amount);
        newBalance.setWhoChanged(performedBy);
        newBalance.setReason("শেয়ারহোল্ডার বিনিয়োগ: " + shareholderName + " | পরিমাণ: ৳" + amount);
        
        mainBalanceRepository.save(newBalance);
    }

    /** Update MainBalance for withdrawal */
    private void updateMainBalanceForWithdrawal(Double amount, String shareholderName, String performedBy) {
        MainBalance currentBalance = getMainBalance();
        
        // Check if withdrawal is possible
        if (amount > currentBalance.getTotalBalance()) {
            throw new RuntimeException("প্রধান ব্যালেন্সে অপর্যাপ্ত তহবিল। উপলব্ধ: ৳" + 
                currentBalance.getTotalBalance() + ", প্রয়োজন: ৳" + amount);
        }
        
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        // Update balances
        newBalance.setTotalBalance(currentBalance.getTotalBalance() - amount);
        newBalance.setTotalInvestment(currentBalance.getTotalInvestment() - amount);
        newBalance.setWhoChanged(performedBy);
        newBalance.setReason("শেয়ারহোল্ডার প্রত্যাহার: " + shareholderName + " | পরিমাণ: ৳" + amount);
        
        mainBalanceRepository.save(newBalance);
    }

    /** Create new MainBalance record */
    private MainBalance createNewMainBalanceRecord(MainBalance currentBalance) {
        return MainBalance.builder()
                .totalBalance(currentBalance.getTotalBalance())
                .totalInvestment(currentBalance.getTotalInvestment())
                .totalProductCost(currentBalance.getTotalProductCost())
                .totalMaintenanceCost(currentBalance.getTotalMaintenanceCost())
                .totalInstallmentReturn(currentBalance.getTotalInstallmentReturn())
                .totalEarnings(currentBalance.getTotalEarnings())
                .whoChanged(currentBalance.getWhoChanged())
                .reason("পূর্ববর্তী ব্যালেন্স থেকে নতুন রেকর্ড তৈরি")
                .build();
    }

    /** Get current main balance */
    private MainBalance getMainBalance() {
        return mainBalanceRepository.findTopByOrderByIdDesc()
                .orElseGet(() -> MainBalance.builder()
                        .totalBalance(0.0)
                        .totalInvestment(0.0)
                        .totalProductCost(0.0)
                        .totalMaintenanceCost(0.0)
                        .totalInstallmentReturn(0.0)
                        .totalEarnings(0.0)
                        .whoChanged("system")
                        .reason("প্রাথমিক ব্যালেন্স")
                        .build());
    }

    /** Create transaction history */
    private void createTransactionHistory(String type, Double amount, String description, 
                                        Long shareholderId, Long memberId, String performedBy) {
        TransactionHistory transaction = TransactionHistory.builder()
                .type(type)
                .amount(amount)
                .description(description)
                .shareholderId(shareholderId)
                .memberId(memberId)
                .timestamp(LocalDateTime.now())
                .build();
        
        transactionHistoryRepository.save(transaction);
    }

    // ========== OTHER METHODS (UNCHANGED) ==========

    public List<ShareholderDTO> getAllShareholders() {
        log.info("Fetching all shareholders");
        return shareholderRepository.findAll()
                .stream()
                .map(shareholderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public Optional<ShareholderDTO> getShareholderById(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        log.info("Fetching shareholder with id: {}", id);
        return shareholderRepository.findById(id)
                .map(shareholderMapper::toDTO);
    }

    public ShareholderDetailsDTO getShareholderWithDetails(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        log.info("Fetching details for shareholder with id: {}", id);

        Shareholder shareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));

        return shareholderMapper.toDetailsDTO(shareholder);
    }

    public ShareholderDashboardDTO getShareholderDashboard(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        log.info("Fetching dashboard for shareholder with id: {}", id);

        Shareholder shareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));

        return shareholderMapper.toDashboardDTO(shareholder);
    }

    public List<ShareholderDTO> getActiveShareholders() {
        log.info("Fetching active shareholders");
        return shareholderRepository.findByStatus("Active")
                .stream()
                .map(shareholderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public List<ShareholderDTO> getInactiveShareholders() {
        log.info("Fetching inactive shareholders");
        return shareholderRepository.findByStatus("Inactive")
                .stream()
                .map(shareholderMapper::toDTO)
                .collect(Collectors.toList());
    }

    public StatisticsDTO getShareholderStatistics() {
        log.info("Fetching shareholder statistics");

        List<Shareholder> allShareholders = shareholderRepository.findAll();

        return StatisticsDTO.builder()
                .totalShareholders(allShareholders.size())
                .activeShareholders(shareholderRepository.countByStatus("Active"))
                .inactiveShareholders(shareholderRepository.countByStatus("Inactive"))
                .totalInvestment(allShareholders.stream()
                        .mapToDouble(sh -> sh.getInvestment() != null ? sh.getInvestment() : 0.0)
                        .sum())
                .totalEarnings(allShareholders.stream()
                        .mapToDouble(sh -> sh.getTotalEarning() != null ? sh.getTotalEarning() : 0.0)
                        .sum())
                .totalBalance(allShareholders.stream()
                        .mapToDouble(sh -> sh.getCurrentBalance() != null ? sh.getCurrentBalance() : 0.0)
                        .sum())
                .totalShares(allShareholders.stream()
                        .mapToInt(sh -> sh.getTotalShare() != null ? sh.getTotalShare() : 0)
                        .sum())
                .totalValue(allShareholders.stream()
                        .mapToDouble(sh -> {
                            Double inv = sh.getInvestment() != null ? sh.getInvestment() : 0.0;
                            Double earning = sh.getTotalEarning() != null ? sh.getTotalEarning() : 0.0;
                            return inv + earning;
                        })
                        .sum())
                .build();
    }

    @Transactional(readOnly = true)
    public ShareholderDTO getShareholderByUserId(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        log.info("Fetching shareholder for user ID: {}", userId);

        Shareholder shareholder = shareholderRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Shareholder not found for user ID: " + userId));

        return shareholderMapper.toDTO(shareholder);
    }

    @Transactional(readOnly = true)
    public ShareholderDTO getShareholderByEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }

        log.info("Fetching shareholder for email: {}", email);

        Shareholder shareholder = shareholderRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with email: " + email));

        return shareholderMapper.toDTO(shareholder);
    }








    @Transactional
public ShareholderDTO addInvestment(Long shareholderId, AddInvestmentDTO investmentDTO) {
    log.info("Adding investment for shareholder ID: {}", shareholderId);
    
    // Get shareholder
    Shareholder shareholder = shareholderRepository.findById(shareholderId)
            .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + shareholderId));
    
    String performedBy = getLoggedInUsername();
    Double amount = investmentDTO.getAmount();
    
    // Update shareholder investment and balance
    Double currentInvestment = shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0;
    Double currentBalance = shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0;
    
    shareholder.setInvestment(currentInvestment + amount);
    shareholder.setCurrentBalance(currentBalance + amount);
    
    Shareholder updatedShareholder = shareholderRepository.save(shareholder);
    
    // Update main balance
    updateMainBalanceForInvestment(amount, shareholder.getName(), performedBy);
    
    // Create transaction history
    createTransactionHistory(
        "INVESTMENT",
        amount,
        String.format("নতুন বিনিয়োগ: %s | পরিমাণ: ৳%.2f | %s", 
            shareholder.getName(), amount, investmentDTO.getDescription()),
        shareholderId,
        null,
        performedBy
    );
    
    // Create investment history
    InvestmentHistory history = InvestmentHistory.builder()
            .shareholderId(shareholderId)
            .amount(amount)
            .investmentDate(LocalDateTime.now())
            .description(investmentDTO.getDescription())
            .performedBy(performedBy)
            .build();
    
    investmentHistoryRepository.save(history);
    
    log.info("Investment added successfully for shareholder: {}", shareholder.getName());
    return shareholderMapper.toDTO(updatedShareholder);
}

public List<InvestmentHistoryDTO> getInvestmentHistory(Long shareholderId) {
    log.info("Fetching investment history for shareholder ID: {}", shareholderId);
    
    List<InvestmentHistory> histories = investmentHistoryRepository
            .findByShareholderIdOrderByInvestmentDateDesc(shareholderId);
    
    return histories.stream()
            .map(history -> InvestmentHistoryDTO.builder()
                    .id(history.getId())
                    .shareholderId(history.getShareholderId())
                    .amount(history.getAmount())
                    .investmentDate(history.getInvestmentDate())
                    .description(history.getDescription())
                    .performedBy(history.getPerformedBy())
                    .createdAt(history.getCreatedAt())
                    .build())
            .collect(Collectors.toList());
}
}