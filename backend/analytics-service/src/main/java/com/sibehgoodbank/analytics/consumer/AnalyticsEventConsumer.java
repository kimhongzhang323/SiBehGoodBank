package com.sibehgoodbank.analytics.consumer;

import com.sibehgoodbank.analytics.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

/**
 * Kafka consumer for processing analytics events from various services.
 * Listens to transaction, user, and account events to update analytics.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class AnalyticsEventConsumer {

    private final AnalyticsService analyticsService;

    /**
     * Consume transaction events for analytics processing.
     */
    @KafkaListener(
            topics = "${analytics.kafka.topics.transactions:transaction-events}",
            groupId = "${spring.kafka.consumer.group-id}",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeTransactionEvent(
            @Payload Map<String, Object> event,
            @Header(KafkaHeaders.RECEIVED_KEY) String key,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment acknowledgment
    ) {
        log.info("Received transaction event: key={}, topic={}, partition={}, offset={}",
                key, topic, partition, offset);

        try {
            processTransactionEvent(event);
            acknowledgment.acknowledge();
            log.debug("Transaction event processed successfully");
        } catch (Exception e) {
            log.error("Error processing transaction event: {}", e.getMessage(), e);
            // Don't acknowledge - will be reprocessed
        }
    }

    /**
     * Consume user events for analytics processing.
     */
    @KafkaListener(
            topics = "${analytics.kafka.topics.users:user-events}",
            groupId = "${spring.kafka.consumer.group-id}",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeUserEvent(
            @Payload Map<String, Object> event,
            @Header(KafkaHeaders.RECEIVED_KEY) String key,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            Acknowledgment acknowledgment
    ) {
        log.info("Received user event: key={}, topic={}", key, topic);

        try {
            processUserEvent(event);
            acknowledgment.acknowledge();
            log.debug("User event processed successfully");
        } catch (Exception e) {
            log.error("Error processing user event: {}", e.getMessage(), e);
        }
    }

    /**
     * Consume account events for analytics processing.
     */
    @KafkaListener(
            topics = "${analytics.kafka.topics.accounts:account-events}",
            groupId = "${spring.kafka.consumer.group-id}",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeAccountEvent(
            @Payload Map<String, Object> event,
            @Header(KafkaHeaders.RECEIVED_KEY) String key,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            Acknowledgment acknowledgment
    ) {
        log.info("Received account event: key={}, topic={}", key, topic);

        try {
            processAccountEvent(event);
            acknowledgment.acknowledge();
            log.debug("Account event processed successfully");
        } catch (Exception e) {
            log.error("Error processing account event: {}", e.getMessage(), e);
        }
    }

    /**
     * Consume security/fraud alert events.
     */
    @KafkaListener(
            topics = "${analytics.kafka.topics.security:security-events}",
            groupId = "${spring.kafka.consumer.group-id}",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeSecurityEvent(
            @Payload Map<String, Object> event,
            @Header(KafkaHeaders.RECEIVED_KEY) String key,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            Acknowledgment acknowledgment
    ) {
        log.info("Received security event: key={}, topic={}", key, topic);

        try {
            processSecurityEvent(event);
            acknowledgment.acknowledge();
            log.debug("Security event processed successfully");
        } catch (Exception e) {
            log.error("Error processing security event: {}", e.getMessage(), e);
        }
    }

    private void processTransactionEvent(Map<String, Object> event) {
        String eventType = getStringValue(event, "eventType");
        UUID userId = getUUIDValue(event, "userId");
        BigDecimal amount = getBigDecimalValue(event, "amount");
        String transactionType = getStringValue(event, "transactionType");
        String status = getStringValue(event, "status");

        log.debug("Processing transaction event: type={}, userId={}, amount={}, txType={}, status={}",
                eventType, userId, amount, transactionType, status);

        switch (eventType) {
            case "TRANSACTION_COMPLETED" -> {
                analyticsService.recordTransactionEvent(userId, amount, transactionType, true);
            }
            case "TRANSACTION_FAILED" -> {
                analyticsService.recordTransactionEvent(userId, amount, transactionType, false);
            }
            case "TRANSFER_COMPLETED" -> {
                UUID toUserId = getUUIDValue(event, "toUserId");
                analyticsService.recordTransactionEvent(userId, amount, "TRANSFER_OUT", true);
                if (toUserId != null) {
                    analyticsService.recordTransactionEvent(toUserId, amount, "TRANSFER_IN", true);
                }
            }
            case "DEPOSIT_COMPLETED" -> {
                analyticsService.recordTransactionEvent(userId, amount, "DEPOSIT", true);
            }
            case "WITHDRAWAL_COMPLETED" -> {
                analyticsService.recordTransactionEvent(userId, amount, "WITHDRAWAL", true);
            }
            default -> log.warn("Unknown transaction event type: {}", eventType);
        }
    }

    private void processUserEvent(Map<String, Object> event) {
        String eventType = getStringValue(event, "eventType");
        UUID userId = getUUIDValue(event, "userId");

        log.debug("Processing user event: type={}, userId={}", eventType, userId);

        switch (eventType) {
            case "USER_REGISTERED" -> analyticsService.recordUserEvent(userId, "REGISTRATION");
            case "USER_LOGIN" -> analyticsService.recordUserEvent(userId, "LOGIN");
            case "USER_LOGOUT" -> analyticsService.recordUserEvent(userId, "LOGOUT");
            case "USER_PROFILE_UPDATED" -> analyticsService.recordUserEvent(userId, "PROFILE_UPDATE");
            case "USER_ACTIVATED" -> analyticsService.recordUserEvent(userId, "ACTIVATION");
            case "USER_DEACTIVATED" -> analyticsService.recordUserEvent(userId, "DEACTIVATION");
            default -> log.warn("Unknown user event type: {}", eventType);
        }
    }

    private void processAccountEvent(Map<String, Object> event) {
        String eventType = getStringValue(event, "eventType");
        UUID userId = getUUIDValue(event, "userId");
        UUID accountId = getUUIDValue(event, "accountId");
        String accountType = getStringValue(event, "accountType");

        log.debug("Processing account event: type={}, userId={}, accountId={}, accountType={}",
                eventType, userId, accountId, accountType);

        switch (eventType) {
            case "ACCOUNT_CREATED" -> {
                analyticsService.recordUserEvent(userId, "ACCOUNT_CREATED");
            }
            case "ACCOUNT_CLOSED" -> {
                analyticsService.recordUserEvent(userId, "ACCOUNT_CLOSED");
            }
            case "ACCOUNT_SUSPENDED" -> {
                analyticsService.recordUserEvent(userId, "ACCOUNT_SUSPENDED");
            }
            case "ACCOUNT_REACTIVATED" -> {
                analyticsService.recordUserEvent(userId, "ACCOUNT_REACTIVATED");
            }
            default -> log.warn("Unknown account event type: {}", eventType);
        }
    }

    private void processSecurityEvent(Map<String, Object> event) {
        String eventType = getStringValue(event, "eventType");
        UUID userId = getUUIDValue(event, "userId");
        String severity = getStringValue(event, "severity");

        log.debug("Processing security event: type={}, userId={}, severity={}", eventType, userId, severity);

        switch (eventType) {
            case "FRAUD_ALERT" -> analyticsService.recordSecurityEvent(userId, "FRAUD_ALERT", severity);
            case "SUSPICIOUS_ACTIVITY" -> analyticsService.recordSecurityEvent(userId, "SUSPICIOUS_ACTIVITY", severity);
            case "LOGIN_ANOMALY" -> analyticsService.recordSecurityEvent(userId, "LOGIN_ANOMALY", severity);
            case "LARGE_TRANSACTION_ALERT" -> analyticsService.recordSecurityEvent(userId, "LARGE_TRANSACTION", severity);
            default -> log.warn("Unknown security event type: {}", eventType);
        }
    }

    private String getStringValue(Map<String, Object> event, String key) {
        Object value = event.get(key);
        return value != null ? value.toString() : null;
    }

    private UUID getUUIDValue(Map<String, Object> event, String key) {
        Object value = event.get(key);
        if (value == null) return null;
        if (value instanceof UUID) return (UUID) value;
        try {
            return UUID.fromString(value.toString());
        } catch (IllegalArgumentException e) {
            log.warn("Invalid UUID value for key {}: {}", key, value);
            return null;
        }
    }

    private BigDecimal getBigDecimalValue(Map<String, Object> event, String key) {
        Object value = event.get(key);
        if (value == null) return BigDecimal.ZERO;
        if (value instanceof BigDecimal) return (BigDecimal) value;
        if (value instanceof Number) return BigDecimal.valueOf(((Number) value).doubleValue());
        try {
            return new BigDecimal(value.toString());
        } catch (NumberFormatException e) {
            log.warn("Invalid BigDecimal value for key {}: {}", key, value);
            return BigDecimal.ZERO;
        }
    }
}
