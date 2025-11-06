package com.fmahadybd.backend.scheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.fmahadybd.backend.dto.MainBalanceResponseDTO;
import com.fmahadybd.backend.service.MainBalanceService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@RequiredArgsConstructor
public class MonthlySummaryScheduler {

    private final MainBalanceService mainBalanceService;

    // Runs on the 1st day of every month at 12:05 AM
    @Scheduled(cron = "0 5 0 1 * *")
    public void generateMonthlySummary() {
        MainBalanceResponseDTO mb = mainBalanceService.getBalance();
        log.info("📅 Monthly Summary Generated:");
        log.info("Total Balance: {}", mb.getTotalBalance());
        log.info("Total Investment: {}", mb.getTotalInvestment());
        // log.info("Total Expenses: {}", mb.getTotalExpenses());
        log.info("Earnings: {}", mb.getEarnings());
    }
}
