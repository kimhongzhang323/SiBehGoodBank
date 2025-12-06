package com.sibehgoodbank.userservice.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Audit log for tracking user actions
 */
@Entity
@Table(name = "user_audit_logs", indexes = {
        @Index(name = "idx_audit_user", columnList = "user_id"),
        @Index(name = "idx_audit_action", columnList = "action"),
        @Index(name = "idx_audit_timestamp", columnList = "created_at")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "user_id")
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "action", nullable = false)
    private AuditAction action;

    @Column(name = "resource_type")
    private String resourceType;

    @Column(name = "resource_id")
    private String resourceId;

    @Column(name = "details", columnDefinition = "TEXT")
    private String details;

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "user_agent")
    private String userAgent;

    @Column(name = "device_id")
    private String deviceId;

    @Column(name = "session_id")
    private String sessionId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    @Builder.Default
    private AuditStatus status = AuditStatus.SUCCESS;

    @Column(name = "error_message")
    private String errorMessage;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public enum AuditAction {
        // Authentication
        LOGIN,
        LOGOUT,
        LOGIN_FAILED,
        PASSWORD_CHANGE,
        PASSWORD_RESET,
        TWO_FACTOR_ENABLED,
        TWO_FACTOR_DISABLED,
        TWO_FACTOR_VERIFIED,
        
        // Registration
        REGISTRATION,
        EMAIL_VERIFIED,
        PHONE_VERIFIED,
        
        // Profile
        PROFILE_UPDATED,
        PROFILE_IMAGE_UPDATED,
        
        // Security
        TOKEN_REFRESH,
        TOKEN_REVOKED,
        ACCOUNT_LOCKED,
        ACCOUNT_UNLOCKED,
        ACCOUNT_SUSPENDED,
        ACCOUNT_ACTIVATED,
        
        // Biometric
        BIOMETRIC_ENABLED,
        BIOMETRIC_DISABLED,
        BIOMETRIC_VERIFIED,
        
        // Admin
        ROLE_ASSIGNED,
        ROLE_REMOVED,
        USER_CREATED_BY_ADMIN,
        USER_UPDATED_BY_ADMIN
    }

    public enum AuditStatus {
        SUCCESS,
        FAILURE,
        PENDING
    }
}
