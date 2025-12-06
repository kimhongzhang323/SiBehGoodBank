package com.sibehgoodbank.transactionservice.dto;

import com.sibehgoodbank.transactionservice.entity.Transaction.Currency;
import com.sibehgoodbank.transactionservice.entity.Transaction.TransactionChannel;
import com.sibehgoodbank.transactionservice.entity.Transaction.TransactionType;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateTransactionRequest {
    
    @NotNull(message = "Source account number is required")
    @Size(min = 10, max = 20, message = "Invalid account number format")
    private String fromAccountNumber;
    
    @Size(min = 10, max = 50, message = "Invalid destination account number")
    private String toAccountNumber;
    
    @Size(max = 50, message = "External account number too long")
    private String toExternalAccount;
    
    @Size(max = 20, message = "Bank code too long")
    private String toBankCode;
    
    @Size(max = 100, message = "Beneficiary name too long")
    private String beneficiaryName;
    
    @NotNull(message = "Transaction type is required")
    private TransactionType transactionType;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    @DecimalMax(value = "1000000000", message = "Amount exceeds maximum limit")
    private BigDecimal amount;
    
    @NotNull(message = "Currency is required")
    private Currency currency;
    
    private Currency targetCurrency;
    
    @Size(max = 500, message = "Description too long")
    private String description;
    
    @Size(max = 500, message = "Remarks too long")
    private String remarks;
    
    private TransactionChannel channel;
    
    private String ipAddress;
    
    private String deviceId;
    
    private String deviceType;
    
    private String location;
    
    // For idempotency
    @Size(max = 100, message = "External reference too long")
    private String externalReferenceId;
}
