package com.sibehgoodbank.transactionservice.service;

import com.sibehgoodbank.transactionservice.dto.CreateTransactionRequest;
import com.sibehgoodbank.transactionservice.dto.FraudCheckResult;
import com.sibehgoodbank.transactionservice.entity.Transaction;
import com.sibehgoodbank.transactionservice.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class FraudDetectionService {
    
    private final TransactionRepository transactionRepository;
    private final RedisTemplate<String, Object> redisTemplate;
    
    private static final String VELOCITY_KEY_PREFIX = "fraud:velocity:";
    private static final String BLACKLIST_KEY = "fraud:blacklist";
    private static final String SUSPICIOUS_IP_KEY = "fraud:suspicious_ips";
    
    // Thresholds
    private static final BigDecimal HIGH_VALUE_THRESHOLD = new BigDecimal("10000.00");
    private static final BigDecimal VERY_HIGH_VALUE_THRESHOLD = new BigDecimal("50000.00");
    private static final int MAX_TRANSACTIONS_PER_HOUR = 20;
    private static final int MAX_TRANSACTIONS_PER_DAY = 100;
    private static final BigDecimal MAX_AMOUNT_PER_HOUR = new BigDecimal("50000.00");
    
    public FraudCheckResult analyzeTransaction(CreateTransactionRequest request, UUID userId) {
        log.info("Analyzing transaction for fraud - User: {}, Amount: {}", userId, request.getAmount());
        
        List<String> riskFactors = new ArrayList<>();
        Map<String, Object> analysisDetails = new HashMap<>();
        int totalScore = 0;
        
        // 1. Check high value transaction
        int valueScore = checkTransactionValue(request.getAmount(), riskFactors, analysisDetails);
        totalScore += valueScore;
        
        // 2. Check velocity (transaction frequency)
        int velocityScore = checkVelocity(userId, riskFactors, analysisDetails);
        totalScore += velocityScore;
        
        // 3. Check IP reputation
        int ipScore = checkIpReputation(request.getIpAddress(), riskFactors, analysisDetails);
        totalScore += ipScore;
        
        // 4. Check device reputation
        int deviceScore = checkDeviceReputation(request.getDeviceId(), riskFactors, analysisDetails);
        totalScore += deviceScore;
        
        // 5. Check for unusual patterns
        int patternScore = checkUnusualPatterns(userId, request, riskFactors, analysisDetails);
        totalScore += patternScore;
        
        // 6. Check geographic anomalies
        int geoScore = checkGeographicAnomalies(userId, request.getLocation(), riskFactors, analysisDetails);
        totalScore += geoScore;
        
        // 7. Check blacklist
        int blacklistScore = checkBlacklist(request, riskFactors, analysisDetails);
        totalScore += blacklistScore;
        
        // 8. Check time-based anomalies
        int timeScore = checkTimeAnomalies(riskFactors, analysisDetails);
        totalScore += timeScore;
        
        // Cap the score at 100
        totalScore = Math.min(totalScore, 100);
        
        // Determine if flagged
        boolean isFlagged = totalScore >= 60;
        String flagReason = isFlagged ? buildFlagReason(riskFactors) : null;
        String recommendedAction = determineAction(totalScore);
        
        // Record velocity
        recordVelocity(userId, request.getAmount());
        
        log.info("Fraud analysis complete - User: {}, Score: {}, Flagged: {}", userId, totalScore, isFlagged);
        
        return FraudCheckResult.builder()
                .riskScore(totalScore)
                .isFlagged(isFlagged)
                .flagReason(flagReason)
                .riskFactors(riskFactors)
                .analysisDetails(analysisDetails)
                .recommendedAction(recommendedAction)
                .build();
    }
    
    private int checkTransactionValue(BigDecimal amount, List<String> riskFactors, Map<String, Object> details) {
        int score = 0;
        
        if (amount.compareTo(VERY_HIGH_VALUE_THRESHOLD) >= 0) {
            score = 30;
            riskFactors.add("Very high value transaction");
        } else if (amount.compareTo(HIGH_VALUE_THRESHOLD) >= 0) {
            score = 15;
            riskFactors.add("High value transaction");
        }
        
        details.put("transactionAmount", amount);
        details.put("highValueThreshold", HIGH_VALUE_THRESHOLD);
        details.put("valueRiskScore", score);
        
        return score;
    }
    
    private int checkVelocity(UUID userId, List<String> riskFactors, Map<String, Object> details) {
        String hourKey = VELOCITY_KEY_PREFIX + userId + ":hour:" + LocalDateTime.now().getHour();
        String dayKey = VELOCITY_KEY_PREFIX + userId + ":day:" + LocalDateTime.now().getDayOfYear();
        
        Integer hourlyCount = (Integer) redisTemplate.opsForValue().get(hourKey);
        Integer dailyCount = (Integer) redisTemplate.opsForValue().get(dayKey);
        
        hourlyCount = hourlyCount != null ? hourlyCount : 0;
        dailyCount = dailyCount != null ? dailyCount : 0;
        
        int score = 0;
        
        if (hourlyCount >= MAX_TRANSACTIONS_PER_HOUR) {
            score = 25;
            riskFactors.add("Exceeded hourly transaction limit");
        } else if (hourlyCount >= MAX_TRANSACTIONS_PER_HOUR * 0.8) {
            score = 15;
            riskFactors.add("Approaching hourly transaction limit");
        }
        
        if (dailyCount >= MAX_TRANSACTIONS_PER_DAY) {
            score = Math.max(score, 20);
            riskFactors.add("Exceeded daily transaction limit");
        }
        
        details.put("hourlyTransactionCount", hourlyCount);
        details.put("dailyTransactionCount", dailyCount);
        details.put("velocityRiskScore", score);
        
        return score;
    }
    
    private int checkIpReputation(String ipAddress, List<String> riskFactors, Map<String, Object> details) {
        if (ipAddress == null) {
            riskFactors.add("No IP address provided");
            return 10;
        }
        
        int score = 0;
        
        // Check if IP is in suspicious list
        Boolean isSuspicious = redisTemplate.opsForSet().isMember(SUSPICIOUS_IP_KEY, ipAddress);
        if (Boolean.TRUE.equals(isSuspicious)) {
            score = 20;
            riskFactors.add("IP address flagged as suspicious");
        }
        
        // Check for VPN/Proxy indicators (simplified)
        if (ipAddress.startsWith("10.") || ipAddress.startsWith("192.168.")) {
            score = Math.max(score, 5);
            riskFactors.add("Private IP range detected");
        }
        
        details.put("ipAddress", ipAddress);
        details.put("ipRiskScore", score);
        
        return score;
    }
    
    private int checkDeviceReputation(String deviceId, List<String> riskFactors, Map<String, Object> details) {
        if (deviceId == null || deviceId.isEmpty()) {
            riskFactors.add("No device identifier");
            return 10;
        }
        
        // Check device blacklist
        String deviceBlacklistKey = "fraud:device_blacklist";
        Boolean isBlacklisted = redisTemplate.opsForSet().isMember(deviceBlacklistKey, deviceId);
        
        int score = Boolean.TRUE.equals(isBlacklisted) ? 30 : 0;
        if (score > 0) {
            riskFactors.add("Device is blacklisted");
        }
        
        details.put("deviceId", deviceId);
        details.put("deviceRiskScore", score);
        
        return score;
    }
    
    private int checkUnusualPatterns(UUID userId, CreateTransactionRequest request, 
                                     List<String> riskFactors, Map<String, Object> details) {
        int score = 0;
        
        // Check against user's historical patterns
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        
        List<Transaction.TransactionType> types = List.of(
                Transaction.TransactionType.INTERNAL_TRANSFER,
                Transaction.TransactionType.EXTERNAL_TRANSFER,
                Transaction.TransactionType.INTERNATIONAL_TRANSFER
        );
        
        BigDecimal recentTotal = transactionRepository.sumAmountByUserAndTypesSince(userId, types, thirtyDaysAgo);
        
        if (recentTotal != null && request.getAmount().compareTo(recentTotal.multiply(new BigDecimal("0.5"))) > 0) {
            score = 15;
            riskFactors.add("Transaction amount significantly exceeds recent average");
        }
        
        // Check for new beneficiary
        if (request.getBeneficiaryName() != null && !request.getBeneficiaryName().isEmpty()) {
            // In production, check against known beneficiaries
            details.put("newBeneficiary", true);
        }
        
        details.put("patternRiskScore", score);
        
        return score;
    }
    
    private int checkGeographicAnomalies(UUID userId, String location, 
                                         List<String> riskFactors, Map<String, Object> details) {
        if (location == null || location.isEmpty()) {
            return 5;
        }
        
        int score = 0;
        
        // Check last known location
        String lastLocationKey = "user:last_location:" + userId;
        String lastLocation = (String) redisTemplate.opsForValue().get(lastLocationKey);
        
        if (lastLocation != null && !lastLocation.equals(location)) {
            // Check time since last transaction from different location
            String lastTimestampKey = "user:last_transaction_time:" + userId;
            Long lastTimestamp = (Long) redisTemplate.opsForValue().get(lastTimestampKey);
            
            if (lastTimestamp != null) {
                long minutesSinceLastTransaction = Duration.between(
                        LocalDateTime.ofEpochSecond(lastTimestamp, 0, java.time.ZoneOffset.UTC),
                        LocalDateTime.now()
                ).toMinutes();
                
                // If location changed within 30 minutes, suspicious
                if (minutesSinceLastTransaction < 30) {
                    score = 20;
                    riskFactors.add("Rapid location change detected");
                }
            }
        }
        
        // Update last location
        redisTemplate.opsForValue().set(lastLocationKey, location, 24, TimeUnit.HOURS);
        redisTemplate.opsForValue().set("user:last_transaction_time:" + userId, 
                System.currentTimeMillis() / 1000, 24, TimeUnit.HOURS);
        
        details.put("location", location);
        details.put("geoRiskScore", score);
        
        return score;
    }
    
    private int checkBlacklist(CreateTransactionRequest request, List<String> riskFactors, Map<String, Object> details) {
        int score = 0;
        
        // Check destination account blacklist
        if (request.getToAccountNumber() != null) {
            Boolean isBlacklisted = redisTemplate.opsForSet().isMember(BLACKLIST_KEY, request.getToAccountNumber());
            if (Boolean.TRUE.equals(isBlacklisted)) {
                score = 50;
                riskFactors.add("Destination account is blacklisted");
            }
        }
        
        if (request.getToExternalAccount() != null) {
            Boolean isBlacklisted = redisTemplate.opsForSet().isMember(BLACKLIST_KEY, request.getToExternalAccount());
            if (Boolean.TRUE.equals(isBlacklisted)) {
                score = 50;
                riskFactors.add("External destination account is blacklisted");
            }
        }
        
        details.put("blacklistRiskScore", score);
        
        return score;
    }
    
    private int checkTimeAnomalies(List<String> riskFactors, Map<String, Object> details) {
        int score = 0;
        int currentHour = LocalDateTime.now().getHour();
        
        // Transactions between 1 AM and 5 AM are unusual
        if (currentHour >= 1 && currentHour <= 5) {
            score = 10;
            riskFactors.add("Transaction at unusual hour");
        }
        
        details.put("transactionHour", currentHour);
        details.put("timeRiskScore", score);
        
        return score;
    }
    
    private void recordVelocity(UUID userId, BigDecimal amount) {
        String hourKey = VELOCITY_KEY_PREFIX + userId + ":hour:" + LocalDateTime.now().getHour();
        String dayKey = VELOCITY_KEY_PREFIX + userId + ":day:" + LocalDateTime.now().getDayOfYear();
        String amountKey = VELOCITY_KEY_PREFIX + userId + ":amount:" + LocalDateTime.now().getHour();
        
        redisTemplate.opsForValue().increment(hourKey);
        redisTemplate.expire(hourKey, Duration.ofHours(2));
        
        redisTemplate.opsForValue().increment(dayKey);
        redisTemplate.expire(dayKey, Duration.ofDays(2));
        
        // Track amount
        Double currentAmount = (Double) redisTemplate.opsForValue().get(amountKey);
        if (currentAmount == null) {
            currentAmount = 0.0;
        }
        redisTemplate.opsForValue().set(amountKey, currentAmount + amount.doubleValue());
        redisTemplate.expire(amountKey, Duration.ofHours(2));
    }
    
    private String buildFlagReason(List<String> riskFactors) {
        if (riskFactors.isEmpty()) {
            return "Multiple risk indicators detected";
        }
        return String.join("; ", riskFactors.subList(0, Math.min(3, riskFactors.size())));
    }
    
    private String determineAction(int score) {
        if (score >= 80) {
            return "BLOCK";
        } else if (score >= 60) {
            return "REQUIRE_MANUAL_REVIEW";
        } else if (score >= 40) {
            return "REQUIRE_2FA";
        } else {
            return "ALLOW";
        }
    }
    
    // Admin methods
    public void addToBlacklist(String accountNumber, String reason) {
        redisTemplate.opsForSet().add(BLACKLIST_KEY, accountNumber);
        log.warn("Added account to blacklist: {} - Reason: {}", accountNumber, reason);
    }
    
    public void removeFromBlacklist(String accountNumber) {
        redisTemplate.opsForSet().remove(BLACKLIST_KEY, accountNumber);
        log.info("Removed account from blacklist: {}", accountNumber);
    }
    
    public void addSuspiciousIp(String ipAddress, String reason) {
        redisTemplate.opsForSet().add(SUSPICIOUS_IP_KEY, ipAddress);
        log.warn("Added IP to suspicious list: {} - Reason: {}", ipAddress, reason);
    }
}
