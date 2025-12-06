package com.sibehgoodbank.notification.provider;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.*;
import com.sibehgoodbank.notification.entity.Notification;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class PushNotificationProvider {

    @Value("${firebase.credentials-file:}")
    private Resource credentialsFile;

    @Value("${firebase.enabled:false}")
    private boolean enabled;

    private FirebaseMessaging firebaseMessaging;

    @PostConstruct
    public void init() {
        if (!enabled) {
            log.info("Firebase push notification provider is disabled");
            return;
        }

        try {
            if (credentialsFile != null && credentialsFile.exists()) {
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(credentialsFile.getInputStream()))
                        .build();

                if (FirebaseApp.getApps().isEmpty()) {
                    FirebaseApp.initializeApp(options);
                }
                
                firebaseMessaging = FirebaseMessaging.getInstance();
                log.info("Firebase push notification provider initialized");
            } else {
                log.warn("Firebase credentials file not found, push notifications disabled");
                enabled = false;
            }
        } catch (IOException e) {
            log.error("Failed to initialize Firebase: {}", e.getMessage());
            enabled = false;
        }
    }

    @Retryable(
            value = {FirebaseMessagingException.class},
            maxAttempts = 3,
            backoff = @Backoff(delay = 1000, multiplier = 2)
    )
    public void send(Notification notification) {
        log.info("Sending push notification for: {}", notification.getId());

        if (!enabled || firebaseMessaging == null) {
            log.info("Push provider disabled, simulating send for notification: {}", notification.getId());
            return;
        }

        if (notification.getDeviceToken() == null || notification.getDeviceToken().isBlank()) {
            throw new IllegalArgumentException("Device token is required for push notifications");
        }

        try {
            Message message = buildMessage(notification);
            String response = firebaseMessaging.send(message);
            log.info("Push notification sent successfully: notificationId={}, response={}", 
                    notification.getId(), response);

        } catch (FirebaseMessagingException e) {
            log.error("Failed to send push notification: notificationId={}, error={}", 
                    notification.getId(), e.getMessage());
            throw new RuntimeException("Failed to send push notification: " + e.getMessage(), e);
        }
    }

    private Message buildMessage(Notification notification) {
        Map<String, String> data = new HashMap<>();
        data.put("notificationId", notification.getId().toString());
        data.put("type", notification.getType().name());
        data.put("channel", notification.getChannel().name());
        
        if (notification.getReferenceId() != null) {
            data.put("referenceId", notification.getReferenceId());
        }
        if (notification.getReferenceType() != null) {
            data.put("referenceType", notification.getReferenceType());
        }

        return Message.builder()
                .setToken(notification.getDeviceToken())
                .setNotification(com.google.firebase.messaging.Notification.builder()
                        .setTitle(notification.getSubject())
                        .setBody(notification.getBody())
                        .build())
                .putAllData(data)
                .setAndroidConfig(AndroidConfig.builder()
                        .setPriority(mapPriority(notification.getPriority()))
                        .setNotification(AndroidNotification.builder()
                                .setIcon("ic_notification")
                                .setColor("#1E88E5")
                                .setSound("default")
                                .build())
                        .build())
                .setApnsConfig(ApnsConfig.builder()
                        .setAps(Aps.builder()
                                .setAlert(ApsAlert.builder()
                                        .setTitle(notification.getSubject())
                                        .setBody(notification.getBody())
                                        .build())
                                .setSound("default")
                                .setBadge(1)
                                .build())
                        .build())
                .build();
    }

    private AndroidConfig.Priority mapPriority(Notification.NotificationPriority priority) {
        if (priority == null) {
            return AndroidConfig.Priority.NORMAL;
        }
        return switch (priority) {
            case URGENT, HIGH -> AndroidConfig.Priority.HIGH;
            default -> AndroidConfig.Priority.NORMAL;
        };
    }

    public void sendToMultipleDevices(List<String> deviceTokens, String title, String body, 
                                       Map<String, String> data) {
        if (!enabled || firebaseMessaging == null) {
            log.info("Push provider disabled, simulating multicast send");
            return;
        }

        try {
            MulticastMessage message = MulticastMessage.builder()
                    .addAllTokens(deviceTokens)
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putAllData(data != null ? data : new HashMap<>())
                    .build();

            BatchResponse response = firebaseMessaging.sendEachForMulticast(message);
            log.info("Multicast push sent: success={}, failure={}", 
                    response.getSuccessCount(), response.getFailureCount());

        } catch (FirebaseMessagingException e) {
            log.error("Failed to send multicast push: {}", e.getMessage());
            throw new RuntimeException("Failed to send multicast push", e);
        }
    }

    public void subscribeToTopic(String token, String topic) {
        if (!enabled || firebaseMessaging == null) {
            return;
        }

        try {
            firebaseMessaging.subscribeToTopic(List.of(token), topic);
            log.info("Subscribed to topic: {}", topic);
        } catch (FirebaseMessagingException e) {
            log.error("Failed to subscribe to topic: {}", e.getMessage());
        }
    }

    public void sendToTopic(String topic, String title, String body, Map<String, String> data) {
        if (!enabled || firebaseMessaging == null) {
            log.info("Push provider disabled, simulating topic send");
            return;
        }

        try {
            Message message = Message.builder()
                    .setTopic(topic)
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putAllData(data != null ? data : new HashMap<>())
                    .build();

            String response = firebaseMessaging.send(message);
            log.info("Topic push sent: topic={}, response={}", topic, response);

        } catch (FirebaseMessagingException e) {
            log.error("Failed to send topic push: {}", e.getMessage());
            throw new RuntimeException("Failed to send topic push", e);
        }
    }
}
