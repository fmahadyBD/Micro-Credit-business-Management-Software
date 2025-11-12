// ShareholderService.java (updated)
package com.fmahadybd.backend.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.dto.ShareholderCreateDTO;
import com.fmahadybd.backend.dto.ShareholderDTO;
import com.fmahadybd.backend.dto.ShareholderDashboardDTO;
import com.fmahadybd.backend.dto.ShareholderDetailsDTO;
import com.fmahadybd.backend.dto.ShareholderUpdateDTO;
import com.fmahadybd.backend.dto.StatisticsDTO;
import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.mapper.ShareholderMapper;
import com.fmahadybd.backend.repository.MainBalanceRepository;
import com.fmahadybd.backend.repository.ShareholderRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShareholderService {

    private final ShareholderRepository shareholderRepository;
    private final ShareholderMapper shareholderMapper;
    private final MainBalanceService mainBalanceService;
    private final MainBalanceRepository mainBalanceRepository;

    // @Transactional
    // public ShareholderDTO saveShareholder(ShareholderCreateDTO shareholderDTO) {
    // if (shareholderDTO == null) {
    // throw new IllegalArgumentException("Shareholder data cannot be null");
    // }

    // log.info("Saving shareholder: {}", shareholderDTO.getName());

    // // Convert DTO to entity
    // Shareholder shareholder = shareholderMapper.toEntity(shareholderDTO);

    // // Save shareholder
    // Shareholder savedShareholder = shareholderRepository.save(shareholder);
    // log.info("Successfully saved shareholder with id: {}",
    // savedShareholder.getId());

    // // Update MainBalance totals
    // MainBalance mb = getMainBalance();
    // double investment = savedShareholder.getInvestment();

    // mb.setTotalInvestment(mb.getTotalInvestment() + investment);
    // mb.setTotalBalance(mb.getTotalBalance() + investment);
    // mainBalanceRepository.save(mb);

    // // Return DTO
    // return shareholderMapper.toDTO(savedShareholder);
    // }
    @Transactional
    public ShareholderDTO saveShareholder(ShareholderCreateDTO shareholderDTO) {
        if (shareholderDTO == null) {
            throw new IllegalArgumentException("Shareholder data cannot be null");
        }

        log.info("Saving shareholder: {}", shareholderDTO.getName());

        // Convert DTO to entity
        Shareholder shareholder = shareholderMapper.toEntity(shareholderDTO);

        // ✅ FORCEFUL NULL CHECK - Add this right before save
        if (shareholder.getTotalEarning() == null) {
            shareholder.setTotalEarning(0.0);
            log.warn("totalEarning was null, forced to 0.0");
        }
        if (shareholder.getTotalShare() == null) {
            shareholder.setTotalShare(0);
            log.warn("totalShare was null, forced to 0");
        }
        if (shareholder.getCurrentBalance() == null) {
            shareholder.setCurrentBalance(0.0);
            log.warn("currentBalance was null, forced to 0.0");
        }

        // Debug log to verify values
        log.debug("Before save - totalEarning: {}, totalShare: {}, currentBalance: {}",
                shareholder.getTotalEarning(), shareholder.getTotalShare(), shareholder.getCurrentBalance());

        // Save shareholder
        Shareholder savedShareholder = shareholderRepository.save(shareholder);
        log.info("Successfully saved shareholder with id: {}", savedShareholder.getId());

        // Update MainBalance totals
        MainBalance mb = getMainBalance();
        double investment = savedShareholder.getInvestment();

        mb.setTotalInvestment(mb.getTotalInvestment() + investment);
        mb.setTotalBalance(mb.getTotalBalance() + investment);
        mainBalanceRepository.save(mb);

        return shareholderMapper.toDTO(savedShareholder);
    }

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

    @Transactional
    public ShareholderDTO updateShareholder(Long id, ShareholderUpdateDTO shareholderDTO) {
        log.info("Updating shareholder with id: {}", id);

        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

        if (shareholderDTO == null) {
            throw new IllegalArgumentException("Shareholder details cannot be null");
        }

        // Fetch existing shareholder
        Shareholder shareholder = shareholderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));

        MainBalance mb = getMainBalance();
        double oldInvestment = shareholder.getInvestment();
        double newInvestment = shareholderDTO.getInvestment();

        // Calculate the difference
        double difference = newInvestment - oldInvestment;

        // Update MainBalance totals based on change
        mb.setTotalInvestment(mb.getTotalInvestment() + difference);
        mb.setTotalBalance(mb.getTotalBalance() + difference);
        mainBalanceRepository.save(mb);

        // Update shareholder entity
        Shareholder updatedEntity = shareholderMapper.toEntity(shareholderDTO, shareholder);
        Shareholder savedShareholder = shareholderRepository.save(updatedEntity);

        log.info("Successfully updated shareholder with id: {}", id);

        return shareholderMapper.toDTO(savedShareholder);
    }

    @Transactional
    public void deleteShareholder(Long id) {
        log.info("Deleting shareholder with id: {}", id);

        if (id == null) {
            throw new IllegalArgumentException("Shareholder ID cannot be null");
        }

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

        shareholderRepository.deleteById(id);
        log.info("Successfully deleted shareholder with id: {}", id);
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

    private MainBalance getMainBalance() {
        return mainBalanceRepository.findAll().stream().findFirst()
                .orElseGet(() -> mainBalanceRepository.save(
                        MainBalance.builder()
                                .totalBalance(0.0)
                                .totalInvestment(0.0)
                                .totalWithdrawal(0.0)
                                .totalProductCost(0.0)
                                .totalMaintenanceCost(0.0)
                                .totalInstallmentReturn(0.0)
                                .totalEarnings(0.0) 
                                .build()));
    }

    @Transactional(readOnly = true)
    public ShareholderDTO getShareholderByUserId(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }

        log.info("Fetching shareholder for user ID: {}", userId);

        // If you have a userId field in Shareholder entity:
        // Shareholder shareholder = shareholderRepository.findByUserId(userId)
        // .orElseThrow(() -> new RuntimeException("Shareholder not found for user ID: "
        // + userId));

        // If you need to add userId field to Shareholder entity:
        // Add this to Shareholder.java:
        // @Column(name = "user_id", unique = true)
        // private Long userId;

        // For now, using a workaround if you don't have userId field:
        // You'll need to add this query to ShareholderRepository
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

}