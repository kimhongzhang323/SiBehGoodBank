package com.sibehgoodbank.transactionservice.service;

import com.sibehgoodbank.transactionservice.dto.*;
import com.sibehgoodbank.transactionservice.entity.Transaction;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public interface TransactionService {
    
    // Transaction creation
    TransactionResponse createTransaction(UUID userId, CreateTransactionRequest request);
    
    TransactionResponse createScheduledTransaction(UUID userId, ScheduledTransactionRequest request);
    
    // Transaction queries
    TransactionResponse getTransactionById(UUID transactionId);
    
    TransactionResponse getTransactionByReference(String referenceNumber);
    
    Page<TransactionResponse> getTransactionsByUser(UUID userId, Pageable pageable);
    
    Page<TransactionResponse> getTransactionsByAccount(UUID accountId, Pageable pageable);
    
    Page<TransactionResponse> getTransactionsByAccountAndDateRange(
            UUID accountId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    // Transaction status
    TransactionResponse updateTransactionStatus(UUID transactionId, Transaction.TransactionStatus status, String reason);
    
    void processScheduledTransactions();
    
    void expireOldPendingTransactions();
    
    // Fraud detection
    FraudCheckResult checkForFraud(CreateTransactionRequest request, UUID userId);
    
    Page<TransactionResponse> getFlaggedTransactions(Pageable pageable);
    
    TransactionResponse reviewTransaction(UUID transactionId, UUID reviewerId, boolean approved, String notes);
    
    // Analytics
    TransactionAnalytics getTransactionAnalytics(UUID userId, LocalDateTime startDate, LocalDateTime endDate);
    
    Map<String, Object> getDailyStats(UUID userId, LocalDateTime startDate, LocalDateTime endDate);
    
    // Bulk operations
    List<TransactionStatusResponse> getTransactionStatuses(List<String> referenceNumbers);
    
    // Reversal
    TransactionResponse reverseTransaction(UUID transactionId, String reason);
}
