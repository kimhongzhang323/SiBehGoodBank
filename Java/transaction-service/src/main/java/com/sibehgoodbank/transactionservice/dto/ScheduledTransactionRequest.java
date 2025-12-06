package com.sibehgoodbank.transactionservice.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduledTransactionRequest {
    
    @NotNull(message = "Source account number is required")
    private String fromAccountNumber;
    
    private String toAccountNumber;
    
    private String toExternalAccount;
    
    private String toBankCode;
    
    private String beneficiaryName;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;
    
    @NotNull(message = "Currency is required")
    private String currency;
    
    private String targetCurrency;
    
    @NotNull(message = "Scheduled date is required")
    @Future(message = "Scheduled date must be in the future")
    private LocalDateTime scheduledFor;
    
    private String description;
    
    private String remarks;
}
