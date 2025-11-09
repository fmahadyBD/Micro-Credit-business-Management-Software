package com.fmahadybd.backend.mapper;

import com.fmahadybd.backend.dto.MainBalanceResponseDTO;
import com.fmahadybd.backend.dto.TransactionHistoryResponseDTO;
import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.entity.TransactionHistory;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class MainBalanceMapper {

    public MainBalanceResponseDTO toResponseDTO(MainBalance entity) {
        return MainBalanceResponseDTO.builder()
                .id(entity.getId())
                .totalBalance(entity.getTotalBalance())
                .totalInvestment(entity.getTotalInvestment())
                .totalWithdrawal(entity.getTotalWithdrawal())
                .totalProductCost(entity.getTotalProductCost())
                .totalMaintenanceCost(entity.getTotalMaintenanceCost())
                .totalInstallmentReturn(entity.getTotalInstallmentReturn())
                .earnings(entity.getTotalEarnings())
                .lastUpdated(LocalDateTime.now())
                .message("Success")
                .build();
    }

    public MainBalanceResponseDTO toResponseDTO(MainBalance entity, String message) {
        MainBalanceResponseDTO dto = toResponseDTO(entity);
        dto.setMessage(message);
        return dto;
    }

    public TransactionHistoryResponseDTO toTransactionDTO(TransactionHistory entity) {
        return TransactionHistoryResponseDTO.builder()
                .id(entity.getId())
                .type(entity.getType())
                .amount(entity.getAmount())
                .description(entity.getDescription())
                .timestamp(entity.getTimestamp())
                // .shareholderId(entity.getShareholder() != null ? entity.getShareholder().getId() : null)
                // .shareholderName(entity.getShareholder() != null ? entity.getShareholder().getName() : null)
                .build();
    }

    public List<TransactionHistoryResponseDTO> toTransactionDTOList(List<TransactionHistory> entities) {
        return entities.stream()
                .map(this::toTransactionDTO)
                .collect(Collectors.toList());
    }
}