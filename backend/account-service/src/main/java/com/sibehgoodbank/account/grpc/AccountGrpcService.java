package com.sibehgoodbank.account.grpc;

import com.sibehgoodbank.grpc.account.*;
import io.grpc.stub.StreamObserver;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.devh.boot.grpc.server.service.GrpcService;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * gRPC service implementation for Account Service.
 * Provides account information to other microservices via gRPC.
 */
@GrpcService
@RequiredArgsConstructor
@Slf4j
public class AccountGrpcService extends AccountServiceGrpc.AccountServiceImplBase {

    private final com.sibehgoodbank.account.service.AccountService accountService;

    @Override
    public void getAccount(GetAccountRequest request, StreamObserver<AccountResponse> responseObserver) {
        try {
            UUID accountId = UUID.fromString(request.getAccountId());
            var account = accountService.getAccountById(accountId);
            
            AccountResponse response = mapToGrpcResponse(account);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            log.error("Error getting account: {}", e.getMessage(), e);
            responseObserver.onError(io.grpc.Status.INTERNAL
                    .withDescription(e.getMessage())
                    .asRuntimeException());
        }
    }

    @Override
    public void getAccountByNumber(GetAccountByNumberRequest request, StreamObserver<AccountResponse> responseObserver) {
        try {
            var account = accountService.getAccountByNumber(request.getAccountNumber());
            
            AccountResponse response = mapToGrpcResponse(account);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            log.error("Error getting account by number: {}", e.getMessage(), e);
            responseObserver.onError(io.grpc.Status.NOT_FOUND
                    .withDescription("Account not found")
                    .asRuntimeException());
        }
    }

    @Override
    public void getAccountsByUser(GetAccountsByUserRequest request, StreamObserver<AccountsResponse> responseObserver) {
        try {
            UUID userId = UUID.fromString(request.getUserId());
            var accounts = accountService.getAccountsByUserId(userId);
            
            AccountsResponse.Builder responseBuilder = AccountsResponse.newBuilder();
            accounts.forEach(account -> responseBuilder.addAccounts(mapToGrpcResponse(account)));
            
            responseObserver.onNext(responseBuilder.build());
            responseObserver.onCompleted();
        } catch (Exception e) {
            log.error("Error getting accounts for user: {}", e.getMessage(), e);
            responseObserver.onError(io.grpc.Status.INTERNAL
                    .withDescription(e.getMessage())
                    .asRuntimeException());
        }
    }

    @Override
    public void validateAccount(ValidateAccountRequest request, StreamObserver<ValidateAccountResponse> responseObserver) {
        try {
            UUID accountId = UUID.fromString(request.getAccountId());
            UUID userId = request.getUserId().isEmpty() ? null : UUID.fromString(request.getUserId());
            
            var account = accountService.getAccountById(accountId);
            
            boolean isActive = "ACTIVE".equals(account.getStatus().name());
            boolean belongsToUser = userId == null || account.getUserId().equals(userId);
            
            ValidateAccountResponse response = ValidateAccountResponse.newBuilder()
                    .setValid(true)
                    .setActive(isActive)
                    .setBelongsToUser(belongsToUser)
                    .setMessage(isActive && belongsToUser ? "Account is valid" : "Account validation failed")
                    .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            log.warn("Account validation failed: {}", e.getMessage());
            responseObserver.onNext(ValidateAccountResponse.newBuilder()
                    .setValid(false)
                    .setMessage("Account not found")
                    .build());
            responseObserver.onCompleted();
        }
    }

    @Override
    public void getBalance(GetBalanceRequest request, StreamObserver<BalanceResponse> responseObserver) {
        try {
            UUID accountId = UUID.fromString(request.getAccountId());
            var account = accountService.getAccountById(accountId);
            
            BalanceResponse response = BalanceResponse.newBuilder()
                    .setAccountId(account.getId().toString())
                    .setBalance(account.getBalance().toPlainString())
                    .setAvailableBalance(account.getAvailableBalance().toPlainString())
                    .setCurrency(account.getCurrency().name())
                    .setAsOfTimestamp(System.currentTimeMillis())
                    .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            log.error("Error getting balance: {}", e.getMessage(), e);
            responseObserver.onError(io.grpc.Status.INTERNAL
                    .withDescription(e.getMessage())
                    .asRuntimeException());
        }
    }

    @Override
    public void updateBalance(UpdateBalanceRequest request, StreamObserver<UpdateBalanceResponse> responseObserver) {
        try {
            UUID accountId = UUID.fromString(request.getAccountId());
            BigDecimal amount = new BigDecimal(request.getAmount());
            String transactionType = request.getTransactionType();
            
            var updatedAccount = accountService.updateBalance(accountId, amount, transactionType);
            
            UpdateBalanceResponse response = UpdateBalanceResponse.newBuilder()
                    .setSuccess(true)
                    .setNewBalance(updatedAccount.getBalance().toPlainString())
                    .setNewAvailableBalance(updatedAccount.getAvailableBalance().toPlainString())
                    .setMessage("Balance updated successfully")
                    .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        } catch (Exception e) {
            log.error("Error updating balance: {}", e.getMessage(), e);
            responseObserver.onNext(UpdateBalanceResponse.newBuilder()
                    .setSuccess(false)
                    .setMessage(e.getMessage())
                    .build());
            responseObserver.onCompleted();
        }
    }

    @Override
    public void accountExists(AccountExistsRequest request, StreamObserver<AccountExistsResponse> responseObserver) {
        try {
            UUID accountId = UUID.fromString(request.getAccountId());
            boolean exists = accountService.accountExists(accountId);
            
            responseObserver.onNext(AccountExistsResponse.newBuilder()
                    .setExists(exists)
                    .build());
            responseObserver.onCompleted();
        } catch (Exception e) {
            responseObserver.onNext(AccountExistsResponse.newBuilder()
                    .setExists(false)
                    .build());
            responseObserver.onCompleted();
        }
    }

    private AccountResponse mapToGrpcResponse(com.sibehgoodbank.account.entity.Account account) {
        return AccountResponse.newBuilder()
                .setAccountId(account.getId().toString())
                .setUserId(account.getUserId().toString())
                .setAccountNumber(account.getAccountNumber())
                .setAccountType(account.getAccountType().name())
                .setCurrency(account.getCurrency().name())
                .setBalance(account.getBalance().toPlainString())
                .setAvailableBalance(account.getAvailableBalance().toPlainString())
                .setStatus(account.getStatus().name())
                .setCreatedAt(account.getCreatedAt().toEpochMilli())
                .build();
    }
}
