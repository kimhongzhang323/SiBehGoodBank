package com.sibehgoodbank.transactionservice.service.impl;

import com.sibehgoodbank.transactionservice.dto.*;
import com.sibehgoodbank.transactionservice.entity.Transaction;
import com.sibehgoodbank.transactionservice.entity.Transaction.*;
import com.sibehgoodbank.transactionservice.repository.TransactionRepository;
import com.sibehgoodbank.transactionservice.service.FraudDetectionService;
import com.sibehgoodbank.transactionservice.service.TransactionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements TransactionService {
    
    private final TransactionRepository transactionRepository;
    private final FraudDetectionService fraudDetectionService;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    private static final String TRANSACTION_EVENTS_TOPIC = "transaction-events";
    private static final String NOTIFICATION_EVENTS_TOPIC = "notification-events";
    
    @Override
    @Transactional
    public TransactionResponse createTransaction(UUID userId, CreateTransactionRequest request) {
        log.info("Creating transaction for user: {} type: {} amount: {}", 
                userId, request.getTransactionType(), request.getAmount());
        
        // Check for idempotency
        if (request.getExternalReferenceId() != null) {
            Optional<Transaction> existing = transactionRepository.findByExternalReferenceId(request.getExternalReferenceId());
            if (existing.isPresent()) {
                log.info("Duplicate transaction detected with external ref: {}", request.getExternalReferenceId());
                return mapToResponse(existing.get());
            }
        }
        
        // Fraud check
        FraudCheckResult fraudResult = fraudDetectionService.analyzeTransaction(request, userId);
        
        // Determine initial status based on fraud check
        TransactionStatus initialStatus = determineInitialStatus(fraudResult);
        
        // Generate reference number
        String referenceNumber = generateReferenceNumber(request.getTransactionType());
        
        // Calculate fee
        BigDecimal fee = calculateFee(request);
        FeeType feeType = determineFeeType(request.getTransactionType());
        
        Transaction transaction = Transaction.builder()
                .referenceNumber(referenceNumber)
                .userId(userId)
                .fromAccountId(UUID.randomUUID()) // Should be resolved from account service
                .fromAccountNumber(request.getFromAccountNumber())
                .toAccountNumber(request.getToAccountNumber())
                .toExternalAccount(request.getToExternalAccount())
                .toBankCode(request.getToBankCode())
                .beneficiaryName(request.getBeneficiaryName())
                .transactionType(request.getTransactionType())
                .status(initialStatus)
                .amount(request.getAmount())
                .fromCurrency(request.getCurrency())
                .toCurrency(request.getTargetCurrency() != null ? request.getTargetCurrency() : request.getCurrency())
                .exchangeRate(BigDecimal.ONE) // Should be fetched from exchange service
                .fee(fee)
                .feeType(feeType)
                .description(request.getDescription())
                .remarks(request.getRemarks())
                .channel(request.getChannel() != null ? request.getChannel() : TransactionChannel.API)
                .ipAddress(request.getIpAddress())
                .deviceId(request.getDeviceId())
                .deviceType(request.getDeviceType())
                .location(request.getLocation())
                .riskScore(fraudResult.getRiskScore())
                .isFlagged(fraudResult.isFlagged())
                .flagReason(fraudResult.getFlagReason())
                .externalReferenceId(request.getExternalReferenceId())
                .build();
        
        Transaction savedTransaction = transactionRepository.save(transaction);
        
        // Publish events
        publishTransactionEvent(savedTransaction, "TRANSACTION_CREATED");
        
        // If flagged, send for review notification
        if (fraudResult.isFlagged()) {
            publishNotificationEvent(savedTransaction, "TRANSACTION_FLAGGED");
        }
        
        // If approved, process immediately
        if (initialStatus == TransactionStatus.PROCESSING) {
            processTransaction(savedTransaction);
        }
        
        log.info("Transaction created: {} with status: {}", referenceNumber, initialStatus);
        
        return mapToResponse(savedTransaction);
    }
    
    @Override
    @Transactional
    public TransactionResponse createScheduledTransaction(UUID userId, ScheduledTransactionRequest request) {
        log.info("Creating scheduled transaction for user: {} at: {}", userId, request.getScheduledFor());
        
        String referenceNumber = generateReferenceNumber(TransactionType.INTERNAL_TRANSFER);
        
        Transaction transaction = Transaction.builder()
                .referenceNumber(referenceNumber)
                .userId(userId)
                .fromAccountId(UUID.randomUUID())
                .fromAccountNumber(request.getFromAccountNumber())
                .toAccountNumber(request.getToAccountNumber())
                .toExternalAccount(request.getToExternalAccount())
                .toBankCode(request.getToBankCode())
                .beneficiaryName(request.getBeneficiaryName())
                .transactionType(TransactionType.INTERNAL_TRANSFER)
                .status(TransactionStatus.SCHEDULED)
                .amount(request.getAmount())
                .fromCurrency(Currency.valueOf(request.getCurrency()))
                .toCurrency(request.getTargetCurrency() != null ? Currency.valueOf(request.getTargetCurrency()) : Currency.valueOf(request.getCurrency()))
                .description(request.getDescription())
                .remarks(request.getRemarks())
                .channel(TransactionChannel.SCHEDULED)
                .scheduledFor(request.getScheduledFor())
                .build();
        
        Transaction savedTransaction = transactionRepository.save(transaction);
        publishTransactionEvent(savedTransaction, "TRANSACTION_SCHEDULED");
        
        return mapToResponse(savedTransaction);
    }
    
    @Override
    @Transactional(readOnly = true)
    public TransactionResponse getTransactionById(UUID transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found: " + transactionId));
        return mapToResponse(transaction);
    }
    
    @Override
    @Transactional(readOnly = true)
    public TransactionResponse getTransactionByReference(String referenceNumber) {
        Transaction transaction = transactionRepository.findByReferenceNumber(referenceNumber)
                .orElseThrow(() -> new RuntimeException("Transaction not found: " + referenceNumber));
        return mapToResponse(transaction);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<TransactionResponse> getTransactionsByUser(UUID userId, Pageable pageable) {
        return transactionRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::mapToResponse);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<TransactionResponse> getTransactionsByAccount(UUID accountId, Pageable pageable) {
        return transactionRepository.findByAccountId(accountId, pageable)
                .map(this::mapToResponse);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<TransactionResponse> getTransactionsByAccountAndDateRange(
            UUID accountId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        return transactionRepository.findByAccountIdAndDateRange(accountId, startDate, endDate, pageable)
                .map(this::mapToResponse);
    }
    
    @Override
    @Transactional
    public TransactionResponse updateTransactionStatus(UUID transactionId, TransactionStatus status, String reason) {
        Transaction transaction = transactionRepository.findByIdWithLock(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        
        TransactionStatus oldStatus = transaction.getStatus();
        transaction.setStatus(status);
        
        if (status == TransactionStatus.COMPLETED) {
            transaction.setProcessedAt(LocalDateTime.now());
        }
        
        Transaction saved = transactionRepository.save(transaction);
        publishTransactionEvent(saved, "TRANSACTION_STATUS_CHANGED");
        
        log.info("Transaction {} status changed from {} to {}", transactionId, oldStatus, status);
        
        return mapToResponse(saved);
    }
    
    @Override
    @Scheduled(fixedRate = 60000) // Every minute
    @Transactional
    public void processScheduledTransactions() {
        List<Transaction> scheduledTransactions = transactionRepository
                .findScheduledTransactionsToProcess(TransactionStatus.SCHEDULED, LocalDateTime.now());
        
        log.info("Processing {} scheduled transactions", scheduledTransactions.size());
        
        for (Transaction transaction : scheduledTransactions) {
            try {
                transaction.setStatus(TransactionStatus.PROCESSING);
                transactionRepository.save(transaction);
                processTransaction(transaction);
            } catch (Exception e) {
                log.error("Failed to process scheduled transaction: {}", transaction.getReferenceNumber(), e);
                transaction.setStatus(TransactionStatus.FAILED);
                transaction.setRemarks("Processing failed: " + e.getMessage());
                transactionRepository.save(transaction);
            }
        }
    }
    
    @Override
    @Scheduled(fixedRate = 3600000) // Every hour
    @Transactional
    public void expireOldPendingTransactions() {
        LocalDateTime expiryTime = LocalDateTime.now().minusHours(24);
        List<Transaction> expiredTransactions = transactionRepository
                .findByStatusAndCreatedAtBefore(TransactionStatus.PENDING, expiryTime);
        
        log.info("Expiring {} old pending transactions", expiredTransactions.size());
        
        for (Transaction transaction : expiredTransactions) {
            transaction.setStatus(TransactionStatus.EXPIRED);
            transaction.setRemarks("Transaction expired after 24 hours");
            transactionRepository.save(transaction);
            publishTransactionEvent(transaction, "TRANSACTION_EXPIRED");
        }
    }
    
    @Override
    public FraudCheckResult checkForFraud(CreateTransactionRequest request, UUID userId) {
        return fraudDetectionService.analyzeTransaction(request, userId);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<TransactionResponse> getFlaggedTransactions(Pageable pageable) {
        return transactionRepository.findFlaggedTransactionsForReview(pageable)
                .map(this::mapToResponse);
    }
    
    @Override
    @Transactional
    public TransactionResponse reviewTransaction(UUID transactionId, UUID reviewerId, boolean approved, String notes) {
        Transaction transaction = transactionRepository.findByIdWithLock(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        
        if (!transaction.getIsFlagged()) {
            throw new RuntimeException("Transaction is not flagged for review");
        }
        
        transaction.setIsReviewed(true);
        transaction.setReviewedBy(reviewerId);
        transaction.setReviewedAt(LocalDateTime.now());
        transaction.setReviewNotes(notes);
        
        if (approved) {
            transaction.setStatus(TransactionStatus.PROCESSING);
            processTransaction(transaction);
        } else {
            transaction.setStatus(TransactionStatus.CANCELLED);
            publishNotificationEvent(transaction, "TRANSACTION_REJECTED");
        }
        
        Transaction saved = transactionRepository.save(transaction);
        log.info("Transaction {} reviewed by {}: {}", transactionId, reviewerId, approved ? "APPROVED" : "REJECTED");
        
        return mapToResponse(saved);
    }
    
    @Override
    @Transactional(readOnly = true)
    public TransactionAnalytics getTransactionAnalytics(UUID userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Object[]> typeSummary = transactionRepository.getTransactionSummaryByType(userId, startDate, endDate);
        List<Object[]> dailyStats = transactionRepository.getDailyTransactionStats(userId, startDate, endDate);
        
        Map<String, TransactionAnalytics.TypeStats> statsByType = new HashMap<>();
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalFees = BigDecimal.ZERO;
        int totalTransactions = 0;
        BigDecimal largestTransaction = BigDecimal.ZERO;
        BigDecimal smallestTransaction = null;
        
        for (Object[] row : typeSummary) {
            TransactionType type = (TransactionType) row[0];
            Long count = (Long) row[1];
            BigDecimal sum = (BigDecimal) row[2];
            
            totalTransactions += count.intValue();
            totalAmount = totalAmount.add(sum);
            
            statsByType.put(type.name(), TransactionAnalytics.TypeStats.builder()
                    .transactionType(type.name())
                    .count(count.intValue())
                    .totalAmount(sum)
                    .averageAmount(sum.divide(BigDecimal.valueOf(count), 2, RoundingMode.HALF_UP))
                    .build());
        }
        
        List<TransactionAnalytics.DailyStats> dailyBreakdown = new ArrayList<>();
        for (Object[] row : dailyStats) {
            LocalDateTime date = (LocalDateTime) row[0];
            Long count = (Long) row[1];
            BigDecimal amount = (BigDecimal) row[2];
            
            dailyBreakdown.add(TransactionAnalytics.DailyStats.builder()
                    .date(date)
                    .transactionCount(count.intValue())
                    .totalAmount(amount)
                    .build());
        }
        
        return TransactionAnalytics.builder()
                .totalTransactions(totalTransactions)
                .totalAmount(totalAmount)
                .totalFees(totalFees)
                .averageTransactionAmount(totalTransactions > 0 ? 
                        totalAmount.divide(BigDecimal.valueOf(totalTransactions), 2, RoundingMode.HALF_UP) : BigDecimal.ZERO)
                .largestTransaction(largestTransaction)
                .smallestTransaction(smallestTransaction != null ? smallestTransaction : BigDecimal.ZERO)
                .statsByType(statsByType)
                .dailyBreakdown(dailyBreakdown)
                .periodStart(startDate)
                .periodEnd(endDate)
                .build();
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getDailyStats(UUID userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Object[]> stats = transactionRepository.getDailyTransactionStats(userId, startDate, endDate);
        
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> dailyData = new ArrayList<>();
        
        for (Object[] row : stats) {
            Map<String, Object> day = new HashMap<>();
            day.put("date", row[0]);
            day.put("count", row[1]);
            day.put("amount", row[2]);
            dailyData.add(day);
        }
        
        result.put("data", dailyData);
        result.put("periodStart", startDate);
        result.put("periodEnd", endDate);
        
        return result;
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<TransactionStatusResponse> getTransactionStatuses(List<String> referenceNumbers) {
        List<Object[]> results = transactionRepository.findStatusByReferenceNumbers(referenceNumbers);
        
        return results.stream()
                .map(row -> TransactionStatusResponse.builder()
                        .referenceNumber((String) row[0])
                        .status(((TransactionStatus) row[1]).name())
                        .statusDescription(getStatusDescription((TransactionStatus) row[1]))
                        .build())
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional
    public TransactionResponse reverseTransaction(UUID transactionId, String reason) {
        Transaction original = transactionRepository.findByIdWithLock(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        
        if (original.getStatus() != TransactionStatus.COMPLETED) {
            throw new RuntimeException("Can only reverse completed transactions");
        }
        
        // Create reversal transaction
        String reversalRef = generateReferenceNumber(TransactionType.REVERSAL);
        
        Transaction reversal = Transaction.builder()
                .referenceNumber(reversalRef)
                .userId(original.getUserId())
                .fromAccountId(original.getToAccountId())
                .fromAccountNumber(original.getToAccountNumber())
                .toAccountId(original.getFromAccountId())
                .toAccountNumber(original.getFromAccountNumber())
                .transactionType(TransactionType.REVERSAL)
                .status(TransactionStatus.PROCESSING)
                .amount(original.getAmount())
                .fromCurrency(original.getToCurrency())
                .toCurrency(original.getFromCurrency())
                .description("Reversal of " + original.getReferenceNumber())
                .remarks(reason)
                .channel(TransactionChannel.API)
                .build();
        
        Transaction savedReversal = transactionRepository.save(reversal);
        
        // Mark original as reversed
        original.setStatus(TransactionStatus.REVERSED);
        original.setRemarks("Reversed by " + reversalRef + ": " + reason);
        transactionRepository.save(original);
        
        // Process reversal
        processTransaction(savedReversal);
        
        publishTransactionEvent(savedReversal, "TRANSACTION_REVERSED");
        publishNotificationEvent(original, "TRANSACTION_REVERSED");
        
        log.info("Transaction {} reversed. Reversal ref: {}", transactionId, reversalRef);
        
        return mapToResponse(savedReversal);
    }
    
    // Helper methods
    
    private void processTransaction(Transaction transaction) {
        try {
            // Here you would call the account service to actually move funds
            // For now, we'll just mark it as completed
            
            // Simulate processing delay
            transaction.setStatus(TransactionStatus.COMPLETED);
            transaction.setProcessedAt(LocalDateTime.now());
            transactionRepository.save(transaction);
            
            publishTransactionEvent(transaction, "TRANSACTION_COMPLETED");
            publishNotificationEvent(transaction, "TRANSACTION_COMPLETED");
            
            log.info("Transaction {} processed successfully", transaction.getReferenceNumber());
        } catch (Exception e) {
            transaction.setStatus(TransactionStatus.FAILED);
            transaction.setRemarks("Processing error: " + e.getMessage());
            transactionRepository.save(transaction);
            
            publishTransactionEvent(transaction, "TRANSACTION_FAILED");
            publishNotificationEvent(transaction, "TRANSACTION_FAILED");
            
            log.error("Transaction {} failed: {}", transaction.getReferenceNumber(), e.getMessage());
        }
    }
    
    private TransactionStatus determineInitialStatus(FraudCheckResult fraudResult) {
        if (fraudResult.getRiskScore() >= 80) {
            return TransactionStatus.FLAGGED;
        } else if (fraudResult.getRiskScore() >= 60) {
            return TransactionStatus.ON_HOLD;
        } else if (fraudResult.isFlagged()) {
            return TransactionStatus.UNDER_REVIEW;
        }
        return TransactionStatus.PROCESSING;
    }
    
    private String generateReferenceNumber(TransactionType type) {
        String prefix = switch (type) {
            case INTERNAL_TRANSFER -> "INT";
            case EXTERNAL_TRANSFER -> "EXT";
            case INTERNATIONAL_TRANSFER -> "GLB";
            case BILL_PAYMENT -> "BIL";
            case MERCHANT_PAYMENT -> "MER";
            case QR_PAYMENT -> "QRP";
            case REVERSAL -> "REV";
            default -> "TXN";
        };
        
        return prefix + System.currentTimeMillis() + String.format("%04d", new Random().nextInt(10000));
    }
    
    private BigDecimal calculateFee(CreateTransactionRequest request) {
        BigDecimal baseFee = BigDecimal.ZERO;
        
        switch (request.getTransactionType()) {
            case EXTERNAL_TRANSFER:
                baseFee = new BigDecimal("0.50");
                break;
            case INTERNATIONAL_TRANSFER:
                baseFee = new BigDecimal("25.00");
                break;
            case INTERBANK_TRANSFER:
                baseFee = new BigDecimal("0.20");
                break;
            default:
                baseFee = BigDecimal.ZERO;
        }
        
        // Currency conversion fee
        if (request.getTargetCurrency() != null && !request.getCurrency().equals(request.getTargetCurrency())) {
            baseFee = baseFee.add(request.getAmount().multiply(new BigDecimal("0.005"))); // 0.5% conversion fee
        }
        
        return baseFee;
    }
    
    private FeeType determineFeeType(TransactionType type) {
        return switch (type) {
            case EXTERNAL_TRANSFER -> FeeType.TRANSFER_FEE;
            case INTERBANK_TRANSFER -> FeeType.INTERBANK_FEE;
            case INTERNATIONAL_TRANSFER -> FeeType.INTERNATIONAL_FEE;
            default -> FeeType.NONE;
        };
    }
    
    private String getStatusDescription(TransactionStatus status) {
        return switch (status) {
            case PENDING -> "Transaction is pending processing";
            case PROCESSING -> "Transaction is being processed";
            case COMPLETED -> "Transaction completed successfully";
            case FAILED -> "Transaction failed";
            case CANCELLED -> "Transaction was cancelled";
            case REVERSED -> "Transaction has been reversed";
            case ON_HOLD -> "Transaction is on hold for review";
            case FLAGGED -> "Transaction flagged for security review";
            case UNDER_REVIEW -> "Transaction is under review";
            case SCHEDULED -> "Transaction is scheduled for future processing";
            case EXPIRED -> "Transaction expired";
        };
    }
    
    private TransactionResponse mapToResponse(Transaction transaction) {
        return TransactionResponse.builder()
                .id(transaction.getId())
                .referenceNumber(transaction.getReferenceNumber())
                .userId(transaction.getUserId())
                .fromAccountNumber(transaction.getFromAccountNumber())
                .toAccountNumber(transaction.getToAccountNumber())
                .toExternalAccount(transaction.getToExternalAccount())
                .toBankCode(transaction.getToBankCode())
                .beneficiaryName(transaction.getBeneficiaryName())
                .transactionType(transaction.getTransactionType().name())
                .status(transaction.getStatus().name())
                .amount(transaction.getAmount())
                .convertedAmount(transaction.getConvertedAmount())
                .fromCurrency(transaction.getFromCurrency().name())
                .toCurrency(transaction.getToCurrency() != null ? transaction.getToCurrency().name() : null)
                .exchangeRate(transaction.getExchangeRate())
                .fee(transaction.getFee())
                .feeType(transaction.getFeeType() != null ? transaction.getFeeType().name() : null)
                .description(transaction.getDescription())
                .remarks(transaction.getRemarks())
                .channel(transaction.getChannel() != null ? transaction.getChannel().name() : null)
                .riskScore(transaction.getRiskScore())
                .isFlagged(transaction.getIsFlagged())
                .flagReason(transaction.getFlagReason())
                .isReviewed(transaction.getIsReviewed())
                .balanceBefore(transaction.getBalanceBefore())
                .balanceAfter(transaction.getBalanceAfter())
                .scheduledFor(transaction.getScheduledFor())
                .processedAt(transaction.getProcessedAt())
                .createdAt(transaction.getCreatedAt())
                .updatedAt(transaction.getUpdatedAt())
                .build();
    }
    
    private void publishTransactionEvent(Transaction transaction, String eventType) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("eventType", eventType);
            event.put("transactionId", transaction.getId());
            event.put("referenceNumber", transaction.getReferenceNumber());
            event.put("userId", transaction.getUserId());
            event.put("amount", transaction.getAmount());
            event.put("status", transaction.getStatus().name());
            event.put("timestamp", LocalDateTime.now().toString());
            
            kafkaTemplate.send(TRANSACTION_EVENTS_TOPIC, transaction.getReferenceNumber(), event);
            log.debug("Published transaction event: {} for {}", eventType, transaction.getReferenceNumber());
        } catch (Exception e) {
            log.error("Failed to publish transaction event: {}", e.getMessage());
        }
    }
    
    private void publishNotificationEvent(Transaction transaction, String eventType) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("eventType", eventType);
            event.put("userId", transaction.getUserId());
            event.put("transactionId", transaction.getId());
            event.put("referenceNumber", transaction.getReferenceNumber());
            event.put("amount", transaction.getAmount());
            event.put("currency", transaction.getFromCurrency().name());
            event.put("status", transaction.getStatus().name());
            event.put("timestamp", LocalDateTime.now().toString());
            
            kafkaTemplate.send(NOTIFICATION_EVENTS_TOPIC, transaction.getUserId().toString(), event);
            log.debug("Published notification event: {} for user {}", eventType, transaction.getUserId());
        } catch (Exception e) {
            log.error("Failed to publish notification event: {}", e.getMessage());
        }
    }
}
