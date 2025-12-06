package com.sibehgoodbank.accountservice.service.impl;

import com.sibehgoodbank.accountservice.dto.*;
import com.sibehgoodbank.accountservice.entity.Account;
import com.sibehgoodbank.accountservice.entity.Account.AccountStatus;
import com.sibehgoodbank.accountservice.entity.Account.AccountType;
import com.sibehgoodbank.accountservice.entity.Account.Currency;
import com.sibehgoodbank.accountservice.repository.AccountRepository;
import com.sibehgoodbank.accountservice.service.AccountService;
import com.sibehgoodbank.common.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AccountServiceImpl implements AccountService {
    
    private final AccountRepository accountRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    private static final String ACCOUNT_EVENTS_TOPIC = "account-events";
    private static final String TRANSACTION_EVENTS_TOPIC = "transaction-events";
    
    @Override
    @Transactional
    public AccountResponse createAccount(UUID userId, CreateAccountRequest request) {
        log.info("Creating account for user: {} with type: {}", userId, request.getAccountType());
        
        // Generate unique account number
        String accountNumber = generateAccountNumber(request.getAccountType());
        
        // Check if this is the first account (make it primary)
        boolean isPrimary = request.isPrimary() || 
            accountRepository.countByUserIdAndStatus(userId, AccountStatus.ACTIVE) == 0;
        
        // If setting as primary, unset other primary accounts
        if (isPrimary) {
            accountRepository.findByUserIdAndIsPrimaryTrue(userId)
                .ifPresent(existing -> {
                    existing.setPrimary(false);
                    accountRepository.save(existing);
                });
        }
        
        Account account = Account.builder()
                .accountNumber(accountNumber)
                .userId(userId)
                .accountType(request.getAccountType())
                .accountName(request.getAccountName())
                .currency(request.getCurrency() != null ? request.getCurrency() : Currency.SGD)
                .balance(request.getInitialDeposit() != null ? request.getInitialDeposit() : BigDecimal.ZERO)
                .availableBalance(request.getInitialDeposit() != null ? request.getInitialDeposit() : BigDecimal.ZERO)
                .holdAmount(BigDecimal.ZERO)
                .dailyTransferLimit(getDefaultDailyLimit(request.getAccountType()))
                .dailyTransferredAmount(BigDecimal.ZERO)
                .interestRate(getDefaultInterestRate(request.getAccountType()))
                .overdraftLimit(BigDecimal.ZERO)
                .status(AccountStatus.ACTIVE)
                .isPrimary(isPrimary)
                .openedDate(LocalDateTime.now())
                .build();
        
        Account savedAccount = accountRepository.save(account);
        
        // Publish account created event
        publishAccountEvent("ACCOUNT_CREATED", savedAccount);
        
        log.info("Account created successfully: {}", savedAccount.getAccountNumber());
        return mapToResponse(savedAccount);
    }
    
    @Override
    @Transactional(readOnly = true)
    public AccountResponse getAccountById(UUID accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found: " + accountId));
        return mapToResponse(account);
    }
    
    @Override
    @Transactional(readOnly = true)
    public AccountResponse getAccountByNumber(String accountNumber) {
        Account account = accountRepository.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new RuntimeException("Account not found: " + accountNumber));
        return mapToResponse(account);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<AccountResponse> getAccountsByUserId(UUID userId) {
        return accountRepository.findByUserIdOrderByIsPrimaryDescCreatedAtDesc(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<AccountResponse> getActiveAccountsByUserId(UUID userId) {
        return accountRepository.findByUserIdAndStatus(userId, AccountStatus.ACTIVE)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional
    public TransferResponse transfer(UUID userId, TransferRequest request) {
        log.info("Processing transfer from {} to {} amount: {}", 
            request.getFromAccountNumber(), request.getToAccountNumber(), request.getAmount());
        
        // Validate accounts
        Account fromAccount = accountRepository.findByAccountNumberWithLock(request.getFromAccountNumber())
                .orElseThrow(() -> new RuntimeException("Source account not found"));
        
        // Verify ownership
        if (!fromAccount.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized: Account does not belong to user");
        }
        
        // Check account status
        if (fromAccount.getStatus() != AccountStatus.ACTIVE) {
            throw new RuntimeException("Source account is not active");
        }
        
        BigDecimal amount = request.getAmount();
        
        // Check available balance
        if (fromAccount.getAvailableBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient funds");
        }
        
        // Check daily limit
        resetDailyLimitIfNeeded(fromAccount);
        BigDecimal newDailyTransferred = fromAccount.getDailyTransferredAmount().add(amount);
        if (newDailyTransferred.compareTo(fromAccount.getDailyTransferLimit()) > 0) {
            throw new RuntimeException("Daily transfer limit exceeded");
        }
        
        // Get destination account
        Account toAccount = accountRepository.findByAccountNumberWithLock(request.getToAccountNumber())
                .orElseThrow(() -> new RuntimeException("Destination account not found"));
        
        if (toAccount.getStatus() != AccountStatus.ACTIVE) {
            throw new RuntimeException("Destination account is not active");
        }
        
        // Currency conversion if needed
        BigDecimal convertedAmount = amount;
        BigDecimal exchangeRate = BigDecimal.ONE;
        if (fromAccount.getCurrency() != toAccount.getCurrency()) {
            // In production, fetch real-time exchange rates
            exchangeRate = getExchangeRate(fromAccount.getCurrency(), toAccount.getCurrency());
            convertedAmount = amount.multiply(exchangeRate);
        }
        
        // Perform transfer
        String referenceNumber = generateReferenceNumber();
        
        // Debit source account
        fromAccount.setBalance(fromAccount.getBalance().subtract(amount));
        fromAccount.setAvailableBalance(fromAccount.getAvailableBalance().subtract(amount));
        fromAccount.setDailyTransferredAmount(newDailyTransferred);
        fromAccount.setLastTransferDate(LocalDate.now());
        fromAccount.setLastActivityDate(LocalDateTime.now());
        
        // Credit destination account
        toAccount.setBalance(toAccount.getBalance().add(convertedAmount));
        toAccount.setAvailableBalance(toAccount.getAvailableBalance().add(convertedAmount));
        toAccount.setLastActivityDate(LocalDateTime.now());
        
        accountRepository.save(fromAccount);
        accountRepository.save(toAccount);
        
        // Publish transaction event
        publishTransactionEvent(referenceNumber, fromAccount, toAccount, amount, convertedAmount, request.getDescription());
        
        log.info("Transfer completed: {} from {} to {}", referenceNumber, 
            fromAccount.getAccountNumber(), toAccount.getAccountNumber());
        
        return TransferResponse.builder()
                .referenceNumber(referenceNumber)
                .fromAccountNumber(fromAccount.getAccountNumber())
                .toAccountNumber(toAccount.getAccountNumber())
                .amount(amount)
                .convertedAmount(convertedAmount)
                .fromCurrency(fromAccount.getCurrency().name())
                .toCurrency(toAccount.getCurrency().name())
                .exchangeRate(exchangeRate)
                .status("COMPLETED")
                .description(request.getDescription())
                .timestamp(LocalDateTime.now())
                .newBalance(fromAccount.getBalance())
                .build();
    }
    
    @Override
    @Transactional
    public AccountResponse freezeAccount(UUID accountId, String reason) {
        log.info("Freezing account: {} reason: {}", accountId, reason);
        
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        
        if (account.getStatus() == AccountStatus.CLOSED) {
            throw new RuntimeException("Cannot freeze a closed account");
        }
        
        account.setStatus(AccountStatus.FROZEN);
        account.setLastActivityDate(LocalDateTime.now());
        
        Account savedAccount = accountRepository.save(account);
        publishAccountEvent("ACCOUNT_FROZEN", savedAccount);
        
        return mapToResponse(savedAccount);
    }
    
    @Override
    @Transactional
    public AccountResponse unfreezeAccount(UUID accountId) {
        log.info("Unfreezing account: {}", accountId);
        
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        
        if (account.getStatus() != AccountStatus.FROZEN) {
            throw new RuntimeException("Account is not frozen");
        }
        
        account.setStatus(AccountStatus.ACTIVE);
        account.setLastActivityDate(LocalDateTime.now());
        
        Account savedAccount = accountRepository.save(account);
        publishAccountEvent("ACCOUNT_UNFROZEN", savedAccount);
        
        return mapToResponse(savedAccount);
    }
    
    @Override
    @Transactional
    public void closeAccount(UUID accountId, String reason) {
        log.info("Closing account: {} reason: {}", accountId, reason);
        
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        
        if (account.getBalance().compareTo(BigDecimal.ZERO) != 0) {
            throw new RuntimeException("Account must have zero balance before closing");
        }
        
        account.setStatus(AccountStatus.CLOSED);
        account.setClosedDate(LocalDateTime.now());
        account.setLastActivityDate(LocalDateTime.now());
        
        accountRepository.save(account);
        publishAccountEvent("ACCOUNT_CLOSED", account);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, BigDecimal> getBalanceSummary(UUID userId) {
        List<Account> accounts = accountRepository.findByUserIdAndStatus(userId, AccountStatus.ACTIVE);
        
        Map<String, BigDecimal> summary = new HashMap<>();
        summary.put("totalBalance", BigDecimal.ZERO);
        summary.put("totalAvailable", BigDecimal.ZERO);
        summary.put("totalHeld", BigDecimal.ZERO);
        
        // Group by currency
        Map<Currency, BigDecimal> balanceByCurrency = new HashMap<>();
        
        for (Account account : accounts) {
            summary.put("totalBalance", summary.get("totalBalance").add(account.getBalance()));
            summary.put("totalAvailable", summary.get("totalAvailable").add(account.getAvailableBalance()));
            summary.put("totalHeld", summary.get("totalHeld").add(account.getHoldAmount()));
            
            balanceByCurrency.merge(account.getCurrency(), account.getBalance(), BigDecimal::add);
        }
        
        // Add currency breakdown
        for (Map.Entry<Currency, BigDecimal> entry : balanceByCurrency.entrySet()) {
            summary.put("balance_" + entry.getKey().name(), entry.getValue());
        }
        
        summary.put("accountCount", BigDecimal.valueOf(accounts.size()));
        
        return summary;
    }
    
    @Override
    @Transactional
    public AccountResponse updateDailyLimit(UUID accountId, BigDecimal newLimit) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        
        if (newLimit.compareTo(BigDecimal.ZERO) < 0) {
            throw new RuntimeException("Daily limit cannot be negative");
        }
        
        account.setDailyTransferLimit(newLimit);
        Account savedAccount = accountRepository.save(account);
        
        publishAccountEvent("LIMIT_UPDATED", savedAccount);
        
        return mapToResponse(savedAccount);
    }
    
    @Override
    @Transactional
    public void placeHold(UUID accountId, BigDecimal amount, String reason) {
        Account account = accountRepository.findByIdWithLock(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        
        if (account.getAvailableBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient available balance for hold");
        }
        
        account.setHoldAmount(account.getHoldAmount().add(amount));
        account.setAvailableBalance(account.getAvailableBalance().subtract(amount));
        
        accountRepository.save(account);
        publishAccountEvent("HOLD_PLACED", account);
    }
    
    @Override
    @Transactional
    public void releaseHold(UUID accountId, BigDecimal amount) {
        Account account = accountRepository.findByIdWithLock(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        
        if (account.getHoldAmount().compareTo(amount) < 0) {
            throw new RuntimeException("Hold amount is less than release amount");
        }
        
        account.setHoldAmount(account.getHoldAmount().subtract(amount));
        account.setAvailableBalance(account.getAvailableBalance().add(amount));
        
        accountRepository.save(account);
        publishAccountEvent("HOLD_RELEASED", account);
    }
    
    // Helper methods
    
    private String generateAccountNumber(AccountType type) {
        String prefix = switch (type) {
            case SAVINGS -> "SAV";
            case CHECKING -> "CHK";
            case FIXED_DEPOSIT -> "FXD";
            case MULTI_CURRENCY -> "MCY";
            case INVESTMENT -> "INV";
            case LOAN -> "LON";
            case CREDIT -> "CRD";
        };
        
        String randomPart = String.format("%012d", new Random().nextLong(999999999999L));
        return prefix + randomPart;
    }
    
    private String generateReferenceNumber() {
        return "TXN" + System.currentTimeMillis() + String.format("%04d", new Random().nextInt(10000));
    }
    
    private BigDecimal getDefaultDailyLimit(AccountType type) {
        return switch (type) {
            case SAVINGS, CHECKING -> new BigDecimal("5000.00");
            case MULTI_CURRENCY -> new BigDecimal("20000.00");
            case INVESTMENT -> new BigDecimal("100000.00");
            default -> new BigDecimal("1000.00");
        };
    }
    
    private BigDecimal getDefaultInterestRate(AccountType type) {
        return switch (type) {
            case SAVINGS -> new BigDecimal("0.025");
            case FIXED_DEPOSIT -> new BigDecimal("0.035");
            default -> BigDecimal.ZERO;
        };
    }
    
    private BigDecimal getExchangeRate(Currency from, Currency to) {
        // Simplified exchange rates - in production, fetch from exchange rate service
        Map<String, BigDecimal> rates = Map.of(
            "SGD_USD", new BigDecimal("0.74"),
            "USD_SGD", new BigDecimal("1.35"),
            "SGD_MYR", new BigDecimal("3.45"),
            "MYR_SGD", new BigDecimal("0.29"),
            "SGD_EUR", new BigDecimal("0.68"),
            "EUR_SGD", new BigDecimal("1.47")
        );
        
        String key = from.name() + "_" + to.name();
        return rates.getOrDefault(key, BigDecimal.ONE);
    }
    
    private void resetDailyLimitIfNeeded(Account account) {
        if (account.getLastTransferDate() == null || 
            !account.getLastTransferDate().equals(LocalDate.now())) {
            account.setDailyTransferredAmount(BigDecimal.ZERO);
            account.setLastTransferDate(LocalDate.now());
        }
    }
    
    private AccountResponse mapToResponse(Account account) {
        return AccountResponse.builder()
                .id(account.getId())
                .accountNumber(account.getAccountNumber())
                .userId(account.getUserId())
                .accountType(account.getAccountType().name())
                .accountName(account.getAccountName())
                .currency(account.getCurrency().name())
                .balance(account.getBalance())
                .availableBalance(account.getAvailableBalance())
                .holdAmount(account.getHoldAmount())
                .dailyTransferLimit(account.getDailyTransferLimit())
                .dailyTransferredAmount(account.getDailyTransferredAmount())
                .interestRate(account.getInterestRate())
                .status(account.getStatus().name())
                .isPrimary(account.isPrimary())
                .openedDate(account.getOpenedDate())
                .lastActivityDate(account.getLastActivityDate())
                .build();
    }
    
    private void publishAccountEvent(String eventType, Account account) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("eventType", eventType);
            event.put("accountId", account.getId());
            event.put("accountNumber", account.getAccountNumber());
            event.put("userId", account.getUserId());
            event.put("status", account.getStatus().name());
            event.put("timestamp", LocalDateTime.now().toString());
            
            kafkaTemplate.send(ACCOUNT_EVENTS_TOPIC, account.getId().toString(), event);
            log.debug("Published account event: {} for account: {}", eventType, account.getAccountNumber());
        } catch (Exception e) {
            log.error("Failed to publish account event: {}", e.getMessage());
        }
    }
    
    private void publishTransactionEvent(String referenceNumber, Account from, Account to, 
                                         BigDecimal amount, BigDecimal convertedAmount, String description) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("eventType", "TRANSFER_COMPLETED");
            event.put("referenceNumber", referenceNumber);
            event.put("fromAccountId", from.getId());
            event.put("fromAccountNumber", from.getAccountNumber());
            event.put("toAccountId", to.getId());
            event.put("toAccountNumber", to.getAccountNumber());
            event.put("amount", amount);
            event.put("convertedAmount", convertedAmount);
            event.put("fromCurrency", from.getCurrency().name());
            event.put("toCurrency", to.getCurrency().name());
            event.put("description", description);
            event.put("timestamp", LocalDateTime.now().toString());
            
            kafkaTemplate.send(TRANSACTION_EVENTS_TOPIC, referenceNumber, event);
            log.debug("Published transaction event: {}", referenceNumber);
        } catch (Exception e) {
            log.error("Failed to publish transaction event: {}", e.getMessage());
        }
    }
}
