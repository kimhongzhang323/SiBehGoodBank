package com.sibehgoodbank.transactionservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FraudCheckResult {
    
    private int riskScore;
    private boolean isFlagged;
    private String flagReason;
    private List<String> riskFactors;
    private Map<String, Object> analysisDetails;
    private String recommendedAction;
    
    public enum RiskLevel {
        LOW(0, 30),
        MEDIUM(31, 60),
        HIGH(61, 80),
        CRITICAL(81, 100);
        
        private final int minScore;
        private final int maxScore;
        
        RiskLevel(int minScore, int maxScore) {
            this.minScore = minScore;
            this.maxScore = maxScore;
        }
        
        public static RiskLevel fromScore(int score) {
            for (RiskLevel level : values()) {
                if (score >= level.minScore && score <= level.maxScore) {
                    return level;
                }
            }
            return CRITICAL;
        }
    }
    
    public RiskLevel getRiskLevel() {
        return RiskLevel.fromScore(riskScore);
    }
}
