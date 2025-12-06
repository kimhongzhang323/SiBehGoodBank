package com.sibehgoodbank.notification.dto;

import com.sibehgoodbank.notification.entity.Notification.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendNotificationRequest {

    @NotNull(message = "User ID is required")
    private UUID userId;

    private String userEmail;

    private String userPhone;

    private String deviceToken;

    @NotNull(message = "Channel is required")
    private NotificationChannel channel;

    @NotNull(message = "Type is required")
    private NotificationType type;

    @Builder.Default
    private NotificationPriority priority = NotificationPriority.NORMAL;

    @NotBlank(message = "Subject is required")
    private String subject;

    private String body;

    private String htmlBody;

    private String templateId;

    private Map<String, Object> templateData;

    private Map<String, Object> metadata;

    private String referenceId;

    private String referenceType;

    private String scheduledAt; // ISO 8601 format

    @Builder.Default
    private int maxRetries = 3;
}
