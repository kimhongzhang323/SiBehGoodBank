package com.sibehgoodbank.notification.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "notification_preferences", indexes = {
        @Index(name = "idx_prefs_user_id", columnList = "userId")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationPreference {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private UUID userId;

    // Email preferences
    @Builder.Default
    private boolean emailEnabled = true;
    
    @Builder.Default
    private boolean emailTransactions = true;
    
    @Builder.Default
    private boolean emailSecurity = true;
    
    @Builder.Default
    private boolean emailMarketing = false;
    
    @Builder.Default
    private boolean emailStatements = true;

    // SMS preferences
    @Builder.Default
    private boolean smsEnabled = true;
    
    @Builder.Default
    private boolean smsTransactions = true;
    
    @Builder.Default
    private boolean smsSecurity = true;
    
    @Builder.Default
    private boolean smsMarketing = false;
    
    @Builder.Default
    private boolean smsOtp = true;

    // Push notification preferences
    @Builder.Default
    private boolean pushEnabled = true;
    
    @Builder.Default
    private boolean pushTransactions = true;
    
    @Builder.Default
    private boolean pushSecurity = true;
    
    @Builder.Default
    private boolean pushMarketing = false;
    
    @Builder.Default
    private boolean pushNews = true;

    // In-app notification preferences
    @Builder.Default
    private boolean inAppEnabled = true;

    // Quiet hours
    @Builder.Default
    private boolean quietHoursEnabled = false;
    
    private Integer quietHoursStart; // Hour of day (0-23)
    
    private Integer quietHoursEnd;

    // Timezone
    @Column(length = 50)
    @Builder.Default
    private String timezone = "Asia/Singapore";

    // Language preference
    @Column(length = 10)
    @Builder.Default
    private String language = "en";

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public boolean isChannelEnabled(Notification.NotificationChannel channel) {
        return switch (channel) {
            case EMAIL -> emailEnabled;
            case SMS -> smsEnabled;
            case PUSH -> pushEnabled;
            case IN_APP -> inAppEnabled;
            case WEBHOOK -> true;
        };
    }

    public boolean isTypeAllowedForChannel(Notification.NotificationType type, Notification.NotificationChannel channel) {
        return switch (channel) {
            case EMAIL -> isTypeAllowedForEmail(type);
            case SMS -> isTypeAllowedForSms(type);
            case PUSH -> isTypeAllowedForPush(type);
            case IN_APP -> inAppEnabled;
            case WEBHOOK -> true;
        };
    }

    private boolean isTypeAllowedForEmail(Notification.NotificationType type) {
        if (!emailEnabled) return false;
        
        return switch (type) {
            case TRANSACTION_COMPLETED, TRANSACTION_FAILED, TRANSACTION_PENDING, 
                 LOW_BALANCE_ALERT, HIGH_VALUE_TRANSACTION, CARD_TRANSACTION -> emailTransactions;
            case LOGIN_ALERT, PASSWORD_CHANGED, SUSPICIOUS_ACTIVITY, DEVICE_ADDED -> emailSecurity;
            case PROMOTIONAL, NEWS_UPDATE -> emailMarketing;
            case STATEMENT_READY -> emailStatements;
            default -> true;
        };
    }

    private boolean isTypeAllowedForSms(Notification.NotificationType type) {
        if (!smsEnabled) return false;
        
        return switch (type) {
            case TRANSACTION_COMPLETED, TRANSACTION_FAILED, HIGH_VALUE_TRANSACTION -> smsTransactions;
            case LOGIN_ALERT, PASSWORD_CHANGED, SUSPICIOUS_ACTIVITY, OTP_VERIFICATION -> smsSecurity;
            case PROMOTIONAL -> smsMarketing;
            default -> true;
        };
    }

    private boolean isTypeAllowedForPush(Notification.NotificationType type) {
        if (!pushEnabled) return false;
        
        return switch (type) {
            case TRANSACTION_COMPLETED, TRANSACTION_FAILED, LOW_BALANCE_ALERT, 
                 HIGH_VALUE_TRANSACTION, CARD_TRANSACTION -> pushTransactions;
            case LOGIN_ALERT, PASSWORD_CHANGED, SUSPICIOUS_ACTIVITY -> pushSecurity;
            case PROMOTIONAL -> pushMarketing;
            case NEWS_UPDATE -> pushNews;
            default -> true;
        };
    }
}
