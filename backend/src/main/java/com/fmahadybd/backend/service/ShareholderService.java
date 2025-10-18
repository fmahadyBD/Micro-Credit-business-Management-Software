package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.repository.ShareholderRepository;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ShareholderService {

    private final ShareholderRepository shareholderRepository;

    public Shareholder saveShareholder(Shareholder shareholder) {
        return shareholderRepository.save(shareholder);
    }

    public List<Shareholder> getAllShareholders() {
        return shareholderRepository.findAll();
    }

    public Optional<Shareholder> getShareholderById(Long id) {
        return shareholderRepository.findById(id);
    }

    public void deleteShareholder(Long id) {
        shareholderRepository.deleteById(id);
    }
}
