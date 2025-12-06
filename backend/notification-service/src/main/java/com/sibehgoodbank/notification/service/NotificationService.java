package com.sibehgoodbank.notification.service;

import com.sibehgoodbank.notification.dto.NotificationResponse;
import com.sibehgoodbank.notification.dto.SendNotificationRequest;
import com.sibehgoodbank.notification.dto.UpdatePreferencesRequest;
import com.sibehgoodbank.notification.entity.Notification;
import com.sibehgoodbank.notification.entity.NotificationPreference;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface NotificationService {

    // Send notifications
    NotificationResponse sendNotification(SendNotificationRequest request);

    void sendNotificationAsync(SendNotificationRequest request);

    void sendBulkNotifications(List<SendNotificationRequest> requests);

    // Notification management
    NotificationResponse getNotification(UUID id, UUID userId);

    Page<NotificationResponse> getUserNotifications(UUID userId, Pageable pageable);

    Page<NotificationResponse> getUserNotificationsByChannel(UUID userId, Notification.NotificationChannel channel, Pageable pageable);

    List<NotificationResponse> getUnreadNotifications(UUID userId);

    long countUnreadNotifications(UUID userId);

    void markAsRead(UUID id, UUID userId);

    void markAllAsRead(UUID userId);

    void deleteNotification(UUID id, UUID userId);

    // Preferences
    NotificationPreference getPreferences(UUID userId);

    NotificationPreference updatePreferences(UUID userId, UpdatePreferencesRequest request);

    NotificationPreference createDefaultPreferences(UUID userId);

    // Statistics
    Object getNotificationStats(UUID userId);

    // Admin operations
    void processScheduledNotifications();

    void retryFailedNotifications();

    void cleanupOldNotifications(int daysToKeep);
}
