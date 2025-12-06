package com.sibehgoodbank.accountservice.controller;

import com.sibehgoodbank.accountservice.dto.*;
import com.sibehgoodbank.accountservice.service.AccountService;
import com.sibehgoodbank.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Account management REST controller
 */
@RestController
@RequestMapping("/api/v1/accounts")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Accounts", description = "Bank account management APIs")
@SecurityRequirement(name = "bearerAuth")
public class AccountController {

    private final AccountService accountService;

    @PostMapping
    @Operation(summary = "Create account", description = "Create a new bank account")
    public ResponseEntity<ApiResponse<AccountResponse>> createAccount(
            @RequestHeader("X-User-Id") String userId,
            @Valid @RequestBody CreateAccountRequest request) {
        
        AccountResponse account = accountService.createAccount(UUID.fromString(userId), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(account));
    }

    @GetMapping
    @Operation(summary = "Get user accounts", description = "Get all accounts for current user")
    public ResponseEntity<ApiResponse<List<AccountResponse>>> getUserAccounts(
            @RequestHeader("X-User-Id") String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        if (size > 100) size = 100; // Max page size
        
        Page<AccountResponse> accounts = accountService.getAccountsByUserId(
                UUID.fromString(userId), PageRequest.of(page, size));
        
        return ResponseEntity.ok(ApiResponse.success(accounts.getContent()));
    }

    @GetMapping("/{accountId}")
    @Operation(summary = "Get account", description = "Get account details by ID")
    public ResponseEntity<ApiResponse<AccountResponse>> getAccount(
            @PathVariable UUID accountId) {
        
        AccountResponse account = accountService.getAccountById(accountId);
        return ResponseEntity.ok(ApiResponse.success(account));
    }

    @GetMapping("/by-number/{accountNumber}")
    @Operation(summary = "Get account by number", description = "Get account by account number")
    public ResponseEntity<ApiResponse<AccountResponse>> getAccountByNumber(
            @PathVariable String accountNumber) {
        
        AccountResponse account = accountService.getAccountByNumber(accountNumber);
        return ResponseEntity.ok(ApiResponse.success(account));
    }

    @PostMapping("/{accountId}/debit")
    @Operation(summary = "Debit account", description = "Withdraw funds from account")
    public ResponseEntity<ApiResponse<AccountResponse>> debit(
            @PathVariable UUID accountId,
            @RequestParam BigDecimal amount,
            @RequestParam(required = false) String reference) {
        
        AccountResponse account = accountService.debit(accountId, amount, reference);
        return ResponseEntity.ok(ApiResponse.success(account));
    }

    @PostMapping("/{accountId}/credit")
    @Operation(summary = "Credit account", description = "Deposit funds to account")
    public ResponseEntity<ApiResponse<AccountResponse>> credit(
            @PathVariable UUID accountId,
            @RequestParam BigDecimal amount,
            @RequestParam(required = false) String reference) {
        
        AccountResponse account = accountService.credit(accountId, amount, reference);
        return ResponseEntity.ok(ApiResponse.success(account));
    }

    @PostMapping("/transfer")
    @Operation(summary = "Transfer funds", description = "Transfer between accounts")
    public ResponseEntity<ApiResponse<TransferResponse>> transfer(
            @Valid @RequestBody TransferRequest request) {
        
        TransferResponse response = accountService.transfer(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/{accountId}/daily-limit")
    @Operation(summary = "Update daily limit", description = "Update daily transfer limit")
    public ResponseEntity<ApiResponse<AccountResponse>> updateDailyLimit(
            @PathVariable UUID accountId,
            @RequestParam BigDecimal limit) {
        
        AccountResponse account = accountService.updateDailyLimit(accountId, limit);
        return ResponseEntity.ok(ApiResponse.success(account));
    }

    @GetMapping("/total-balance")
    @Operation(summary = "Get total balance", description = "Get total balance across all accounts by currency")
    public ResponseEntity<ApiResponse<Map<String, BigDecimal>>> getTotalBalance(
            @RequestHeader("X-User-Id") String userId) {
        
        Map<String, BigDecimal> balances = accountService.getTotalBalanceByUser(UUID.fromString(userId));
        return ResponseEntity.ok(ApiResponse.success(balances));
    }

    @PostMapping("/{accountId}/freeze")
    @Operation(summary = "Freeze account", description = "Freeze account (admin only)")
    public ResponseEntity<ApiResponse<Void>> freezeAccount(
            @PathVariable UUID accountId,
            @RequestParam String reason) {
        
        accountService.freezeAccount(accountId, reason);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
