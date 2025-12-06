package com.sibehgoodbank.transactionservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionAnalytics {
    
    private int totalTransactions;
    private BigDecimal totalAmount;
    private BigDecimal totalFees;
    private BigDecimal averageTransactionAmount;
    private BigDecimal largestTransaction;
    private BigDecimal smallestTransaction;
    
    private Map<String, TypeStats> statsByType;
    private Map<String, CurrencyStats> statsByCurrency;
    private Map<String, ChannelStats> statsByChannel;
    
    private List<DailyStats> dailyBreakdown;
    
    private LocalDateTime periodStart;
    private LocalDateTime periodEnd;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TypeStats {
        private String transactionType;
        private int count;
        private BigDecimal totalAmount;
        private BigDecimal averageAmount;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CurrencyStats {
        private String currency;
        private int count;
        private BigDecimal totalAmount;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ChannelStats {
        private String channel;
        private int count;
        private BigDecimal totalAmount;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyStats {
        private LocalDateTime date;
        private int transactionCount;
        private BigDecimal totalAmount;
        private BigDecimal inflow;
        private BigDecimal outflow;
    }
}
