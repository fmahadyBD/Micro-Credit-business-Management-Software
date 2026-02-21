package com.fmahadybd.backend.service;

import com.fmahadybd.backend.repository.TokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import jakarta.annotation.PostConstruct;

@Service
@RequiredArgsConstructor
public class TokenCleanupService {
    
    private final TokenRepository tokenRepository;
    private final TransactionTemplate transactionTemplate;
    
    @PostConstruct
    public void init() {
        // Cleanup on application startup with manual transaction
        transactionTemplate.execute(status -> {
            tokenRepository.deleteExpiredAndRevokedTokens();
            return null;
        });
    }
    
    @Scheduled(fixedRate = 3600000) // Run every hour
    @Transactional
    public void cleanupExpiredTokens() {
        tokenRepository.deleteExpiredAndRevokedTokens();
    }
}