package com.sibehgoodbank.transactionservice.client;

import com.sibehgoodbank.common.grpc.*;
import io.grpc.StatusRuntimeException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;

/**
 * gRPC Client service for Account Service operations
 * Provides a clean abstraction over gRPC calls with error handling
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AccountGrpcClient {

    private final AccountServiceGrpc.AccountServiceBlockingStub accountServiceBlockingStub;

    /**
     * Get account details by account ID
     */
    public Optional<AccountResponse> getAccount(String accountId) {
        try {
            log.debug("gRPC call: getAccount for accountId: {}", accountId);
            GetAccountRequest request = GetAccountRequest.newBuilder()
                    .setAccountId(accountId)
                    .build();
            return Optional.of(accountServiceBlockingStub.getAccount(request));
        } catch (StatusRuntimeException e) {
            log.error("gRPC error getting account: {} - Status: {}", accountId, e.getStatus(), e);
            return Optional.empty();
        } catch (Exception e) {
            log.error("Error getting account via gRPC: {}", accountId, e);
            return Optional.empty();
        }
    }

    /**
     * Get account balance
     */
    public Optional<BalanceResponse> getBalance(String accountId) {
        try {
            log.debug("gRPC call: getBalance for accountId: {}", accountId);
            GetBalanceRequest request = GetBalanceRequest.newBuilder()
                    .setAccountId(accountId)
                    .build();
            return Optional.of(accountServiceBlockingStub.getBalance(request));
        } catch (StatusRuntimeException e) {
            log.error("gRPC error getting balance: {} - Status: {}", accountId, e.getStatus(), e);
            return Optional.empty();
        } catch (Exception e) {
            log.error("Error getting balance via gRPC: {}", accountId, e);
            return Optional.empty();
        }
    }

    /**
     * Update account balance (debit or credit)
     */
    public Optional<UpdateBalanceResponse> updateBalance(String accountId, BigDecimal amount, 
                                                         String operationType, String transactionReference) {
        try {
            log.debug("gRPC call: updateBalance for accountId: {}, amount: {}, type: {}", 
                     accountId, amount, operationType);
            
            UpdateBalanceRequest request = UpdateBalanceRequest.newBuilder()
                    .setAccountId(accountId)
                    .setAmount(amount.toString())
                    .setOperationType(operationType) // DEBIT or CREDIT
                    .setTransactionReference(transactionReference)
                    .build();
            
            return Optional.of(accountServiceBlockingStub.updateBalance(request));
        } catch (StatusRuntimeException e) {
            log.error("gRPC error updating balance: {} - Status: {}", accountId, e.getStatus(), e);
            return Optional.empty();
        } catch (Exception e) {
            log.error("Error updating balance via gRPC: {}", accountId, e);
            return Optional.empty();
        }
    }

    /**
     * Validate if account exists and is active
     */
    public boolean validateAccount(String accountId) {
        try {
            log.debug("gRPC call: validateAccount for accountId: {}", accountId);
            ValidateAccountRequest request = ValidateAccountRequest.newBuilder()
                    .setAccountId(accountId)
                    .build();
            ValidateAccountResponse response = accountServiceBlockingStub.validateAccount(request);
            return response.getIsValid();
        } catch (StatusRuntimeException e) {
            log.error("gRPC error validating account: {} - Status: {}", accountId, e.getStatus(), e);
            return false;
        } catch (Exception e) {
            log.error("Error validating account via gRPC: {}", accountId, e);
            return false;
        }
    }

    /**
     * Check if account belongs to user
     */
    public boolean checkAccountOwnership(String accountId, String userId) {
        try {
            log.debug("gRPC call: checkAccountOwnership for accountId: {}, userId: {}", accountId, userId);
            CheckAccountOwnershipRequest request = CheckAccountOwnershipRequest.newBuilder()
                    .setAccountId(accountId)
                    .setUserId(userId)
                    .build();
            CheckAccountOwnershipResponse response = accountServiceBlockingStub.checkAccountOwnership(request);
            return response.getIsOwner();
        } catch (StatusRuntimeException e) {
            log.error("gRPC error checking ownership: {} - Status: {}", accountId, e.getStatus(), e);
            return false;
        } catch (Exception e) {
            log.error("Error checking ownership via gRPC: {}", accountId, e);
            return false;
        }
    }

    /**
     * Perform atomic balance transfer between two accounts
     * Debit source account and credit destination account
     */
    public boolean transferBalance(String fromAccountId, String toAccountId, 
                                   BigDecimal amount, String transactionReference) {
        try {
            log.info("gRPC transfer: {} -> {}, amount: {}, ref: {}", 
                    fromAccountId, toAccountId, amount, transactionReference);
            
            // Debit source account
            Optional<UpdateBalanceResponse> debitResponse = updateBalance(
                    fromAccountId, amount, "DEBIT", transactionReference);
            
            if (debitResponse.isEmpty() || !debitResponse.get().getSuccess()) {
                log.error("Failed to debit source account: {}", fromAccountId);
                return false;
            }
            
            // Credit destination account
            Optional<UpdateBalanceResponse> creditResponse = updateBalance(
                    toAccountId, amount, "CREDIT", transactionReference);
            
            if (creditResponse.isEmpty() || !creditResponse.get().getSuccess()) {
                log.error("Failed to credit destination account: {}. Attempting rollback.", toAccountId);
                // Attempt rollback - credit back to source
                updateBalance(fromAccountId, amount, "CREDIT", transactionReference + "_ROLLBACK");
                return false;
            }
            
            log.info("gRPC transfer successful: ref={}", transactionReference);
            return true;
            
        } catch (Exception e) {
            log.error("Error during gRPC transfer", e);
            return false;
        }
    }
}
