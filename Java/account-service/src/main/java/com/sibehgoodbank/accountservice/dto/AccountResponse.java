package com.sibehgoodbank.accountservice.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Account response DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountResponse {
    private UUID id;
    private UUID userId;
    private String accountNumber;
    private String accountName;
    private String accountType;
    private String currency;
    private BigDecimal balance;
    private BigDecimal availableBalance;
    private BigDecimal pendingBalance;
    private BigDecimal dailyTransferLimit;
    private BigDecimal dailyTransferUsed;
    private String status;
    private boolean isPrimary;
    private LocalDateTime createdAt;
    private LocalDateTime lastTransactionAt;
}
