package com.sibehgoodbank.analytics.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "daily_analytics", indexes = {
        @Index(name = "idx_daily_analytics_date", columnList = "analyticsDate"),
        @Index(name = "idx_daily_analytics_user", columnList = "userId")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyAnalytics {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private LocalDate analyticsDate;

    private UUID userId;

    // Transaction metrics
    @Column(precision = 19, scale = 4)
    private BigDecimal totalTransactionVolume;
    
    private Long totalTransactionCount;
    
    private Long successfulTransactions;
    
    private Long failedTransactions;

    @Column(precision = 19, scale = 4)
    private BigDecimal averageTransactionAmount;

    // Account metrics
    private Long newAccountsCreated;
    
    private Long activeAccounts;
    
    @Column(precision = 19, scale = 4)
    private BigDecimal totalDeposits;
    
    @Column(precision = 19, scale = 4)
    private BigDecimal totalWithdrawals;

    // User metrics
    private Long newUsersRegistered;
    
    private Long activeUsers;
    
    private Long loginCount;

    // Security metrics
    private Long fraudAlertsGenerated;
    
    private Long suspiciousActivities;

    @Column(length = 3)
    private String currency;

    @CreationTimestamp
    private LocalDateTime createdAt;
}
