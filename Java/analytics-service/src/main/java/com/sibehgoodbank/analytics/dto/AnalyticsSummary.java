package com.sibehgoodbank.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AnalyticsSummary {

    private LocalDate startDate;
    private LocalDate endDate;
    private String period;
    
    // Transaction metrics
    private BigDecimal totalTransactionVolume;
    private Long totalTransactionCount;
    private Long successfulTransactions;
    private Long failedTransactions;
    private BigDecimal averageTransactionAmount;
    private Double successRate;
    
    // Account metrics
    private Long totalAccounts;
    private Long activeAccounts;
    private BigDecimal totalDeposits;
    private BigDecimal totalWithdrawals;
    private BigDecimal netFlow;
    
    // User metrics
    private Long totalUsers;
    private Long newUsers;
    private Long activeUsers;
    private Double averageLoginCount;
    
    // Security metrics
    private Long fraudAlerts;
    private Long suspiciousActivities;
    private Double fraudRate;
    
    // Growth metrics
    private Double userGrowthRate;
    private Double transactionGrowthRate;
    private Double volumeGrowthRate;
}
