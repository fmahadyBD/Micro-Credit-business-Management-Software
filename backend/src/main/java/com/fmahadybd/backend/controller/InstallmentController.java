package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fmahadybd.backend.dto.InstallmentUpdateDTO;
import com.fmahadybd.backend.entity.Installment;
import com.fmahadybd.backend.service.InstallmentService;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/installments")
@RequiredArgsConstructor
public class InstallmentController {

    private final InstallmentService installmentService;

    @PostMapping
    public ResponseEntity<Installment> createInstallment(@Valid @RequestBody Installment installment) {
        Installment savedInstallment = installmentService.save(installment);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedInstallment);
    }

    @PostMapping(value = "/with-images", consumes = "multipart/form-data")
    public ResponseEntity<Installment> createInstallmentWithImages(
            @RequestPart("installment") @Valid Installment installment,
            @RequestPart(value = "images", required = false) MultipartFile[] images) {

        Installment savedInstallment = installmentService.saveWithImages(installment, images);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedInstallment);
    }

    @PostMapping(value = "/{id}/images", consumes = "multipart/form-data")
    public ResponseEntity<Void> uploadInstallmentImages(
            @PathVariable Long id,
            @RequestPart("images") MultipartFile[] images) {

        installmentService.uploadInstallmentImages(images, id);
        return ResponseEntity.accepted().build();
    }

    @GetMapping
    public ResponseEntity<List<Installment>> getAllInstallments() {
        return ResponseEntity.ok(installmentService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Installment> getInstallmentById(@PathVariable Long id) {
        Installment installment = installmentService.findById(id)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));
        return ResponseEntity.ok(installment);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Installment> updateInstallment(
            @PathVariable Long id,
            @Valid @RequestBody InstallmentUpdateDTO installmentDTO) {

        Installment updatedInstallment = installmentService.update(id, installmentDTO);
        return ResponseEntity.ok(updatedInstallment);
    }

    // @DeleteMapping("/{id}")
    // public ResponseEntity<Void> deleteInstallment(@PathVariable Long id) {
    //     installmentService.delete(id);
    //     return ResponseEntity.noContent().build();
    // }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteInstallment(@PathVariable Long id) {
        try {
            installmentService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Installment not found", "message", e.getMessage()));
        }
    }

    @GetMapping("/{id}/images")
    public ResponseEntity<?> getInstallmentImages(@PathVariable Long id) {
        try {
            Installment installment = installmentService.findById(id)
                    .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));
            return ResponseEntity.ok(installment.getImageFilePaths());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Installment not found", "message", e.getMessage()));
        }
    }
}
