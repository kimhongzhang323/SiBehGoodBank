package com.sibehgoodbank.notification.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sibehgoodbank.notification.dto.NotificationResponse;
import com.sibehgoodbank.notification.dto.SendNotificationRequest;
import com.sibehgoodbank.notification.dto.UpdatePreferencesRequest;
import com.sibehgoodbank.notification.entity.Notification;
import com.sibehgoodbank.notification.entity.Notification.*;
import com.sibehgoodbank.notification.entity.NotificationPreference;
import com.sibehgoodbank.notification.provider.EmailProvider;
import com.sibehgoodbank.notification.provider.PushNotificationProvider;
import com.sibehgoodbank.notification.provider.SmsProvider;
import com.sibehgoodbank.notification.repository.NotificationPreferenceRepository;
import com.sibehgoodbank.notification.repository.NotificationRepository;
import com.sibehgoodbank.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationPreferenceRepository preferenceRepository;
    private final EmailProvider emailProvider;
    private final SmsProvider smsProvider;
    private final PushNotificationProvider pushProvider;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public NotificationResponse sendNotification(SendNotificationRequest request) {
        log.info("Sending {} notification to user: {}", request.getChannel(), request.getUserId());

        // Check user preferences
        NotificationPreference preferences = getOrCreatePreferences(request.getUserId());
        if (!isNotificationAllowed(preferences, request.getChannel(), request.getType())) {
            log.info("Notification blocked by user preferences: channel={}, type={}", 
                    request.getChannel(), request.getType());
            return null;
        }

        // Create notification entity
        Notification notification = createNotificationEntity(request);
        
        // Check if scheduled
        if (request.getScheduledAt() != null) {
            notification.setScheduledAt(LocalDateTime.parse(request.getScheduledAt(), DateTimeFormatter.ISO_DATE_TIME));
            notification.setStatus(NotificationStatus.PENDING);
            notification = notificationRepository.save(notification);
            return mapToResponse(notification);
        }

        // Send immediately
        notification.setStatus(NotificationStatus.PROCESSING);
        notification = notificationRepository.save(notification);

        try {
            sendToProvider(notification);
            notification.setStatus(NotificationStatus.SENT);
            notification.setSentAt(LocalDateTime.now());
            log.info("Notification sent successfully: id={}", notification.getId());
        } catch (Exception e) {
            log.error("Failed to send notification: id={}, error={}", notification.getId(), e.getMessage());
            notification.setStatus(NotificationStatus.FAILED);
            notification.setErrorMessage(e.getMessage());
            notification.setRetryCount(notification.getRetryCount() + 1);
            notification.setNextRetryAt(calculateNextRetryTime(notification.getRetryCount()));
        }

        notification = notificationRepository.save(notification);
        
        // Publish event
        publishNotificationEvent(notification);

        return mapToResponse(notification);
    }

    @Override
    @Async
    public void sendNotificationAsync(SendNotificationRequest request) {
        sendNotification(request);
    }

    @Override
    @Transactional
    public void sendBulkNotifications(List<SendNotificationRequest> requests) {
        log.info("Sending {} bulk notifications", requests.size());
        
        for (SendNotificationRequest request : requests) {
            try {
                sendNotificationAsync(request);
            } catch (Exception e) {
                log.error("Failed to send bulk notification: userId={}, error={}", 
                        request.getUserId(), e.getMessage());
            }
        }
    }

    @Override
    public NotificationResponse getNotification(UUID id, UUID userId) {
        return notificationRepository.findById(id)
                .filter(n -> n.getUserId().equals(userId))
                .map(this::mapToResponse)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
    }

    @Override
    public Page<NotificationResponse> getUserNotifications(UUID userId, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::mapToResponse);
    }

    @Override
    public Page<NotificationResponse> getUserNotificationsByChannel(UUID userId, 
            NotificationChannel channel, Pageable pageable) {
        return notificationRepository.findByUserIdAndChannelOrderByCreatedAtDesc(userId, channel, pageable)
                .map(this::mapToResponse);
    }

    @Override
    public List<NotificationResponse> getUnreadNotifications(UUID userId) {
        return notificationRepository.findUnreadByUserId(userId).stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public long countUnreadNotifications(UUID userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    @Override
    @Transactional
    public void markAsRead(UUID id, UUID userId) {
        notificationRepository.markAsRead(id, userId, LocalDateTime.now());
    }

    @Override
    @Transactional
    public void markAllAsRead(UUID userId) {
        notificationRepository.markAllAsRead(userId, LocalDateTime.now());
    }

    @Override
    @Transactional
    public void deleteNotification(UUID id, UUID userId) {
        Notification notification = notificationRepository.findById(id)
                .filter(n -> n.getUserId().equals(userId))
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        
        notificationRepository.delete(notification);
    }

    @Override
    public NotificationPreference getPreferences(UUID userId) {
        return getOrCreatePreferences(userId);
    }

    @Override
    @Transactional
    public NotificationPreference updatePreferences(UUID userId, UpdatePreferencesRequest request) {
        NotificationPreference preferences = getOrCreatePreferences(userId);

        // Update email preferences
        if (request.getEmailEnabled() != null) preferences.setEmailEnabled(request.getEmailEnabled());
        if (request.getEmailTransactions() != null) preferences.setEmailTransactions(request.getEmailTransactions());
        if (request.getEmailSecurity() != null) preferences.setEmailSecurity(request.getEmailSecurity());
        if (request.getEmailMarketing() != null) preferences.setEmailMarketing(request.getEmailMarketing());
        if (request.getEmailStatements() != null) preferences.setEmailStatements(request.getEmailStatements());

        // Update SMS preferences
        if (request.getSmsEnabled() != null) preferences.setSmsEnabled(request.getSmsEnabled());
        if (request.getSmsTransactions() != null) preferences.setSmsTransactions(request.getSmsTransactions());
        if (request.getSmsSecurity() != null) preferences.setSmsSecurity(request.getSmsSecurity());
        if (request.getSmsMarketing() != null) preferences.setSmsMarketing(request.getSmsMarketing());
        if (request.getSmsOtp() != null) preferences.setSmsOtp(request.getSmsOtp());

        // Update push preferences
        if (request.getPushEnabled() != null) preferences.setPushEnabled(request.getPushEnabled());
        if (request.getPushTransactions() != null) preferences.setPushTransactions(request.getPushTransactions());
        if (request.getPushSecurity() != null) preferences.setPushSecurity(request.getPushSecurity());
        if (request.getPushMarketing() != null) preferences.setPushMarketing(request.getPushMarketing());
        if (request.getPushNews() != null) preferences.setPushNews(request.getPushNews());

        // Update in-app preferences
        if (request.getInAppEnabled() != null) preferences.setInAppEnabled(request.getInAppEnabled());

        // Update quiet hours
        if (request.getQuietHoursEnabled() != null) preferences.setQuietHoursEnabled(request.getQuietHoursEnabled());
        if (request.getQuietHoursStart() != null) preferences.setQuietHoursStart(request.getQuietHoursStart());
        if (request.getQuietHoursEnd() != null) preferences.setQuietHoursEnd(request.getQuietHoursEnd());

        // Update settings
        if (request.getTimezone() != null) preferences.setTimezone(request.getTimezone());
        if (request.getLanguage() != null) preferences.setLanguage(request.getLanguage());

        return preferenceRepository.save(preferences);
    }

    @Override
    @Transactional
    public NotificationPreference createDefaultPreferences(UUID userId) {
        NotificationPreference preferences = NotificationPreference.builder()
                .userId(userId)
                .build();
        return preferenceRepository.save(preferences);
    }

    @Override
    public Object getNotificationStats(UUID userId) {
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("userId", userId);
        stats.put("unreadCount", countUnreadNotifications(userId));
        stats.put("byType", notificationRepository.countByTypeForUser(userId, thirtyDaysAgo));
        stats.put("period", "30_days");
        
        return stats;
    }

    @Override
    @Scheduled(fixedRate = 60000) // Every minute
    @Transactional
    public void processScheduledNotifications() {
        LocalDateTime now = LocalDateTime.now();
        List<Notification> scheduledNotifications = notificationRepository
                .findByStatusAndScheduledAtBeforeOrderByPriorityDescCreatedAtAsc(NotificationStatus.PENDING, now);

        log.info("Processing {} scheduled notifications", scheduledNotifications.size());

        for (Notification notification : scheduledNotifications) {
            try {
                notification.setStatus(NotificationStatus.PROCESSING);
                sendToProvider(notification);
                notification.setStatus(NotificationStatus.SENT);
                notification.setSentAt(LocalDateTime.now());
            } catch (Exception e) {
                log.error("Failed to send scheduled notification: id={}", notification.getId(), e);
                notification.setStatus(NotificationStatus.FAILED);
                notification.setErrorMessage(e.getMessage());
            }
            notificationRepository.save(notification);
        }
    }

    @Override
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    @Transactional
    public void retryFailedNotifications() {
        LocalDateTime now = LocalDateTime.now();
        List<Notification> failedNotifications = notificationRepository
                .findForRetry(now, PageRequest.of(0, 50));

        log.info("Retrying {} failed notifications", failedNotifications.size());

        for (Notification notification : failedNotifications) {
            try {
                sendToProvider(notification);
                notification.setStatus(NotificationStatus.SENT);
                notification.setSentAt(LocalDateTime.now());
                notification.setErrorMessage(null);
            } catch (Exception e) {
                notification.setRetryCount(notification.getRetryCount() + 1);
                notification.setErrorMessage(e.getMessage());
                
                if (notification.canRetry()) {
                    notification.setNextRetryAt(calculateNextRetryTime(notification.getRetryCount()));
                } else {
                    notification.setStatus(NotificationStatus.FAILED);
                    log.error("Notification failed after max retries: id={}", notification.getId());
                }
            }
            notificationRepository.save(notification);
        }
    }

    @Override
    @Scheduled(cron = "0 0 2 * * *") // Daily at 2 AM
    @Transactional
    public void cleanupOldNotifications(int daysToKeep) {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(daysToKeep > 0 ? daysToKeep : 90);
        int deleted = notificationRepository.deleteOldNotifications(cutoff);
        log.info("Cleaned up {} old notifications", deleted);
    }

    // Helper methods
    private NotificationPreference getOrCreatePreferences(UUID userId) {
        return preferenceRepository.findByUserId(userId)
                .orElseGet(() -> createDefaultPreferences(userId));
    }

    private boolean isNotificationAllowed(NotificationPreference prefs, NotificationChannel channel, NotificationType type) {
        return prefs.isChannelEnabled(channel) && prefs.isTypeAllowedForChannel(type, channel);
    }

    private Notification createNotificationEntity(SendNotificationRequest request) {
        String templateData = null;
        String metadata = null;
        
        try {
            if (request.getTemplateData() != null) {
                templateData = objectMapper.writeValueAsString(request.getTemplateData());
            }
            if (request.getMetadata() != null) {
                metadata = objectMapper.writeValueAsString(request.getMetadata());
            }
        } catch (Exception e) {
            log.warn("Failed to serialize notification data", e);
        }

        return Notification.builder()
                .userId(request.getUserId())
                .userEmail(request.getUserEmail())
                .userPhone(request.getUserPhone())
                .deviceToken(request.getDeviceToken())
                .channel(request.getChannel())
                .type(request.getType())
                .priority(request.getPriority())
                .status(NotificationStatus.PENDING)
                .subject(request.getSubject())
                .body(request.getBody())
                .htmlBody(request.getHtmlBody())
                .templateId(request.getTemplateId())
                .templateData(templateData)
                .metadata(metadata)
                .referenceId(request.getReferenceId())
                .referenceType(request.getReferenceType())
                .maxRetries(request.getMaxRetries())
                .build();
    }

    private void sendToProvider(Notification notification) {
        switch (notification.getChannel()) {
            case EMAIL -> emailProvider.send(notification);
            case SMS -> smsProvider.send(notification);
            case PUSH -> pushProvider.send(notification);
            case IN_APP -> log.info("In-app notification stored: id={}", notification.getId());
            case WEBHOOK -> sendWebhook(notification);
        }
    }

    private void sendWebhook(Notification notification) {
        // Implement webhook delivery
        log.info("Webhook notification: id={}", notification.getId());
    }

    private LocalDateTime calculateNextRetryTime(int retryCount) {
        // Exponential backoff: 1min, 5min, 15min, 30min, 1hr
        int[] delays = {1, 5, 15, 30, 60};
        int delayMinutes = retryCount < delays.length ? delays[retryCount] : 60;
        return LocalDateTime.now().plusMinutes(delayMinutes);
    }

    private void publishNotificationEvent(Notification notification) {
        Map<String, Object> event = new HashMap<>();
        event.put("eventType", "NOTIFICATION_" + notification.getStatus());
        event.put("notificationId", notification.getId());
        event.put("userId", notification.getUserId());
        event.put("channel", notification.getChannel());
        event.put("type", notification.getType());
        event.put("timestamp", LocalDateTime.now().toString());

        kafkaTemplate.send("notification-events", notification.getId().toString(), event);
    }

    private NotificationResponse mapToResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .userId(notification.getUserId())
                .channel(notification.getChannel())
                .type(notification.getType())
                .status(notification.getStatus())
                .priority(notification.getPriority())
                .subject(notification.getSubject())
                .body(notification.getBody())
                .referenceId(notification.getReferenceId())
                .referenceType(notification.getReferenceType())
                .sentAt(notification.getSentAt())
                .deliveredAt(notification.getDeliveredAt())
                .readAt(notification.getReadAt())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
