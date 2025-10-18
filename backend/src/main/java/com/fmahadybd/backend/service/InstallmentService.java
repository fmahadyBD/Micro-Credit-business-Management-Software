package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.fmahadybd.backend.entity.Installment;
import com.fmahadybd.backend.repository.InstallmentRepository;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class InstallmentService {

    private final InstallmentRepository installmentRepository;

    public Installment saveInstallment(Installment installment) {
        return installmentRepository.save(installment);
    }

    public List<Installment> getAllInstallments() {
        return installmentRepository.findAll();
    }

    public Optional<Installment> getInstallmentById(Long id) {
        return installmentRepository.findById(id);
    }

    public void deleteInstallment(Long id) {
        installmentRepository.deleteById(id);
    }
}