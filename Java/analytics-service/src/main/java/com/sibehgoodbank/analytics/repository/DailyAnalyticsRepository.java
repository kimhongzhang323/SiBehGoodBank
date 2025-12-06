package com.sibehgoodbank.analytics.repository;

import com.sibehgoodbank.analytics.entity.DailyAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DailyAnalyticsRepository extends JpaRepository<DailyAnalytics, UUID> {

    Optional<DailyAnalytics> findByAnalyticsDateAndUserIdIsNull(LocalDate date);

    Optional<DailyAnalytics> findByAnalyticsDateAndUserId(LocalDate date, UUID userId);

    List<DailyAnalytics> findByAnalyticsDateBetweenAndUserIdIsNullOrderByAnalyticsDateAsc(
            LocalDate startDate, LocalDate endDate);

    List<DailyAnalytics> findByUserIdAndAnalyticsDateBetweenOrderByAnalyticsDateAsc(
            UUID userId, LocalDate startDate, LocalDate endDate);

    @Query("SELECT SUM(d.totalTransactionVolume) FROM DailyAnalytics d " +
            "WHERE d.analyticsDate BETWEEN :startDate AND :endDate AND d.userId IS NULL")
    BigDecimal sumTransactionVolumeForPeriod(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT SUM(d.totalTransactionCount) FROM DailyAnalytics d " +
            "WHERE d.analyticsDate BETWEEN :startDate AND :endDate AND d.userId IS NULL")
    Long sumTransactionCountForPeriod(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT SUM(d.newUsersRegistered) FROM DailyAnalytics d " +
            "WHERE d.analyticsDate BETWEEN :startDate AND :endDate AND d.userId IS NULL")
    Long sumNewUsersForPeriod(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT AVG(d.activeUsers) FROM DailyAnalytics d " +
            "WHERE d.analyticsDate BETWEEN :startDate AND :endDate AND d.userId IS NULL")
    Double avgActiveUsersForPeriod(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT SUM(d.fraudAlertsGenerated) FROM DailyAnalytics d " +
            "WHERE d.analyticsDate BETWEEN :startDate AND :endDate AND d.userId IS NULL")
    Long sumFraudAlertsForPeriod(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
