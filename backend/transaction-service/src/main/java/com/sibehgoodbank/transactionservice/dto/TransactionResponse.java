package com.sibehgoodbank.transactionservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponse {
    
    private UUID id;
    private String referenceNumber;
    private UUID userId;
    
    private String fromAccountNumber;
    private String toAccountNumber;
    private String toExternalAccount;
    private String toBankCode;
    private String beneficiaryName;
    
    private String transactionType;
    private String status;
    
    private BigDecimal amount;
    private BigDecimal convertedAmount;
    private String fromCurrency;
    private String toCurrency;
    private BigDecimal exchangeRate;
    
    private BigDecimal fee;
    private String feeType;
    
    private String description;
    private String remarks;
    private String channel;
    
    private Integer riskScore;
    private Boolean isFlagged;
    private String flagReason;
    private Boolean isReviewed;
    
    private BigDecimal balanceBefore;
    private BigDecimal balanceAfter;
    
    private LocalDateTime scheduledFor;
    private LocalDateTime processedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
