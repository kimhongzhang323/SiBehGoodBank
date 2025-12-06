package com.sibehgoodbank.analytics.service.impl;

import com.sibehgoodbank.analytics.dto.AnalyticsSummary;
import com.sibehgoodbank.analytics.entity.DailyAnalytics;
import com.sibehgoodbank.analytics.repository.DailyAnalyticsRepository;
import com.sibehgoodbank.analytics.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class AnalyticsServiceImpl implements AnalyticsService {

    private final DailyAnalyticsRepository dailyAnalyticsRepository;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String CACHE_KEY_PREFIX = "analytics:";
    private static final long CACHE_TTL_HOURS = 1;

    @Override
    public AnalyticsSummary getDashboardSummary() {
        String cacheKey = CACHE_KEY_PREFIX + "dashboard";
        AnalyticsSummary cached = (AnalyticsSummary) redisTemplate.opsForValue().get(cacheKey);
        if (cached != null) {
            return cached;
        }

        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(30);
        
        AnalyticsSummary summary = getSummaryForPeriod(startDate, endDate);
        redisTemplate.opsForValue().set(cacheKey, summary, CACHE_TTL_HOURS, TimeUnit.HOURS);
        
        return summary;
    }

    @Override
    public AnalyticsSummary getSummaryForPeriod(LocalDate startDate, LocalDate endDate) {
        BigDecimal totalVolume = dailyAnalyticsRepository.sumTransactionVolumeForPeriod(startDate, endDate);
        Long totalCount = dailyAnalyticsRepository.sumTransactionCountForPeriod(startDate, endDate);
        Long newUsers = dailyAnalyticsRepository.sumNewUsersForPeriod(startDate, endDate);
        Double avgActiveUsers = dailyAnalyticsRepository.avgActiveUsersForPeriod(startDate, endDate);
        Long fraudAlerts = dailyAnalyticsRepository.sumFraudAlertsForPeriod(startDate, endDate);

        List<DailyAnalytics> dailyData = dailyAnalyticsRepository
                .findByAnalyticsDateBetweenAndUserIdIsNullOrderByAnalyticsDateAsc(startDate, endDate);

        long successCount = dailyData.stream()
                .mapToLong(d -> d.getSuccessfulTransactions() != null ? d.getSuccessfulTransactions() : 0)
                .sum();
        
        long failedCount = dailyData.stream()
                .mapToLong(d -> d.getFailedTransactions() != null ? d.getFailedTransactions() : 0)
                .sum();

        BigDecimal totalDeposits = dailyData.stream()
                .map(DailyAnalytics::getTotalDeposits)
                .filter(d -> d != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalWithdrawals = dailyData.stream()
                .map(DailyAnalytics::getTotalWithdrawals)
                .filter(d -> d != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        double successRate = totalCount != null && totalCount > 0 
                ? (double) successCount / totalCount * 100 
                : 0.0;

        BigDecimal avgTransaction = totalCount != null && totalCount > 0 && totalVolume != null
                ? totalVolume.divide(BigDecimal.valueOf(totalCount), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        double fraudRate = totalCount != null && totalCount > 0 && fraudAlerts != null
                ? (double) fraudAlerts / totalCount * 100
                : 0.0;

        return AnalyticsSummary.builder()
                .startDate(startDate)
                .endDate(endDate)
                .period(ChronoUnit.DAYS.between(startDate, endDate) + " days")
                .totalTransactionVolume(totalVolume != null ? totalVolume : BigDecimal.ZERO)
                .totalTransactionCount(totalCount != null ? totalCount : 0L)
                .successfulTransactions(successCount)
                .failedTransactions(failedCount)
                .averageTransactionAmount(avgTransaction)
                .successRate(successRate)
                .totalDeposits(totalDeposits)
                .totalWithdrawals(totalWithdrawals)
                .netFlow(totalDeposits.subtract(totalWithdrawals))
                .newUsers(newUsers != null ? newUsers : 0L)
                .activeUsers(avgActiveUsers != null ? avgActiveUsers.longValue() : 0L)
                .fraudAlerts(fraudAlerts != null ? fraudAlerts : 0L)
                .fraudRate(fraudRate)
                .build();
    }

    @Override
    public AnalyticsSummary getUserAnalytics(UUID userId, LocalDate startDate, LocalDate endDate) {
        List<DailyAnalytics> userData = dailyAnalyticsRepository
                .findByUserIdAndAnalyticsDateBetweenOrderByAnalyticsDateAsc(userId, startDate, endDate);

        BigDecimal totalVolume = userData.stream()
                .map(DailyAnalytics::getTotalTransactionVolume)
                .filter(v -> v != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long totalCount = userData.stream()
                .mapToLong(d -> d.getTotalTransactionCount() != null ? d.getTotalTransactionCount() : 0)
                .sum();

        long successCount = userData.stream()
                .mapToLong(d -> d.getSuccessfulTransactions() != null ? d.getSuccessfulTransactions() : 0)
                .sum();

        return AnalyticsSummary.builder()
                .startDate(startDate)
                .endDate(endDate)
                .period(ChronoUnit.DAYS.between(startDate, endDate) + " days")
                .totalTransactionVolume(totalVolume)
                .totalTransactionCount(totalCount)
                .successfulTransactions(successCount)
                .failedTransactions(totalCount - successCount)
                .successRate(totalCount > 0 ? (double) successCount / totalCount * 100 : 0.0)
                .build();
    }

    @Override
    public List<DailyAnalytics> getDailyTrend(LocalDate startDate, LocalDate endDate) {
        return dailyAnalyticsRepository
                .findByAnalyticsDateBetweenAndUserIdIsNullOrderByAnalyticsDateAsc(startDate, endDate);
    }

    @Override
    public List<DailyAnalytics> getUserDailyTrend(UUID userId, LocalDate startDate, LocalDate endDate) {
        return dailyAnalyticsRepository
                .findByUserIdAndAnalyticsDateBetweenOrderByAnalyticsDateAsc(userId, startDate, endDate);
    }

    @Override
    @Transactional
    public void recordTransactionEvent(UUID userId, BigDecimal amount, String transactionType, boolean successful) {
        log.debug("Recording transaction event: type={}, user={}, amount={}, successful={}", 
                transactionType, userId, amount, successful);
        
        LocalDate today = LocalDate.now();
        DailyAnalytics analytics = getOrCreateDailyAnalytics(today, userId);
        
        analytics.setTotalTransactionCount(analytics.getTotalTransactionCount() + 1);
        analytics.setTotalTransactionVolume(analytics.getTotalTransactionVolume().add(amount));
        
        if (successful) {
            analytics.setSuccessfulTransactions(analytics.getSuccessfulTransactions() + 1);
        } else {
            analytics.setFailedTransactions(analytics.getFailedTransactions() + 1);
        }
        
        switch (transactionType) {
            case "DEPOSIT", "TRANSFER_IN" -> 
                analytics.setTotalDeposits(analytics.getTotalDeposits().add(amount));
            case "WITHDRAWAL", "TRANSFER_OUT" -> 
                analytics.setTotalWithdrawals(analytics.getTotalWithdrawals().add(amount));
        }
        
        dailyAnalyticsRepository.save(analytics);
    }

    @Override
    @Transactional
    public void recordUserEvent(UUID userId, String eventType) {
        log.debug("Recording user event: {} for user: {}", eventType, userId);
        
        LocalDate today = LocalDate.now();
        DailyAnalytics analytics = getOrCreateDailyAnalytics(today, null);
        
        switch (eventType) {
            case "REGISTRATION" -> analytics.setNewUsersRegistered(analytics.getNewUsersRegistered() + 1);
            case "LOGIN" -> {
                analytics.setLoginCount(analytics.getLoginCount() + 1);
                analytics.setActiveUsers(analytics.getActiveUsers() + 1);
            }
            case "ACCOUNT_CREATED" -> analytics.setNewAccountsCreated(analytics.getNewAccountsCreated() + 1);
        }
        
        dailyAnalyticsRepository.save(analytics);
    }

    @Override
    @Transactional
    public void recordSecurityEvent(UUID userId, String eventType, String severity) {
        log.debug("Recording security event: {} for user: {}, severity: {}", eventType, userId, severity);
        
        LocalDate today = LocalDate.now();
        DailyAnalytics analytics = getOrCreateDailyAnalytics(today, null);
        
        switch (eventType) {
            case "FRAUD_ALERT" -> analytics.setFraudAlertsGenerated(analytics.getFraudAlertsGenerated() + 1);
            case "SUSPICIOUS_ACTIVITY", "LOGIN_ANOMALY", "LARGE_TRANSACTION" -> 
                analytics.setSuspiciousActivities(analytics.getSuspiciousActivities() + 1);
        }
        
        dailyAnalyticsRepository.save(analytics);
    }

    private DailyAnalytics getOrCreateDailyAnalytics(LocalDate date, UUID userId) {
        if (userId != null) {
            return dailyAnalyticsRepository
                    .findByUserIdAndAnalyticsDateBetweenOrderByAnalyticsDateAsc(userId, date, date)
                    .stream()
                    .findFirst()
                    .orElseGet(() -> createNewDailyAnalytics(date, userId));
        }
        return dailyAnalyticsRepository.findByAnalyticsDateAndUserIdIsNull(date)
                .orElseGet(() -> createNewDailyAnalytics(date, null));
    }

    private DailyAnalytics createNewDailyAnalytics(LocalDate date, UUID userId) {
        return DailyAnalytics.builder()
                .analyticsDate(date)
                .userId(userId)
                .totalTransactionVolume(BigDecimal.ZERO)
                .totalTransactionCount(0L)
                .successfulTransactions(0L)
                .failedTransactions(0L)
                .averageTransactionAmount(BigDecimal.ZERO)
                .newAccountsCreated(0L)
                .activeAccounts(0L)
                .totalDeposits(BigDecimal.ZERO)
                .totalWithdrawals(BigDecimal.ZERO)
                .newUsersRegistered(0L)
                .activeUsers(0L)
                .loginCount(0L)
                .fraudAlertsGenerated(0L)
                .suspiciousActivities(0L)
                .currency("USD")
                .build();
    }

    @Override
    @Transactional
    public void generateDailyAnalytics(LocalDate date) {
        log.info("Generating daily analytics for: {}", date);
        
        // Check if already exists
        if (dailyAnalyticsRepository.findByAnalyticsDateAndUserIdIsNull(date).isPresent()) {
            log.info("Daily analytics already exists for: {}", date);
            return;
        }

        // Create placeholder - real implementation would aggregate from events
        DailyAnalytics analytics = DailyAnalytics.builder()
                .analyticsDate(date)
                .totalTransactionVolume(BigDecimal.ZERO)
                .totalTransactionCount(0L)
                .successfulTransactions(0L)
                .failedTransactions(0L)
                .averageTransactionAmount(BigDecimal.ZERO)
                .newAccountsCreated(0L)
                .activeAccounts(0L)
                .totalDeposits(BigDecimal.ZERO)
                .totalWithdrawals(BigDecimal.ZERO)
                .newUsersRegistered(0L)
                .activeUsers(0L)
                .loginCount(0L)
                .fraudAlertsGenerated(0L)
                .suspiciousActivities(0L)
                .currency("USD")
                .build();

        dailyAnalyticsRepository.save(analytics);
        log.info("Daily analytics created for: {}", date);
    }

    @Override
    public void refreshCachedAnalytics() {
        log.info("Refreshing cached analytics");
        redisTemplate.delete(CACHE_KEY_PREFIX + "dashboard");
        getDashboardSummary(); // Repopulate cache
    }

    @Scheduled(cron = "0 5 0 * * ?") // Run at 00:05 every day
    public void scheduledDailyAnalyticsGeneration() {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        generateDailyAnalytics(yesterday);
    }

    @Scheduled(cron = "0 0 * * * ?") // Run every hour
    public void scheduledCacheRefresh() {
        refreshCachedAnalytics();
    }
}
