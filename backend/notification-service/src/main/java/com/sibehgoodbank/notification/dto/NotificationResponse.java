package com.sibehgoodbank.notification.dto;

import com.sibehgoodbank.notification.entity.Notification.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {

    private UUID id;
    private UUID userId;
    private NotificationChannel channel;
    private NotificationType type;
    private NotificationStatus status;
    private NotificationPriority priority;
    private String subject;
    private String body;
    private String referenceId;
    private String referenceType;
    private LocalDateTime sentAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime readAt;
    private LocalDateTime createdAt;
}
