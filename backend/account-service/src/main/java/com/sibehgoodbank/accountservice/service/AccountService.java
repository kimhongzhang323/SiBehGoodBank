package com.sibehgoodbank.accountservice.service;

import com.sibehgoodbank.accountservice.dto.*;
import com.sibehgoodbank.accountservice.entity.Account;
import com.sibehgoodbank.accountservice.repository.AccountRepository;
import com.sibehgoodbank.common.messaging.kafka.KafkaConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Account service with business logic for banking operations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AccountService {

    private final AccountRepository accountRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Create a new bank account
     */
    @Transactional
    public AccountResponse createAccount(UUID userId, CreateAccountRequest request) {
        log.info("Creating account for user: {}", userId);

        // Generate unique account number
        String accountNumber = generateAccountNumber();
        while (accountRepository.existsByAccountNumber(accountNumber)) {
            accountNumber = generateAccountNumber();
        }

        // Check if this should be primary account
        boolean isPrimary = accountRepository.countActiveAccountsByUserId(userId) == 0;

        Account account = Account.builder()
                .userId(userId)
                .accountNumber(accountNumber)
                .accountName(request.getAccountName())
                .accountType(request.getAccountType())
                .currency(request.getCurrency() != null ? request.getCurrency() : Account.Currency.SGD)
                .balance(BigDecimal.ZERO)
                .availableBalance(BigDecimal.ZERO)
                .dailyTransferLimit(request.getDailyTransferLimit() != null ? 
                        request.getDailyTransferLimit() : new BigDecimal("10000"))
                .isPrimary(isPrimary)
                .status(Account.AccountStatus.ACTIVE)
                .activatedAt(LocalDateTime.now())
                .build();

        account = accountRepository.save(account);

        // Publish event
        publishAccountEvent("ACCOUNT_CREATED", account);

        log.info("Account created with number: {}", accountNumber);
        return mapToResponse(account);
    }

    /**
     * Get account by ID
     */
    @Cacheable(value = "account", key = "#accountId")
    public AccountResponse getAccountById(UUID accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        return mapToResponse(account);
    }

    /**
     * Get account by account number
     */
    public AccountResponse getAccountByNumber(String accountNumber) {
        Account account = accountRepository.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        return mapToResponse(account);
    }

    /**
     * Get all accounts for user
     */
    public List<AccountResponse> getAccountsByUserId(UUID userId) {
        return accountRepository.findByUserId(userId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get accounts by user with pagination
     */
    public Page<AccountResponse> getAccountsByUserId(UUID userId, Pageable pageable) {
        return accountRepository.findByUserId(userId, pageable)
                .map(this::mapToResponse);
    }

    /**
     * Debit funds from account with pessimistic locking
     */
    @Transactional
    @CacheEvict(value = "account", key = "#accountId")
    public AccountResponse debit(UUID accountId, BigDecimal amount, String reference) {
        log.info("Debiting {} from account {}", amount, accountId);

        Account account = accountRepository.findByIdForUpdate(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));

        validateAccountStatus(account);
        
        if (!account.canDebit(amount)) {
            throw new RuntimeException("Insufficient funds");
        }
        
        if (!account.isWithinDailyLimit(amount)) {
            throw new RuntimeException("Daily transfer limit exceeded");
        }

        account.debit(amount);
        account = accountRepository.save(account);

        // Publish event
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("accountId", accountId.toString());
        eventData.put("amount", amount);
        eventData.put("reference", reference);
        eventData.put("type", "DEBIT");
        publishAccountEvent("ACCOUNT_DEBITED", account, eventData);

        return mapToResponse(account);
    }

    /**
     * Credit funds to account with pessimistic locking
     */
    @Transactional
    @CacheEvict(value = "account", key = "#accountId")
    public AccountResponse credit(UUID accountId, BigDecimal amount, String reference) {
        log.info("Crediting {} to account {}", amount, accountId);

        Account account = accountRepository.findByIdForUpdate(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));

        validateAccountStatus(account);

        account.credit(amount);
        account = accountRepository.save(account);

        // Publish event
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("accountId", accountId.toString());
        eventData.put("amount", amount);
        eventData.put("reference", reference);
        eventData.put("type", "CREDIT");
        publishAccountEvent("ACCOUNT_CREDITED", account, eventData);

        return mapToResponse(account);
    }

    /**
     * Transfer between accounts
     */
    @Transactional
    public TransferResponse transfer(TransferRequest request) {
        log.info("Transfer from {} to {}: {} {}", 
                request.getFromAccountNumber(), 
                request.getToAccountNumber(),
                request.getAmount(),
                request.getCurrency());

        // Lock both accounts in consistent order to prevent deadlocks
        Account fromAccount = accountRepository.findByAccountNumberForUpdate(request.getFromAccountNumber())
                .orElseThrow(() -> new RuntimeException("Source account not found"));
        Account toAccount = accountRepository.findByAccountNumberForUpdate(request.getToAccountNumber())
                .orElseThrow(() -> new RuntimeException("Destination account not found"));

        // Validations
        validateAccountStatus(fromAccount);
        validateAccountStatus(toAccount);

        if (!fromAccount.canDebit(request.getAmount())) {
            throw new RuntimeException("Insufficient funds");
        }

        if (!fromAccount.isWithinDailyLimit(request.getAmount())) {
            throw new RuntimeException("Daily transfer limit exceeded");
        }

        // Perform transfer
        String reference = generateReference();
        fromAccount.debit(request.getAmount());
        toAccount.credit(request.getAmount());

        accountRepository.save(fromAccount);
        accountRepository.save(toAccount);

        // Publish events
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("fromAccountId", fromAccount.getId().toString());
        eventData.put("toAccountId", toAccount.getId().toString());
        eventData.put("amount", request.getAmount());
        eventData.put("reference", reference);
        
        kafkaTemplate.send(KafkaConfig.TRANSACTION_EVENTS_TOPIC, reference, eventData);

        return TransferResponse.builder()
                .reference(reference)
                .fromAccountNumber(fromAccount.getAccountNumber())
                .toAccountNumber(toAccount.getAccountNumber())
                .amount(request.getAmount())
                .currency(fromAccount.getCurrency().name())
                .status("COMPLETED")
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * Hold funds for pending transaction
     */
    @Transactional
    @CacheEvict(value = "account", key = "#accountId")
    public void holdFunds(UUID accountId, BigDecimal amount) {
        Account account = accountRepository.findByIdForUpdate(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        account.holdFunds(amount);
        accountRepository.save(account);
    }

    /**
     * Release held funds
     */
    @Transactional
    @CacheEvict(value = "account", key = "#accountId")
    public void releaseFunds(UUID accountId, BigDecimal amount) {
        Account account = accountRepository.findByIdForUpdate(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        account.releaseFunds(amount);
        accountRepository.save(account);
    }

    /**
     * Update daily transfer limit
     */
    @Transactional
    @CacheEvict(value = "account", key = "#accountId")
    public AccountResponse updateDailyLimit(UUID accountId, BigDecimal newLimit) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        
        account.setDailyTransferLimit(newLimit);
        account = accountRepository.save(account);
        
        return mapToResponse(account);
    }

    /**
     * Freeze account
     */
    @Transactional
    @CacheEvict(value = "account", key = "#accountId")
    public void freezeAccount(UUID accountId, String reason) {
        log.info("Freezing account: {} - Reason: {}", accountId, reason);
        accountRepository.updateStatus(accountId, Account.AccountStatus.FROZEN);
    }

    /**
     * Get total balance across all accounts
     */
    public Map<String, BigDecimal> getTotalBalanceByUser(UUID userId) {
        Map<String, BigDecimal> balances = new HashMap<>();
        for (Account.Currency currency : Account.Currency.values()) {
            BigDecimal total = accountRepository.getTotalBalanceByUserAndCurrency(userId, currency);
            if (total != null && total.compareTo(BigDecimal.ZERO) > 0) {
                balances.put(currency.name(), total);
            }
        }
        return balances;
    }

    // Helper methods
    private String generateAccountNumber() {
        // Format: 888-XXX-XXXX-X (Singapore style)
        StringBuilder sb = new StringBuilder("888");
        for (int i = 0; i < 8; i++) {
            sb.append(RANDOM.nextInt(10));
        }
        return sb.toString();
    }

    private String generateReference() {
        return "TXN" + System.currentTimeMillis() + RANDOM.nextInt(1000);
    }

    private void validateAccountStatus(Account account) {
        if (account.getStatus() != Account.AccountStatus.ACTIVE) {
            throw new RuntimeException("Account is not active: " + account.getStatus());
        }
    }

    private AccountResponse mapToResponse(Account account) {
        return AccountResponse.builder()
                .id(account.getId())
                .userId(account.getUserId())
                .accountNumber(account.getAccountNumber())
                .accountName(account.getAccountName())
                .accountType(account.getAccountType().name())
                .currency(account.getCurrency().name())
                .balance(account.getBalance())
                .availableBalance(account.getAvailableBalance())
                .pendingBalance(account.getPendingBalance())
                .dailyTransferLimit(account.getDailyTransferLimit())
                .dailyTransferUsed(account.getDailyTransferUsed())
                .status(account.getStatus().name())
                .isPrimary(account.isPrimary())
                .createdAt(account.getCreatedAt())
                .lastTransactionAt(account.getLastTransactionAt())
                .build();
    }

    private void publishAccountEvent(String eventType, Account account) {
        publishAccountEvent(eventType, account, new HashMap<>());
    }

    private void publishAccountEvent(String eventType, Account account, Map<String, Object> additionalData) {
        try {
            Map<String, Object> event = new HashMap<>(additionalData);
            event.put("eventType", eventType);
            event.put("accountId", account.getId().toString());
            event.put("userId", account.getUserId().toString());
            event.put("timestamp", LocalDateTime.now().toString());
            kafkaTemplate.send(KafkaConfig.ACCOUNT_EVENTS_TOPIC, account.getId().toString(), event);
        } catch (Exception e) {
            log.error("Failed to publish account event: {}", e.getMessage());
        }
    }
}
