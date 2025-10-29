package com.fmahadybd.backend.entity;

public enum TransactionStatus {
    PENDING,      // Transaction requested but not processed
    COMPLETED,    // Transaction successfully completed
    CANCELLED,    // Transaction was cancelled
    FAILED        // Transaction failed (payment issues, etc.)
}