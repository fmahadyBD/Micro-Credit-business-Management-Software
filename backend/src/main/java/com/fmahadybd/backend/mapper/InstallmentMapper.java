package com.fmahadybd.backend.mapper;

import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;
import com.fmahadybd.backend.dto.InstallmentResponseDTO;
import com.fmahadybd.backend.entity.Installment;

@Component
public class InstallmentMapper {

    public InstallmentResponseDTO toResponseDTO(Installment installment) {
        if (installment == null) {
            return null;
        }

        return InstallmentResponseDTO.builder()
                .id(installment.getId())
                .product(installment.getProduct())
                .member(installment.getMember())
                .totalAmountOfProduct(installment.getTotalAmountOfProduct())
                .otherCost(installment.getOtherCost())
                .advanced_paid(installment.getAdvanced_paid())
                .needPaidAmount(installment.getNeedPaidAmount())
                .installmentMonths(installment.getInstallmentMonths())
                .interestRate(installment.getInterestRate())
                .status(installment.getStatus())
                .imageFilePaths(installment.getImageFilePaths())
                .given_product_agent(installment.getGiven_product_agent())
                // .createdTime(installment.getCreatedTime())
                .paymentSchedules(installment.getPaymentSchedules())
                .monthlyInstallmentAmount(installment.getMonthlyInstallmentAmount())
                .totalAmountWithInterest(installment.getTotalAmountWithInterest())  // ✅ FIXED!
                .build();
    }

    public List<InstallmentResponseDTO> toResponseDTOList(List<Installment> installments) {
        if (installments == null) return List.of();
        
        return installments.stream()
                .map(this::toResponseDTO)
                .collect(Collectors.toList());
    }
}