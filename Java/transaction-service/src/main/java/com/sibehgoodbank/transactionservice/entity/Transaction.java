package com.sibehgoodbank.transactionservice.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "transactions", indexes = {
    @Index(name = "idx_transactions_reference", columnList = "referenceNumber"),
    @Index(name = "idx_transactions_from_account", columnList = "fromAccountId"),
    @Index(name = "idx_transactions_to_account", columnList = "toAccountId"),
    @Index(name = "idx_transactions_user", columnList = "userId"),
    @Index(name = "idx_transactions_type", columnList = "transactionType"),
    @Index(name = "idx_transactions_status", columnList = "status"),
    @Index(name = "idx_transactions_created", columnList = "createdAt")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Transaction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(nullable = false, unique = true, length = 50)
    private String referenceNumber;
    
    @Column(nullable = false)
    private UUID userId;
    
    @Column(nullable = false)
    private UUID fromAccountId;
    
    @Column(nullable = false, length = 20)
    private String fromAccountNumber;
    
    private UUID toAccountId;
    
    @Column(length = 50)
    private String toAccountNumber;
    
    @Column(length = 100)
    private String toExternalAccount;
    
    @Column(length = 20)
    private String toBankCode;
    
    @Column(length = 100)
    private String beneficiaryName;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private TransactionType transactionType;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TransactionStatus status;
    
    @Column(nullable = false, precision = 19, scale = 4)
    private BigDecimal amount;
    
    @Column(precision = 19, scale = 4)
    private BigDecimal convertedAmount;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 3)
    private Currency fromCurrency;
    
    @Enumerated(EnumType.STRING)
    @Column(length = 3)
    private Currency toCurrency;
    
    @Column(precision = 19, scale = 8)
    private BigDecimal exchangeRate;
    
    @Column(precision = 19, scale = 4)
    private BigDecimal fee;
    
    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private FeeType feeType;
    
    @Column(length = 500)
    private String description;
    
    @Column(length = 500)
    private String remarks;
    
    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private TransactionChannel channel;
    
    @Column(length = 45)
    private String ipAddress;
    
    @Column(length = 100)
    private String deviceId;
    
    @Column(length = 50)
    private String deviceType;
    
    @Column(length = 100)
    private String location;
    
    // Fraud detection fields
    @Column(nullable = false)
    @Builder.Default
    private Integer riskScore = 0;
    
    @Column(nullable = false)
    @Builder.Default
    private Boolean isFlagged = false;
    
    @Column(length = 500)
    private String flagReason;
    
    @Column(nullable = false)
    @Builder.Default
    private Boolean isReviewed = false;
    
    private UUID reviewedBy;
    
    private LocalDateTime reviewedAt;
    
    @Column(length = 500)
    private String reviewNotes;
    
    // Scheduling
    private UUID scheduledTransferId;
    
    private LocalDateTime scheduledFor;
    
    private LocalDateTime processedAt;
    
    // Balance tracking
    @Column(precision = 19, scale = 4)
    private BigDecimal balanceBefore;
    
    @Column(precision = 19, scale = 4)
    private BigDecimal balanceAfter;
    
    @Column(length = 100)
    private String externalReferenceId;
    
    @Version
    private Long version;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    public enum TransactionType {
        INTERNAL_TRANSFER,
        EXTERNAL_TRANSFER,
        INTERBANK_TRANSFER,
        INTERNATIONAL_TRANSFER,
        BILL_PAYMENT,
        MERCHANT_PAYMENT,
        QR_PAYMENT,
        DEPOSIT,
        WITHDRAWAL,
        ATM_WITHDRAWAL,
        FEE,
        INTEREST,
        REFUND,
        REVERSAL,
        ADJUSTMENT,
        LOAN_DISBURSEMENT,
        LOAN_REPAYMENT,
        CARD_PURCHASE,
        CARD_REFUND
    }
    
    public enum TransactionStatus {
        PENDING,
        PROCESSING,
        COMPLETED,
        FAILED,
        CANCELLED,
        REVERSED,
        ON_HOLD,
        FLAGGED,
        UNDER_REVIEW,
        SCHEDULED,
        EXPIRED
    }
    
    public enum Currency {
        SGD, USD, EUR, GBP, JPY, CNY, HKD, AUD, MYR, THB, IDR
    }
    
    public enum FeeType {
        TRANSFER_FEE,
        INTERBANK_FEE,
        INTERNATIONAL_FEE,
        CURRENCY_CONVERSION,
        EXPEDITED_FEE,
        LATE_FEE,
        SERVICE_FEE,
        NONE
    }
    
    public enum TransactionChannel {
        MOBILE_APP,
        WEB_BANKING,
        ATM,
        BRANCH,
        PHONE_BANKING,
        API,
        SCHEDULED,
        THIRD_PARTY
    }
}
