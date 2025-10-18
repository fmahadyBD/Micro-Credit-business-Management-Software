package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fmahadybd.backend.entity.Installment;
import com.fmahadybd.backend.service.InstallmentService;

import java.util.List;

@RestController
@RequestMapping("/api/installments")
@RequiredArgsConstructor
public class InstallmentController {

    private final InstallmentService installmentService;

    @PostMapping
    public ResponseEntity<Installment> createInstallment(@RequestBody Installment installment) {
        return ResponseEntity.ok(installmentService.saveInstallment(installment));
    }

    @GetMapping
    public ResponseEntity<List<Installment>> getAllInstallments() {
        return ResponseEntity.ok(installmentService.getAllInstallments());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Installment> getInstallmentById(@PathVariable Long id) {
        return installmentService.getInstallmentById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteInstallment(@PathVariable Long id) {
        installmentService.deleteInstallment(id);
        return ResponseEntity.noContent().build();
    }
}