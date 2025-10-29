package com.fmahadybd.backend.entity;

public enum WithdrawalStatus {
    PENDING,    // Request submitted, waiting approval
    APPROVED,   // Admin approved, ready for processing
    REJECTED,   // Admin rejected the request
    PROCESSED,  // Payment sent to shareholder
    CANCELLED   // Shareholder cancelled the request
}