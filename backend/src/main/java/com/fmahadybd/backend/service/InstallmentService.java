package com.fmahadybd.backend.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.stereotype.Service;
// import jakarta.transaction.Transactional;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.fmahadybd.backend.dto.InstallmentResponseDTO;
import com.fmahadybd.backend.dto.InstallmentUpdateDTO;
import com.fmahadybd.backend.entity.Installment;
import com.fmahadybd.backend.entity.Product;
import com.fmahadybd.backend.mapper.InstallmentMapper;
import com.fmahadybd.backend.repository.InstallmentRepository;
import com.fmahadybd.backend.repository.ProductRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class InstallmentService {

    private final InstallmentRepository installmentRepository;
    private final FileStorageService fileStorageService;
    private final InstallmentMapper installmentMapper;
    private final ProductService productService;
    private final ProductRepository productRepository;

    private final String folder = "installment";

    public Installment save(Installment installment) {
        validateInstallment(installment);
        calculateInstallmentAmounts(installment);

        if (installment.getCreatedTime() == null) {
            installment.setCreatedTime(LocalDateTime.now());
        }

        Long productId = installment.getProduct().getId();

        try {
            Product product = productService.getProductById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found with ID: " + productId));

            product.setIsDeliveryRequired(true);
            productRepository.save(product);

        } catch (Exception e) {
            System.err.println("Error updating product delivery requirement: " + e.getMessage());
        }

        Installment savedInstallment = installmentRepository.save(installment);

        return savedInstallment;
    }

    public Installment saveWithImages(Installment installment, MultipartFile[] images) {
        // Ensure product requires delivery
        setProductDeliveryRequired(installment);

        // Save installment first
        Installment savedInstallment = save(installment);

        // Upload images if any
        if (images != null && images.length > 0) {
            uploadInstallmentImages(images, savedInstallment.getId());
            savedInstallment = installmentRepository.findById(savedInstallment.getId())
                    .orElse(savedInstallment);
        }

        return savedInstallment;
    }

    public void uploadInstallmentImages(MultipartFile[] files, Long installmentId) {
        Installment installment = installmentRepository.findById(installmentId)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + installmentId));

        List<String> savedFilePaths = new ArrayList<>();
        for (MultipartFile file : files) {
            if (!file.isEmpty()) {
                String filePath = fileStorageService.saveFile(file, installmentId, folder);
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

    }

    private void setProductDeliveryRequired(Installment installment) {
        Product product = installment.getProduct();
        if (product != null) {
            product.setIsDeliveryRequired(true);
        }
    }

    @Transactional(readOnly = true)
    public List<InstallmentResponseDTO> searchInstallments(String keyword) {
        List<Installment> results = installmentRepository.searchInstallments(keyword);
        return installmentMapper.toResponseDTOList(results);
    }

    @Transactional(readOnly = true)
    public List<InstallmentResponseDTO> findAll() {
        List<Installment> installments = installmentRepository.findAll();
        return installmentMapper.toResponseDTOList(installments);
    }

    @Transactional(readOnly = true)
    public Optional<InstallmentResponseDTO> findById(Long id) {
        return installmentRepository.findById(id)
                .map(installmentMapper::toResponseDTO);
    }

    // Internal method - returns entity (for image operations)
    public Optional<Installment> findEntityById(Long id) {
        return installmentRepository.findById(id);
    }

    @Transactional
    public InstallmentResponseDTO update(Long id, InstallmentUpdateDTO installmentDTO) {
        Installment existing = installmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));

        updateFields(existing, installmentDTO);
        calculateInstallmentAmounts(existing);

        Installment updated = installmentRepository.save(existing);
        return installmentMapper.toResponseDTO(updated);
    }

}
