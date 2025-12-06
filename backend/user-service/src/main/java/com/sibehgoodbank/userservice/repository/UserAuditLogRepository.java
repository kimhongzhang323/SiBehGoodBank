package com.sibehgoodbank.userservice.repository;

import com.sibehgoodbank.userservice.entity.UserAuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Repository for audit logs
 */
@Repository
public interface UserAuditLogRepository extends JpaRepository<UserAuditLog, UUID> {

    Page<UserAuditLog> findByUserId(UUID userId, Pageable pageable);

    Page<UserAuditLog> findByAction(UserAuditLog.AuditAction action, Pageable pageable);

    @Query("SELECT l FROM UserAuditLog l WHERE l.userId = :userId AND l.createdAt BETWEEN :startDate AND :endDate")
    List<UserAuditLog> findByUserIdAndDateRange(
            @Param("userId") UUID userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    @Query("SELECT l FROM UserAuditLog l WHERE l.action = :action AND l.status = 'FAILURE' ORDER BY l.createdAt DESC")
    List<UserAuditLog> findFailedAttempts(@Param("action") UserAuditLog.AuditAction action, Pageable pageable);

    @Query("SELECT l FROM UserAuditLog l WHERE l.ipAddress = :ipAddress AND l.action = 'LOGIN_FAILED' AND l.createdAt > :since")
    List<UserAuditLog> findRecentFailedLoginsByIp(
            @Param("ipAddress") String ipAddress,
            @Param("since") LocalDateTime since);

    @Query("SELECT COUNT(l) FROM UserAuditLog l WHERE l.action = :action AND l.createdAt > :since")
    long countActionsSince(
            @Param("action") UserAuditLog.AuditAction action,
            @Param("since") LocalDateTime since);

    @Query("SELECT l FROM UserAuditLog l WHERE l.sessionId = :sessionId ORDER BY l.createdAt")
    List<UserAuditLog> findBySessionId(@Param("sessionId") String sessionId);
}
