package com.sibehgoodbank.analytics.service;

import com.sibehgoodbank.analytics.dto.AnalyticsSummary;
import com.sibehgoodbank.analytics.entity.DailyAnalytics;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface AnalyticsService {

    AnalyticsSummary getDashboardSummary();

    AnalyticsSummary getSummaryForPeriod(LocalDate startDate, LocalDate endDate);

    AnalyticsSummary getUserAnalytics(UUID userId, LocalDate startDate, LocalDate endDate);

    List<DailyAnalytics> getDailyTrend(LocalDate startDate, LocalDate endDate);

    List<DailyAnalytics> getUserDailyTrend(UUID userId, LocalDate startDate, LocalDate endDate);

    /**
     * Record a transaction event with amount and transaction type.
     */
    void recordTransactionEvent(UUID userId, BigDecimal amount, String transactionType, boolean successful);

    /**
     * Record a user event (login, registration, etc.).
     */
    void recordUserEvent(UUID userId, String eventType);

    /**
     * Record a security event (fraud alert, suspicious activity, etc.).
     */
    void recordSecurityEvent(UUID userId, String eventType, String severity);

    void generateDailyAnalytics(LocalDate date);

    void refreshCachedAnalytics();
}
