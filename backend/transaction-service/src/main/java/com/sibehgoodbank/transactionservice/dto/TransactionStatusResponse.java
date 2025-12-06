package com.sibehgoodbank.transactionservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionStatusResponse {
    
    private String referenceNumber;
    private String status;
    private String statusDescription;
}
