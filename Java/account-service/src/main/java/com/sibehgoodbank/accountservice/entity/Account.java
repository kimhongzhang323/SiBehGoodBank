package com.sibehgoodbank.accountservice.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Bank account entity supporting multi-currency
 */
@Entity
@Table(name = "accounts", indexes = {
        @Index(name = "idx_account_number", columnList = "account_number", unique = true),
        @Index(name = "idx_account_user", columnList = "user_id"),
        @Index(name = "idx_account_type", columnList = "account_type"),
        @Index(name = "idx_account_status", columnList = "status")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Account {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "account_number", nullable = false, unique = true, length = 20)
    private String accountNumber;

    @Column(name = "account_name", nullable = false, length = 100)
    private String accountName;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_type", nullable = false)
    private AccountType accountType;

    @Enumerated(EnumType.STRING)
    @Column(name = "currency", nullable = false)
    @Builder.Default
    private Currency currency = Currency.SGD;

    @Column(name = "balance", precision = 19, scale = 4, nullable = false)
    @Builder.Default
    private BigDecimal balance = BigDecimal.ZERO;

    @Column(name = "available_balance", precision = 19, scale = 4, nullable = false)
    @Builder.Default
    private BigDecimal availableBalance = BigDecimal.ZERO;

    @Column(name = "pending_balance", precision = 19, scale = 4)
    @Builder.Default
    private BigDecimal pendingBalance = BigDecimal.ZERO;

    @Column(name = "overdraft_limit", precision = 19, scale = 4)
    @Builder.Default
    private BigDecimal overdraftLimit = BigDecimal.ZERO;

    @Column(name = "daily_transfer_limit", precision = 19, scale = 4)
    @Builder.Default
    private BigDecimal dailyTransferLimit = new BigDecimal("10000");

    @Column(name = "daily_transfer_used", precision = 19, scale = 4)
    @Builder.Default
    private BigDecimal dailyTransferUsed = BigDecimal.ZERO;

    @Column(name = "interest_rate", precision = 5, scale = 4)
    @Builder.Default
    private BigDecimal interestRate = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @Builder.Default
    private AccountStatus status = AccountStatus.PENDING_ACTIVATION;

    @Column(name = "is_primary")
    @Builder.Default
    private boolean isPrimary = false;

    @Column(name = "iban", length = 34)
    private String iban;

    @Column(name = "swift_code", length = 11)
    private String swiftCode;

    @Column(name = "branch_code", length = 10)
    private String branchCode;

    // Audit fields
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "activated_at")
    private LocalDateTime activatedAt;

    @Column(name = "closed_at")
    private LocalDateTime closedAt;

    @Column(name = "last_transaction_at")
    private LocalDateTime lastTransactionAt;

    // Version for optimistic locking (critical for balance updates)
    @Version
    private Long version;

    public enum AccountType {
        SAVINGS,
        CURRENT,
        FIXED_DEPOSIT,
        INVESTMENT,
        JOINT,
        KIDS,
        BUSINESS
    }

    public enum Currency {
        SGD, USD, EUR, GBP, JPY, CNY, AUD, MYR, THB, IDR, PHP, VND, INR, KRW, HKD
    }

    public enum AccountStatus {
        PENDING_ACTIVATION,
        ACTIVE,
        DORMANT,
        FROZEN,
        CLOSED
    }

    // Business methods
    public boolean canDebit(BigDecimal amount) {
        BigDecimal effectiveBalance = availableBalance.add(overdraftLimit);
        return effectiveBalance.compareTo(amount) >= 0;
    }

    public void debit(BigDecimal amount) {
        if (!canDebit(amount)) {
            throw new IllegalStateException("Insufficient funds");
        }
        this.balance = this.balance.subtract(amount);
        this.availableBalance = this.availableBalance.subtract(amount);
        this.dailyTransferUsed = this.dailyTransferUsed.add(amount);
        this.lastTransactionAt = LocalDateTime.now();
    }

    public void credit(BigDecimal amount) {
        this.balance = this.balance.add(amount);
        this.availableBalance = this.availableBalance.add(amount);
        this.lastTransactionAt = LocalDateTime.now();
    }

    public void holdFunds(BigDecimal amount) {
        if (availableBalance.compareTo(amount) < 0) {
            throw new IllegalStateException("Insufficient available balance");
        }
        this.availableBalance = this.availableBalance.subtract(amount);
        this.pendingBalance = this.pendingBalance.add(amount);
    }

    public void releaseFunds(BigDecimal amount) {
        this.pendingBalance = this.pendingBalance.subtract(amount);
        this.availableBalance = this.availableBalance.add(amount);
    }

    public void resetDailyLimit() {
        this.dailyTransferUsed = BigDecimal.ZERO;
    }

    public boolean isWithinDailyLimit(BigDecimal amount) {
        return dailyTransferUsed.add(amount).compareTo(dailyTransferLimit) <= 0;
    }
}
