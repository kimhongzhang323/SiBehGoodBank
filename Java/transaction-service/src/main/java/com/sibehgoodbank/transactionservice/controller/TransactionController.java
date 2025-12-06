package com.sibehgoodbank.transactionservice.controller;

import com.sibehgoodbank.common.dto.ApiResponse;
import com.sibehgoodbank.transactionservice.dto.*;
import com.sibehgoodbank.transactionservice.entity.Transaction.TransactionStatus;
import com.sibehgoodbank.transactionservice.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
@Tag(name = "Transaction Management", description = "APIs for managing transactions")
public class TransactionController {
    
    private final TransactionService transactionService;
    
    @PostMapping
    @Operation(summary = "Create a new transaction")
    public ResponseEntity<ApiResponse<TransactionResponse>> createTransaction(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody CreateTransactionRequest request) {
        log.info("Creating transaction for user: {}", userId);
        TransactionResponse response = transactionService.createTransaction(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Transaction created successfully"));
    }
    
    @PostMapping("/scheduled")
    @Operation(summary = "Create a scheduled transaction")
    public ResponseEntity<ApiResponse<TransactionResponse>> createScheduledTransaction(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody ScheduledTransactionRequest request) {
        log.info("Creating scheduled transaction for user: {} at: {}", userId, request.getScheduledFor());
        TransactionResponse response = transactionService.createScheduledTransaction(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Scheduled transaction created successfully"));
    }
    
    @GetMapping("/{transactionId}")
    @Operation(summary = "Get transaction by ID")
    public ResponseEntity<ApiResponse<TransactionResponse>> getTransactionById(
            @PathVariable UUID transactionId) {
        TransactionResponse response = transactionService.getTransactionById(transactionId);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @GetMapping("/reference/{referenceNumber}")
    @Operation(summary = "Get transaction by reference number")
    public ResponseEntity<ApiResponse<TransactionResponse>> getTransactionByReference(
            @PathVariable String referenceNumber) {
        TransactionResponse response = transactionService.getTransactionByReference(referenceNumber);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @GetMapping("/user/{userId}")
    @Operation(summary = "Get transactions by user ID")
    public ResponseEntity<ApiResponse<Page<TransactionResponse>>> getTransactionsByUser(
            @PathVariable UUID userId,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<TransactionResponse> transactions = transactionService.getTransactionsByUser(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }
    
    @GetMapping("/account/{accountId}")
    @Operation(summary = "Get transactions by account ID")
    public ResponseEntity<ApiResponse<Page<TransactionResponse>>> getTransactionsByAccount(
            @PathVariable UUID accountId,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<TransactionResponse> transactions = transactionService.getTransactionsByAccount(accountId, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }
    
    @GetMapping("/account/{accountId}/range")
    @Operation(summary = "Get transactions by account and date range")
    public ResponseEntity<ApiResponse<Page<TransactionResponse>>> getTransactionsByAccountAndDateRange(
            @PathVariable UUID accountId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<TransactionResponse> transactions = transactionService.getTransactionsByAccountAndDateRange(
                accountId, startDate, endDate, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }
    
    @PostMapping("/fraud-check")
    @Operation(summary = "Check transaction for fraud")
    public ResponseEntity<ApiResponse<FraudCheckResult>> checkForFraud(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody CreateTransactionRequest request) {
        FraudCheckResult result = transactionService.checkForFraud(request, userId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @GetMapping("/flagged")
    @PreAuthorize("hasRole('ADMIN') or hasRole('COMPLIANCE')")
    @Operation(summary = "Get flagged transactions for review (Admin/Compliance only)")
    public ResponseEntity<ApiResponse<Page<TransactionResponse>>> getFlaggedTransactions(
            @PageableDefault(size = 20, sort = "riskScore", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<TransactionResponse> transactions = transactionService.getFlaggedTransactions(pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }
    
    @PostMapping("/{transactionId}/review")
    @PreAuthorize("hasRole('ADMIN') or hasRole('COMPLIANCE')")
    @Operation(summary = "Review a flagged transaction (Admin/Compliance only)")
    public ResponseEntity<ApiResponse<TransactionResponse>> reviewTransaction(
            @PathVariable UUID transactionId,
            @RequestHeader("X-User-Id") UUID reviewerId,
            @RequestParam boolean approved,
            @RequestParam(required = false) String notes) {
        TransactionResponse response = transactionService.reviewTransaction(transactionId, reviewerId, approved, notes);
        return ResponseEntity.ok(ApiResponse.success(response, approved ? "Transaction approved" : "Transaction rejected"));
    }
    
    @PutMapping("/{transactionId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update transaction status (Admin only)")
    public ResponseEntity<ApiResponse<TransactionResponse>> updateTransactionStatus(
            @PathVariable UUID transactionId,
            @RequestParam TransactionStatus status,
            @RequestParam(required = false) String reason) {
        TransactionResponse response = transactionService.updateTransactionStatus(transactionId, status, reason);
        return ResponseEntity.ok(ApiResponse.success(response, "Transaction status updated"));
    }
    
    @PostMapping("/{transactionId}/reverse")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Reverse a transaction (Admin only)")
    public ResponseEntity<ApiResponse<TransactionResponse>> reverseTransaction(
            @PathVariable UUID transactionId,
            @RequestParam String reason) {
        TransactionResponse response = transactionService.reverseTransaction(transactionId, reason);
        return ResponseEntity.ok(ApiResponse.success(response, "Transaction reversed successfully"));
    }
    
    @GetMapping("/analytics/{userId}")
    @Operation(summary = "Get transaction analytics for a user")
    public ResponseEntity<ApiResponse<TransactionAnalytics>> getTransactionAnalytics(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        TransactionAnalytics analytics = transactionService.getTransactionAnalytics(userId, startDate, endDate);
        return ResponseEntity.ok(ApiResponse.success(analytics));
    }
    
    @GetMapping("/stats/daily/{userId}")
    @Operation(summary = "Get daily transaction stats for a user")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDailyStats(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        Map<String, Object> stats = transactionService.getDailyStats(userId, startDate, endDate);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @PostMapping("/status/batch")
    @Operation(summary = "Get status of multiple transactions")
    public ResponseEntity<ApiResponse<List<TransactionStatusResponse>>> getTransactionStatuses(
            @RequestBody List<String> referenceNumbers) {
        List<TransactionStatusResponse> statuses = transactionService.getTransactionStatuses(referenceNumbers);
        return ResponseEntity.ok(ApiResponse.success(statuses));
    }
}
