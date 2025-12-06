package com.sibehgoodbank.accountservice.dto;

import com.sibehgoodbank.accountservice.entity.Account;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;

/**
 * Create account request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateAccountRequest {

    @NotBlank(message = "Account name is required")
    @Size(max = 100, message = "Account name must not exceed 100 characters")
    private String accountName;

    @NotNull(message = "Account type is required")
    private Account.AccountType accountType;

    private Account.Currency currency;

    @Positive(message = "Daily transfer limit must be positive")
    private BigDecimal dailyTransferLimit;
}
