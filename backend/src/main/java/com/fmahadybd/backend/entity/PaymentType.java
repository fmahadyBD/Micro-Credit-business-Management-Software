package com.fmahadybd.backend.entity;

public enum PaymentType {
    PAYMENT,        // Regular payment
    PARTIAL_PAYMENT,// Partial payment
    ADVANCE_PAYMENT,// Advance payment for future
    REFUND,         // Money returned
    ADJUSTMENT,     // Amount adjustment
    PENALTY,        // Late payment penalty
    DISCOUNT        // Payment discount
}