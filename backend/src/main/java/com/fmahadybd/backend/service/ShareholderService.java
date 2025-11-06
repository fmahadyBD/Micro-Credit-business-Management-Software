// ShareholderService.java (updated)
package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fmahadybd.backend.dto.*;
import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.mapper.ShareholderMapper;
import com.fmahadybd.backend.repository.ShareholderRepository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShareholderService {

    private final ShareholderRepository shareholderRepository;
    private final ShareholderMapper shareholderMapper;

    @Transactional
    public ShareholderDTO saveShareholder(ShareholderCreateDTO shareholderDTO) {
        log.info("Saving shareholder: {}", shareholderDTO.getName());

        // Validate DTO
        if (shareholderDTO == null) {
            throw new IllegalArgumentException("Shareholder data cannot be null");
        }

        // Convert DTO to entity
        Shareholder shareholder = shareholderMapper.toEntity(shareholderDTO);
        
        // Save entity
        Shareholder saved = shareholderRepository.save(shareholder);
        log.info("Successfully saved shareholder with id: {}", saved.getId());
        
        // Convert back to DTO for response
        return shareholderMapper.toDTO(saved);
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

        return shareholderRepository.findById(id)
                .map(existing -> {
                    // Update entity with DTO data
                    Shareholder updatedEntity = shareholderMapper.toEntity(shareholderDTO, existing);
                    Shareholder saved = shareholderRepository.save(updatedEntity);
                    log.info("Successfully updated shareholder with id: {}", id);
                    return shareholderMapper.toDTO(saved);
                })
                .orElseThrow(() -> new RuntimeException("Shareholder not found with id: " + id));
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
}