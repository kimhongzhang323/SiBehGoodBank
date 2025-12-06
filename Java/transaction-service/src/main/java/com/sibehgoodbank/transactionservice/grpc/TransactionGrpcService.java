package com.sibehgoodbank.transactionservice.grpc;

import com.sibehgoodbank.common.grpc.*;
import com.sibehgoodbank.transactionservice.dto.TransferRequest;
import com.sibehgoodbank.transactionservice.entity.Transaction;
import com.sibehgoodbank.transactionservice.entity.TransactionStatus;
import com.sibehgoodbank.transactionservice.repository.TransactionRepository;
import com.sibehgoodbank.transactionservice.service.TransactionService;
import io.grpc.Status;
import io.grpc.stub.StreamObserver;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.devh.boot.grpc.server.service.GrpcService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * gRPC service implementation for Transaction Service
 * Provides high-performance inter-service communication for transaction operations
 */
@GrpcService
@RequiredArgsConstructor
@Slf4j
public class TransactionGrpcService extends TransactionServiceGrpc.TransactionServiceImplBase {

    private final TransactionRepository transactionRepository;
    private final TransactionService transactionService;

    @Override
    public void getTransaction(GetTransactionRequest request, 
                               StreamObserver<TransactionResponse> responseObserver) {
        log.debug("gRPC getTransaction called for transactionId: {}", request.getTransactionId());
        
        try {
            UUID transactionId = UUID.fromString(request.getTransactionId());
            Optional<Transaction> txnOpt = transactionRepository.findById(transactionId);
            
            if (txnOpt.isEmpty()) {
                responseObserver.onError(
                    Status.NOT_FOUND
                        .withDescription("Transaction not found: " + request.getTransactionId())
                        .asRuntimeException()
                );
                return;
            }
            
            Transaction txn = txnOpt.get();
            TransactionResponse response = buildTransactionResponse(txn);
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid transaction ID format: {}", request.getTransactionId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid transaction ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error getting transaction: {}", request.getTransactionId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while fetching transaction")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void getTransactionByReference(GetTransactionByReferenceRequest request, 
                                          StreamObserver<TransactionResponse> responseObserver) {
        log.debug("gRPC getTransactionByReference called for reference: {}", request.getReferenceNumber());
        
        try {
            Optional<Transaction> txnOpt = transactionRepository.findByReferenceNumber(request.getReferenceNumber());
            
            if (txnOpt.isEmpty()) {
                responseObserver.onError(
                    Status.NOT_FOUND
                        .withDescription("Transaction not found with reference: " + request.getReferenceNumber())
                        .asRuntimeException()
                );
                return;
            }
            
            Transaction txn = txnOpt.get();
            TransactionResponse response = buildTransactionResponse(txn);
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (Exception e) {
            log.error("Error getting transaction by reference: {}", request.getReferenceNumber(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while fetching transaction")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void getUserTransactions(GetUserTransactionsRequest request, 
                                    StreamObserver<TransactionListResponse> responseObserver) {
        log.debug("gRPC getUserTransactions called for userId: {}", request.getUserId());
        
        try {
            UUID userId = UUID.fromString(request.getUserId());
            int pageSize = request.getPageSize() > 0 ? request.getPageSize() : 20;
            int pageNumber = request.getPageNumber();
            
            List<Transaction> transactions = transactionRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .skip((long) pageNumber * pageSize)
                .limit(pageSize)
                .collect(Collectors.toList());
            
            List<TransactionResponse> responses = transactions.stream()
                .map(this::buildTransactionResponse)
                .collect(Collectors.toList());
            
            TransactionListResponse response = TransactionListResponse.newBuilder()
                .addAllTransactions(responses)
                .setTotalCount(transactionRepository.countByUserId(userId))
                .setPageNumber(pageNumber)
                .setPageSize(pageSize)
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid user ID format: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid user ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error getting user transactions: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while fetching transactions")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void createTransfer(CreateTransferRequest request, 
                              StreamObserver<TransactionCreatedResponse> responseObserver) {
        log.debug("gRPC createTransfer called from {} to {}", request.getFromAccountId(), request.getToAccountId());
        
        try {
            TransferRequest transferRequest = TransferRequest.builder()
                .userId(UUID.fromString(request.getUserId()))
                .fromAccountId(UUID.fromString(request.getFromAccountId()))
                .toAccountId(UUID.fromString(request.getToAccountId()))
                .toAccountNumber(request.getToAccountNumber())
                .amount(new BigDecimal(request.getAmount()))
                .currency(request.getCurrency())
                .description(request.getDescription())
                .build();
            
            Transaction txn = transactionService.initiateTransfer(transferRequest);
            
            TransactionCreatedResponse response = TransactionCreatedResponse.newBuilder()
                .setTransactionId(txn.getId().toString())
                .setReferenceNumber(txn.getReferenceNumber())
                .setStatus(txn.getStatus().name())
                .setMessage("Transfer initiated successfully")
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid request parameters", e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid request parameters: " + e.getMessage())
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error creating transfer", e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while creating transfer: " + e.getMessage())
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void validateTransaction(ValidateTransactionRequest request, 
                                   StreamObserver<ValidateTransactionResponse> responseObserver) {
        log.debug("gRPC validateTransaction called for transactionId: {}", request.getTransactionId());
        
        try {
            UUID transactionId = UUID.fromString(request.getTransactionId());
            Optional<Transaction> txnOpt = transactionRepository.findById(transactionId);
            
            if (txnOpt.isEmpty()) {
                ValidateTransactionResponse response = ValidateTransactionResponse.newBuilder()
                    .setValid(false)
                    .setReason("Transaction not found")
                    .build();
                responseObserver.onNext(response);
                responseObserver.onCompleted();
                return;
            }
            
            Transaction txn = txnOpt.get();
            boolean isValid = txn.getStatus() == TransactionStatus.COMPLETED;
            
            ValidateTransactionResponse.Builder responseBuilder = ValidateTransactionResponse.newBuilder()
                .setValid(isValid)
                .setStatus(txn.getStatus().name());
            
            if (!isValid && txn.getStatus() == TransactionStatus.FAILED) {
                responseBuilder.setReason(txn.getFailureReason() != null ? txn.getFailureReason() : "Transaction failed");
            }
            
            responseObserver.onNext(responseBuilder.build());
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid transaction ID format: {}", request.getTransactionId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid transaction ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error validating transaction: {}", request.getTransactionId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while validating transaction")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void updateTransactionStatus(UpdateTransactionStatusRequest request, 
                                       StreamObserver<UpdateTransactionStatusResponse> responseObserver) {
        log.debug("gRPC updateTransactionStatus called for transactionId: {}", request.getTransactionId());
        
        try {
            UUID transactionId = UUID.fromString(request.getTransactionId());
            Optional<Transaction> txnOpt = transactionRepository.findById(transactionId);
            
            if (txnOpt.isEmpty()) {
                responseObserver.onError(
                    Status.NOT_FOUND
                        .withDescription("Transaction not found: " + request.getTransactionId())
                        .asRuntimeException()
                );
                return;
            }
            
            Transaction txn = txnOpt.get();
            TransactionStatus oldStatus = txn.getStatus();
            TransactionStatus newStatus = TransactionStatus.valueOf(request.getNewStatus());
            
            txn.setStatus(newStatus);
            if (request.hasFailureReason() && !request.getFailureReason().isEmpty()) {
                txn.setFailureReason(request.getFailureReason());
            }
            
            transactionRepository.save(txn);
            
            UpdateTransactionStatusResponse response = UpdateTransactionStatusResponse.newBuilder()
                .setTransactionId(txn.getId().toString())
                .setOldStatus(oldStatus.name())
                .setNewStatus(newStatus.name())
                .setSuccess(true)
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid request parameters", e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid request parameters: " + e.getMessage())
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error updating transaction status: {}", request.getTransactionId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while updating transaction status")
                    .asRuntimeException()
            );
        }
    }

    /**
     * Build TransactionResponse from Transaction entity
     */
    private TransactionResponse buildTransactionResponse(Transaction txn) {
        TransactionResponse.Builder builder = TransactionResponse.newBuilder()
            .setTransactionId(txn.getId().toString())
            .setReferenceNumber(txn.getReferenceNumber())
            .setUserId(txn.getUserId().toString())
            .setFromAccountId(txn.getFromAccountId().toString())
            .setFromAccountNumber(txn.getFromAccountNumber())
            .setTransactionType(txn.getTransactionType().name())
            .setStatus(txn.getStatus().name())
            .setAmount(txn.getAmount().toString())
            .setFromCurrency(txn.getFromCurrency().name());
        
        if (txn.getToAccountId() != null) {
            builder.setToAccountId(txn.getToAccountId().toString());
        }
        if (txn.getToAccountNumber() != null) {
            builder.setToAccountNumber(txn.getToAccountNumber());
        }
        if (txn.getToCurrency() != null) {
            builder.setToCurrency(txn.getToCurrency().name());
        }
        if (txn.getConvertedAmount() != null) {
            builder.setConvertedAmount(txn.getConvertedAmount().toString());
        }
        if (txn.getExchangeRate() != null) {
            builder.setExchangeRate(txn.getExchangeRate().toString());
        }
        if (txn.getFee() != null) {
            builder.setFee(txn.getFee().toString());
        }
        if (txn.getDescription() != null) {
            builder.setDescription(txn.getDescription());
        }
        if (txn.getCreatedAt() != null) {
            builder.setCreatedAt(txn.getCreatedAt().toString());
        }
        if (txn.getCompletedAt() != null) {
            builder.setCompletedAt(txn.getCompletedAt().toString());
        }
        
        return builder.build();
    }
}
