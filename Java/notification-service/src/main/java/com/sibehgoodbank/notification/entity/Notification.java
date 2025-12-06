package com.sibehgoodbank.notification.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "notifications", indexes = {
        @Index(name = "idx_notifications_user_id", columnList = "userId"),
        @Index(name = "idx_notifications_status", columnList = "status"),
        @Index(name = "idx_notifications_channel", columnList = "channel"),
        @Index(name = "idx_notifications_type", columnList = "type"),
        @Index(name = "idx_notifications_scheduled", columnList = "scheduledAt"),
        @Index(name = "idx_notifications_created", columnList = "createdAt")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    @Column(length = 100)
    private String userEmail;

    @Column(length = 20)
    private String userPhone;

    @Column(length = 500)
    private String deviceToken;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private NotificationChannel channel;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private NotificationType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private NotificationStatus status;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private NotificationPriority priority;

    @Column(nullable = false, length = 255)
    private String subject;

    @Column(columnDefinition = "TEXT")
    private String body;

    @Column(columnDefinition = "TEXT")
    private String htmlBody;

    @Column(length = 100)
    private String templateId;

    @Column(columnDefinition = "jsonb")
    private String templateData;

    @Column(columnDefinition = "jsonb")
    private String metadata;

    @Column(length = 100)
    private String referenceId;

    @Column(length = 50)
    private String referenceType;

    private LocalDateTime scheduledAt;

    private LocalDateTime sentAt;

    private LocalDateTime deliveredAt;

    private LocalDateTime readAt;

    @Column(columnDefinition = "TEXT")
    private String errorMessage;

    private int retryCount;

    @Builder.Default
    private int maxRetries = 3;

    private LocalDateTime nextRetryAt;

    @Column(length = 255)
    private String externalId;

    @Column(length = 100)
    private String providerResponse;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public enum NotificationChannel {
        EMAIL,
        SMS,
        PUSH,
        IN_APP,
        WEBHOOK
    }

    public enum NotificationType {
        // Transaction notifications
        TRANSACTION_COMPLETED,
        TRANSACTION_FAILED,
        TRANSACTION_PENDING,
        LOW_BALANCE_ALERT,
        HIGH_VALUE_TRANSACTION,
        
        // Security notifications
        LOGIN_ALERT,
        PASSWORD_CHANGED,
        OTP_VERIFICATION,
        SUSPICIOUS_ACTIVITY,
        DEVICE_ADDED,
        
        // Account notifications
        ACCOUNT_CREATED,
        ACCOUNT_UPDATED,
        BENEFICIARY_ADDED,
        STATEMENT_READY,
        
        // Card notifications
        CARD_TRANSACTION,
        CARD_BLOCKED,
        CARD_ACTIVATED,
        CARD_EXPIRING,
        
        // Marketing
        PROMOTIONAL,
        NEWS_UPDATE,
        
        // System
        SYSTEM_MAINTENANCE,
        SERVICE_UPDATE,
        
        // Support
        SUPPORT_TICKET_CREATED,
        SUPPORT_TICKET_UPDATED,
        SUPPORT_TICKET_RESOLVED
    }

    public enum NotificationStatus {
        PENDING,
        QUEUED,
        PROCESSING,
        SENT,
        DELIVERED,
        READ,
        FAILED,
        CANCELLED,
        EXPIRED
    }

    public enum NotificationPriority {
        LOW,
        NORMAL,
        HIGH,
        URGENT
    }

    public boolean canRetry() {
        return retryCount < maxRetries && status == NotificationStatus.FAILED;
    }
}
