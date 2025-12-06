package com.sibehgoodbank.notification.consumer;

import com.sibehgoodbank.notification.dto.SendNotificationRequest;
import com.sibehgoodbank.notification.entity.Notification.NotificationChannel;
import com.sibehgoodbank.notification.entity.Notification.NotificationPriority;
import com.sibehgoodbank.notification.entity.Notification.NotificationType;
import com.sibehgoodbank.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.Exchange;
import org.springframework.amqp.rabbit.annotation.Queue;
import org.springframework.amqp.rabbit.annotation.QueueBinding;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventConsumer {

    private final NotificationService notificationService;

    @RabbitListener(bindings = @QueueBinding(
            value = @Queue(value = "notification.transaction.queue", durable = "true"),
            exchange = @Exchange(value = "notification.exchange", type = "topic"),
            key = "notification.transaction.*"
    ))
    public void handleTransactionNotification(@Payload Map<String, Object> event) {
        log.info("Received transaction notification event: {}", event);
        
        try {
            String eventType = (String) event.get("eventType");
            UUID userId = UUID.fromString((String) event.get("userId"));
            
            SendNotificationRequest request = buildTransactionNotification(eventType, userId, event);
            notificationService.sendNotificationAsync(request);
            
        } catch (Exception e) {
            log.error("Failed to process transaction notification event", e);
        }
    }

    @RabbitListener(bindings = @QueueBinding(
            value = @Queue(value = "notification.security.queue", durable = "true"),
            exchange = @Exchange(value = "notification.exchange", type = "topic"),
            key = "notification.security.*"
    ))
    public void handleSecurityNotification(@Payload Map<String, Object> event) {
        log.info("Received security notification event: {}", event);
        
        try {
            String eventType = (String) event.get("eventType");
            UUID userId = UUID.fromString((String) event.get("userId"));
            
            SendNotificationRequest request = buildSecurityNotification(eventType, userId, event);
            notificationService.sendNotification(request);
            
        } catch (Exception e) {
            log.error("Failed to process security notification event", e);
        }
    }

    @RabbitListener(bindings = @QueueBinding(
            value = @Queue(value = "notification.account.queue", durable = "true"),
            exchange = @Exchange(value = "notification.exchange", type = "topic"),
            key = "notification.account.*"
    ))
    public void handleAccountNotification(@Payload Map<String, Object> event) {
        log.info("Received account notification event: {}", event);
        
        try {
            String eventType = (String) event.get("eventType");
            UUID userId = UUID.fromString((String) event.get("userId"));
            
            SendNotificationRequest request = buildAccountNotification(eventType, userId, event);
            notificationService.sendNotificationAsync(request);
            
        } catch (Exception e) {
            log.error("Failed to process account notification event", e);
        }
    }

    @RabbitListener(bindings = @QueueBinding(
            value = @Queue(value = "notification.otp.queue", durable = "true"),
            exchange = @Exchange(value = "notification.exchange", type = "topic"),
            key = "notification.otp.*"
    ))
    public void handleOtpNotification(@Payload Map<String, Object> event) {
        log.info("Received OTP notification event: {}", event);
        
        try {
            UUID userId = UUID.fromString((String) event.get("userId"));
            String channel = (String) event.get("channel");
            String purpose = (String) event.get("purpose");
            
            notificationService.sendOtp(userId, channel, purpose);
            
        } catch (Exception e) {
            log.error("Failed to process OTP notification event", e);
        }
    }

    @RabbitListener(bindings = @QueueBinding(
            value = @Queue(value = "notification.alert.queue", durable = "true"),
            exchange = @Exchange(value = "notification.exchange", type = "topic"),
            key = "notification.alert.*"
    ))
    public void handleAlertNotification(@Payload Map<String, Object> event) {
        log.info("Received alert notification event: {}", event);
        
        try {
            UUID userId = UUID.fromString((String) event.get("userId"));
            String alertType = (String) event.get("alertType");
            String message = (String) event.get("message");
            
            SendNotificationRequest request = SendNotificationRequest.builder()
                    .userId(userId)
                    .channel(NotificationChannel.PUSH)
                    .type(NotificationType.ALERT)
                    .priority(NotificationPriority.HIGH)
                    .subject("Banking Alert: " + alertType)
                    .body(message)
                    .templateData(event)
                    .build();
            
            notificationService.sendNotification(request);
            
        } catch (Exception e) {
            log.error("Failed to process alert notification event", e);
        }
    }

    private SendNotificationRequest buildTransactionNotification(String eventType, UUID userId, Map<String, Object> event) {
        String subject;
        String body;
        NotificationPriority priority = NotificationPriority.NORMAL;
        
        switch (eventType) {
            case "TRANSFER_COMPLETED" -> {
                subject = "Transfer Completed";
                body = String.format("Your transfer of %s %s has been completed successfully.",
                        event.get("currency"), event.get("amount"));
            }
            case "TRANSFER_RECEIVED" -> {
                subject = "Payment Received";
                body = String.format("You have received %s %s from %s.",
                        event.get("currency"), event.get("amount"), event.get("senderName"));
            }
            case "TRANSFER_FAILED" -> {
                subject = "Transfer Failed";
                body = String.format("Your transfer of %s %s has failed. Reason: %s",
                        event.get("currency"), event.get("amount"), event.get("reason"));
                priority = NotificationPriority.HIGH;
            }
            case "LARGE_TRANSACTION" -> {
                subject = "Large Transaction Alert";
                body = String.format("A large transaction of %s %s has been processed on your account.",
                        event.get("currency"), event.get("amount"));
                priority = NotificationPriority.HIGH;
            }
            default -> {
                subject = "Transaction Update";
                body = "There has been an update to your transaction.";
            }
        }
        
        return SendNotificationRequest.builder()
                .userId(userId)
                .channel(NotificationChannel.PUSH)
                .type(NotificationType.TRANSACTION)
                .priority(priority)
                .subject(subject)
                .body(body)
                .templateData(event)
                .build();
    }

    private SendNotificationRequest buildSecurityNotification(String eventType, UUID userId, Map<String, Object> event) {
        String subject;
        String body;
        
        switch (eventType) {
            case "LOGIN_SUCCESS" -> {
                subject = "New Login Detected";
                body = String.format("A new login was detected from %s at %s. If this wasn't you, please secure your account immediately.",
                        event.get("device"), event.get("location"));
            }
            case "LOGIN_FAILED" -> {
                subject = "Failed Login Attempt";
                body = String.format("A failed login attempt was detected on your account from %s.",
                        event.get("location"));
            }
            case "PASSWORD_CHANGED" -> {
                subject = "Password Changed";
                body = "Your account password has been changed. If you didn't make this change, contact support immediately.";
            }
            case "SUSPICIOUS_ACTIVITY" -> {
                subject = "Suspicious Activity Detected";
                body = String.format("Suspicious activity has been detected on your account: %s",
                        event.get("description"));
            }
            case "DEVICE_ADDED" -> {
                subject = "New Device Added";
                body = String.format("A new device '%s' has been added to your account.",
                        event.get("deviceName"));
            }
            default -> {
                subject = "Security Alert";
                body = "There has been a security-related event on your account.";
            }
        }
        
        return SendNotificationRequest.builder()
                .userId(userId)
                .channel(NotificationChannel.EMAIL)
                .type(NotificationType.SECURITY)
                .priority(NotificationPriority.URGENT)
                .subject(subject)
                .body(body)
                .templateData(event)
                .build();
    }

    private SendNotificationRequest buildAccountNotification(String eventType, UUID userId, Map<String, Object> event) {
        String subject;
        String body;
        
        switch (eventType) {
            case "ACCOUNT_CREATED" -> {
                subject = "Welcome to SibehGoodBank!";
                body = String.format("Your %s account has been created successfully. Account number: %s",
                        event.get("accountType"), event.get("accountNumber"));
            }
            case "ACCOUNT_VERIFIED" -> {
                subject = "Account Verified";
                body = "Your account has been verified successfully. You now have full access to all features.";
            }
            case "LOW_BALANCE" -> {
                subject = "Low Balance Alert";
                body = String.format("Your account balance is low: %s %s",
                        event.get("currency"), event.get("balance"));
            }
            case "STATEMENT_READY" -> {
                subject = "Account Statement Ready";
                body = String.format("Your %s account statement is ready for download.",
                        event.get("statementPeriod"));
            }
            default -> {
                subject = "Account Update";
                body = "There has been an update to your account.";
            }
        }
        
        return SendNotificationRequest.builder()
                .userId(userId)
                .channel(NotificationChannel.EMAIL)
                .type(NotificationType.ACCOUNT)
                .priority(NotificationPriority.NORMAL)
                .subject(subject)
                .body(body)
                .templateData(event)
                .build();
    }
}
