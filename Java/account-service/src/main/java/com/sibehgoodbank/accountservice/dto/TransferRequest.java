package com.sibehgoodbank.accountservice.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;

/**
 * Transfer request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransferRequest {

    @NotBlank(message = "Source account number is required")
    private String fromAccountNumber;

    @NotBlank(message = "Destination account number is required")
    private String toAccountNumber;

    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    @DecimalMin(value = "0.01", message = "Minimum transfer amount is 0.01")
    private BigDecimal amount;

    private String currency;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    private String reference;
}
