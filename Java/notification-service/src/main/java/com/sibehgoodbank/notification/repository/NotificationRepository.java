package com.sibehgoodbank.notification.repository;

import com.sibehgoodbank.notification.entity.Notification;
import com.sibehgoodbank.notification.entity.Notification.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    // Find by user
    Page<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    List<Notification> findByUserIdAndStatusOrderByCreatedAtDesc(UUID userId, NotificationStatus status);

    // Find unread notifications
    @Query("SELECT n FROM Notification n WHERE n.userId = :userId AND n.status IN ('SENT', 'DELIVERED') ORDER BY n.createdAt DESC")
    List<Notification> findUnreadByUserId(@Param("userId") UUID userId);

    // Count unread
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.userId = :userId AND n.status IN ('SENT', 'DELIVERED')")
    long countUnreadByUserId(@Param("userId") UUID userId);

    // Find by status for processing
    List<Notification> findByStatusAndScheduledAtBeforeOrderByPriorityDescCreatedAtAsc(
            NotificationStatus status, LocalDateTime scheduledAt);

    List<Notification> findByStatusOrderByPriorityDescCreatedAtAsc(NotificationStatus status, Pageable pageable);

    // Find for retry
    @Query("SELECT n FROM Notification n WHERE n.status = 'FAILED' AND n.retryCount < n.maxRetries AND n.nextRetryAt <= :now ORDER BY n.priority DESC, n.createdAt ASC")
    List<Notification> findForRetry(@Param("now") LocalDateTime now, Pageable pageable);

    // Find by channel and type
    Page<Notification> findByUserIdAndChannelOrderByCreatedAtDesc(
            UUID userId, NotificationChannel channel, Pageable pageable);

    Page<Notification> findByUserIdAndTypeOrderByCreatedAtDesc(
            UUID userId, NotificationType type, Pageable pageable);

    // Find by reference
    List<Notification> findByReferenceIdAndReferenceType(String referenceId, String referenceType);

    Optional<Notification> findByExternalId(String externalId);

    // Mark as read
    @Modifying
    @Query("UPDATE Notification n SET n.status = 'READ', n.readAt = :readAt WHERE n.id = :id AND n.userId = :userId")
    int markAsRead(@Param("id") UUID id, @Param("userId") UUID userId, @Param("readAt") LocalDateTime readAt);

    @Modifying
    @Query("UPDATE Notification n SET n.status = 'READ', n.readAt = :readAt WHERE n.userId = :userId AND n.status IN ('SENT', 'DELIVERED')")
    int markAllAsRead(@Param("userId") UUID userId, @Param("readAt") LocalDateTime readAt);

    // Statistics
    @Query("SELECT n.type, COUNT(n) FROM Notification n WHERE n.userId = :userId AND n.createdAt >= :since GROUP BY n.type")
    List<Object[]> countByTypeForUser(@Param("userId") UUID userId, @Param("since") LocalDateTime since);

    @Query("SELECT n.channel, COUNT(n) FROM Notification n WHERE n.createdAt >= :since GROUP BY n.channel")
    List<Object[]> countByChannelSince(@Param("since") LocalDateTime since);

    @Query("SELECT n.status, COUNT(n) FROM Notification n WHERE n.createdAt >= :since GROUP BY n.status")
    List<Object[]> countByStatusSince(@Param("since") LocalDateTime since);

    // Cleanup old notifications
    @Modifying
    @Query("DELETE FROM Notification n WHERE n.createdAt < :before AND n.status IN ('READ', 'CANCELLED', 'EXPIRED')")
    int deleteOldNotifications(@Param("before") LocalDateTime before);

    // Cancel pending notifications
    @Modifying
    @Query("UPDATE Notification n SET n.status = 'CANCELLED' WHERE n.referenceId = :referenceId AND n.status = 'PENDING'")
    int cancelPendingByReference(@Param("referenceId") String referenceId);
}
