package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.fmahadybd.backend.dto.InstallmentUpdateDTO;
import com.fmahadybd.backend.entity.Installment;
import com.fmahadybd.backend.repository.InstallmentRepository;

import jakarta.transaction.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class InstallmentService {

    private final InstallmentRepository installmentRepository;
    private final FileStorageService fileStorageService;
    private final PaymentScheduleService paymentScheduleService;

    public Installment save(Installment installment) {
        validateInstallment(installment);
        calculateInstallmentAmounts(installment);

        if (installment.getCreatedTime() == null) {
            installment.setCreatedTime(LocalDateTime.now());
        }

        Installment savedInstallment = installmentRepository.save(installment);

        paymentScheduleService.createPaymentSchedules(savedInstallment, savedInstallment.getGiven_product_agent());

        return savedInstallment;
    }

    public Installment saveWithImages(Installment installment, MultipartFile[] images) {
        Installment savedInstallment = save(installment);

        if (images != null && images.length > 0) {
            uploadInstallmentImages(images, savedInstallment.getId());
            savedInstallment = installmentRepository.findById(savedInstallment.getId()).orElse(savedInstallment);
        }

        return savedInstallment;
    }

    public void uploadInstallmentImages(MultipartFile[] files, Long installmentId) {
        Installment installment = installmentRepository.findById(installmentId)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + installmentId));

        List<String> savedFilePaths = new ArrayList<>();
        for (MultipartFile file : files) {
            if (!file.isEmpty()) {
                String filePath = fileStorageService.saveFile(file, installmentId);
                if (filePath != null)
                    savedFilePaths.add(filePath);
            }
        }

        List<String> currentPaths = installment.getImageFilePaths();
        if (currentPaths == null)
            currentPaths = new ArrayList<>();
        currentPaths.addAll(savedFilePaths);
        installment.setImageFilePaths(currentPaths);

        installmentRepository.save(installment);
    }

    public List<Installment> findAll() {
        return installmentRepository.findAll();
    }

    public Optional<Installment> findById(Long id) {
        return installmentRepository.findById(id);
    }

    @Transactional
    public Installment update(Long id, InstallmentUpdateDTO installmentDTO) {
        Installment existing = installmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));

        updateFields(existing, installmentDTO);
        calculateInstallmentAmounts(existing);

        return installmentRepository.save(existing);
    }

    private void updateFields(Installment existing, InstallmentUpdateDTO dto) {
        if (dto.getTotalAmountOfProduct() != null)
            existing.setTotalAmountOfProduct(dto.getTotalAmountOfProduct());
        if (dto.getOtherCost() != null)
            existing.setOtherCost(dto.getOtherCost());
        if (dto.getAdvanced_paid() != null)
            existing.setAdvanced_paid(dto.getAdvanced_paid());
        if (dto.getInstallmentMonths() != null)
            existing.setInstallmentMonths(dto.getInstallmentMonths());
        if (dto.getInterestRate() != null)
            existing.setInterestRate(dto.getInterestRate());
        if (dto.getStatus() != null)
            existing.setStatus(dto.getStatus());
    }

    public void delete(Long id) {
        Installment installment = installmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));
        installmentRepository.delete(installment);
    }

    public void deleteInstallmentImage(Long installmentId, String filePath) {
        Installment installment = installmentRepository.findById(installmentId)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + installmentId));

        List<String> paths = installment.getImageFilePaths();
        if (paths != null && paths.remove(filePath)) {
            installment.setImageFilePaths(paths);
            installmentRepository.save(installment);
        }
    }

    private void updateFields(Installment existing, Installment updated) {
        if (updated.getProduct() != null)
            existing.setProduct(updated.getProduct());
        if (updated.getMember() != null)
            existing.setMember(updated.getMember());
        if (updated.getTotalAmountOfProduct() != null)
            existing.setTotalAmountOfProduct(updated.getTotalAmountOfProduct());
        if (updated.getOtherCost() != null)
            existing.setOtherCost(updated.getOtherCost());
        if (updated.getAdvanced_paid() != null)
            existing.setAdvanced_paid(updated.getAdvanced_paid());
        if (updated.getInstallmentMonths() != null)
            existing.setInstallmentMonths(updated.getInstallmentMonths());
        if (updated.getInterestRate() != null)
            existing.setInterestRate(updated.getInterestRate());
        if (updated.getStatus() != null)
            existing.setStatus(updated.getStatus());
        if (updated.getGiven_product_agent() != null)
            existing.setGiven_product_agent(updated.getGiven_product_agent());
    }

    private void validateInstallment(Installment installment) {
        if (installment.getMember() == null)
            throw new IllegalArgumentException("Member is required");
        if (installment.getTotalAmountOfProduct() == null || installment.getTotalAmountOfProduct() < 0)
            throw new IllegalArgumentException("Valid total amount is required");
        if (installment.getInstallmentMonths() != null && installment.getInstallmentMonths() <= 0)
            throw new IllegalArgumentException("Installment months must be greater than 0");
    }

    private void calculateInstallmentAmounts(Installment installment) {
        Double total = installment.getTotalAmountOfProduct() != null ? installment.getTotalAmountOfProduct() : 0.0;
        Double other = installment.getOtherCost() != null ? installment.getOtherCost() : 0.0;
        Double advance = installment.getAdvanced_paid() != null ? installment.getAdvanced_paid() : 0.0;
        Double interest = installment.getInterestRate() != null ? installment.getInterestRate() : 15.0;

        Double totalWithInterest = total + (total * interest / 100);
        installment.setNeedPaidAmount(Math.max(totalWithInterest + other - advance, 0.0));
        installment.setTotalRemainingAmount(installment.getNeedPaidAmount());
    }
}
