package com.sibehgoodbank.analytics.controller;

import com.sibehgoodbank.analytics.dto.AnalyticsSummary;
import com.sibehgoodbank.analytics.entity.DailyAnalytics;
import com.sibehgoodbank.analytics.service.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Analytics", description = "Analytics and reporting endpoints")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/dashboard")
    @Operation(summary = "Get dashboard summary", description = "Get analytics summary for last 30 days")
    public ResponseEntity<AnalyticsSummary> getDashboardSummary() {
        log.info("Getting dashboard summary");
        AnalyticsSummary summary = analyticsService.getDashboardSummary();
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/summary")
    @Operation(summary = "Get period summary", description = "Get analytics for a specific date range")
    public ResponseEntity<AnalyticsSummary> getPeriodSummary(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info("Getting summary for period: {} to {}", startDate, endDate);
        AnalyticsSummary summary = analyticsService.getSummaryForPeriod(startDate, endDate);
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user analytics", description = "Get analytics for a specific user")
    public ResponseEntity<AnalyticsSummary> getUserAnalytics(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info("Getting analytics for user: {} from {} to {}", userId, startDate, endDate);
        AnalyticsSummary summary = analyticsService.getUserAnalytics(userId, startDate, endDate);
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/trends/daily")
    @Operation(summary = "Get daily trends", description = "Get daily analytics data for trends")
    public ResponseEntity<List<DailyAnalytics>> getDailyTrends(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info("Getting daily trends from {} to {}", startDate, endDate);
        List<DailyAnalytics> trends = analyticsService.getDailyTrend(startDate, endDate);
        return ResponseEntity.ok(trends);
    }

    @GetMapping("/trends/user/{userId}")
    @Operation(summary = "Get user daily trends", description = "Get daily analytics for a specific user")
    public ResponseEntity<List<DailyAnalytics>> getUserDailyTrends(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info("Getting daily trends for user: {} from {} to {}", userId, startDate, endDate);
        List<DailyAnalytics> trends = analyticsService.getUserDailyTrend(userId, startDate, endDate);
        return ResponseEntity.ok(trends);
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh cache", description = "Refresh cached analytics data")
    public ResponseEntity<Map<String, String>> refreshCache() {
        log.info("Refreshing analytics cache");
        analyticsService.refreshCachedAnalytics();
        return ResponseEntity.ok(Map.of("message", "Cache refreshed successfully"));
    }

    @PostMapping("/generate/{date}")
    @Operation(summary = "Generate daily analytics", description = "Manually generate analytics for a specific date")
    public ResponseEntity<Map<String, String>> generateDailyAnalytics(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        log.info("Generating analytics for date: {}", date);
        analyticsService.generateDailyAnalytics(date);
        return ResponseEntity.ok(Map.of("message", "Analytics generated for " + date));
    }
}
