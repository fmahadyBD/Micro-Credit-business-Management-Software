// ShareholderMapper.java
package com.fmahadybd.backend.mapper;

import com.fmahadybd.backend.dto.*;
import com.fmahadybd.backend.entity.Shareholder;

import java.time.LocalDate;

import org.springframework.stereotype.Component;

@Component
public class ShareholderMapper {

    public ShareholderDTO toDTO(Shareholder shareholder) {
        if (shareholder == null) {
            return null;
        }

        return ShareholderDTO.builder()
                .id(shareholder.getId())
                .name(shareholder.getName())
                .email(shareholder.getEmail())
                .phone(shareholder.getPhone())
                .nidCard(shareholder.getNidCard())
                .nominee(shareholder.getNominee())
                .zila(shareholder.getZila())
                .house(shareholder.getHouse())
                .investment(shareholder.getInvestment())
                .totalShare(shareholder.getTotalShare())
                .totalEarning(shareholder.getTotalEarning())
                .currentBalance(shareholder.getCurrentBalance())
                .role(shareholder.getRole())
                .status(shareholder.getStatus())
                .joinDate(shareholder.getJoinDate())
                .roi(shareholder.getROI())
                .totalValue(shareholder.getTotalValue())
                .build();
    }

    public Shareholder toEntity(ShareholderCreateDTO dto) {
        if (dto == null) {
            return null;
        }

        return Shareholder.builder()
                .name(dto.getName())
                .phone(dto.getPhone())
                .email(dto.getEmail())
                .nidCard(dto.getNidCard())
                .nominee(dto.getNominee())
                .zila(dto.getZila())
                .house(dto.getHouse())
                .investment(dto.getInvestment() != null ? dto.getInvestment() : 0.0)
                .totalShare(dto.getTotalShare() != null ? dto.getTotalShare() : 0)
                .totalEarning(dto.getTotalEarning() != null ? dto.getTotalEarning() : 0.0) // ✅ Fixed
                .currentBalance(dto.getCurrentBalance() != null ? dto.getCurrentBalance() : 0.0)
                .role(dto.getRole())
                .status(dto.getStatus() != null ? dto.getStatus() : "Active")
                .joinDate(dto.getJoinDate() != null ? dto.getJoinDate() : LocalDate.now())
                .build();
    }

    public Shareholder toEntity(ShareholderUpdateDTO dto, Shareholder existing) {
        if (dto == null || existing == null) {
            return existing;
        }

        if (dto.getName() != null) {
            existing.setName(dto.getName());
        }
        if (dto.getPhone() != null) {
            existing.setPhone(dto.getPhone());
        }
        if (dto.getEmail() != null) {
            existing.setEmail(dto.getEmail());
        }
        if (dto.getNidCard() != null) {
            existing.setNidCard(dto.getNidCard());
        }
        if (dto.getNominee() != null) {
            existing.setNominee(dto.getNominee());
        }
        if (dto.getZila() != null) {
            existing.setZila(dto.getZila());
        }
        if (dto.getHouse() != null) {
            existing.setHouse(dto.getHouse());
        }
        if (dto.getInvestment() != null) {
            existing.setInvestment(dto.getInvestment());
        }
        if (dto.getTotalShare() != null) {
            existing.setTotalShare(dto.getTotalShare());
        }
        if (dto.getTotalEarning() != null) {
            existing.setTotalEarning(dto.getTotalEarning());
        }
        if (dto.getCurrentBalance() != null) {
            existing.setCurrentBalance(dto.getCurrentBalance());
        }
        if (dto.getRole() != null) {
            existing.setRole(dto.getRole());
        }
        if (dto.getStatus() != null) {
            existing.setStatus(dto.getStatus());
        }
        if (dto.getJoinDate() != null) {
            existing.setJoinDate(dto.getJoinDate());
        }

        return existing;
    }

    public ShareholderDetailsDTO toDetailsDTO(Shareholder shareholder) {
        if (shareholder == null) {
            return null;
        }

        return ShareholderDetailsDTO.builder()
                .shareholder(toDTO(shareholder))
                .totalShares(shareholder.getTotalShare() != null ? shareholder.getTotalShare() : 0)
                .totalEarnings(shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0)
                .currentBalance(shareholder.getCurrentBalance() != null ? shareholder.getCurrentBalance() : 0.0)
                .activeSince(shareholder.getJoinDate())
                .investment(shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0)
                .totalValue(shareholder.getTotalValue())
                .build();
    }

    public DashboardMetricsDTO toDashboardMetrics(Shareholder shareholder) {
        if (shareholder == null) {
            return DashboardMetricsDTO.builder().build();
        }

        Double investment = shareholder.getInvestment() != null ? shareholder.getInvestment() : 0.0;
        Double totalEarning = shareholder.getTotalEarning() != null ? shareholder.getTotalEarning() : 0.0;

        DashboardMetricsDTO.DashboardMetricsDTOBuilder builder = DashboardMetricsDTO.builder();

        // ROI Calculation
        if (investment > 0) {
            double roi = (totalEarning / investment) * 100;
            builder.roiPercentage(Math.round(roi * 100.0) / 100.0);
        } else {
            builder.roiPercentage(0.0);
        }

        // Monthly average earning
        if (shareholder.getJoinDate() != null) {
            long monthsActive = java.time.temporal.ChronoUnit.MONTHS.between(
                    shareholder.getJoinDate(),
                    java.time.LocalDate.now());

            if (monthsActive > 0) {
                double monthlyAverage = totalEarning / monthsActive;
                builder.monthlyAverageEarning(Math.round(monthlyAverage * 100.0) / 100.0);
            } else {
                builder.monthlyAverageEarning(0.0);
            }
            builder.monthsActive(monthsActive);
        } else {
            builder.monthlyAverageEarning(0.0);
            builder.monthsActive(0L);
        }

        // Total value
        builder.totalValue(investment + totalEarning);

        return builder.build();
    }

    public ShareholderDashboardDTO toDashboardDTO(Shareholder shareholder) {
        if (shareholder == null) {
            return null;
        }

        return ShareholderDashboardDTO.builder()
                .basicInfo(toDTO(shareholder))
                .performanceMetrics(toDashboardMetrics(shareholder))
                .build();
    }
}