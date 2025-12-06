package com.sibehgoodbank.notification.grpc;

import com.sibehgoodbank.common.grpc.*;
import com.sibehgoodbank.notification.dto.SendNotificationRequest;
import com.sibehgoodbank.notification.entity.Notification;
import com.sibehgoodbank.notification.entity.NotificationPreference;
import com.sibehgoodbank.notification.repository.NotificationPreferenceRepository;
import com.sibehgoodbank.notification.service.NotificationService;
import io.grpc.Status;
import io.grpc.stub.StreamObserver;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.devh.boot.grpc.server.service.GrpcService;

import java.util.*;

/**
 * gRPC service implementation for Notification Service
 * Provides high-performance inter-service communication for notification operations
 */
@GrpcService
@RequiredArgsConstructor
@Slf4j
public class NotificationGrpcService extends NotificationServiceGrpc.NotificationServiceImplBase {

    private final NotificationService notificationService;
    private final NotificationPreferenceRepository preferenceRepository;

    @Override
    public void sendNotification(SendNotificationGrpcRequest request, 
                                StreamObserver<SendNotificationGrpcResponse> responseObserver) {
        log.debug("gRPC sendNotification called for userId: {}", request.getUserId());
        
        try {
            UUID userId = UUID.fromString(request.getUserId());
            
            // Convert gRPC channel to internal channel
            Notification.NotificationChannel channel = convertChannel(request.getChannel());
            
            SendNotificationRequest notificationRequest = SendNotificationRequest.builder()
                .userId(userId)
                .channel(channel)
                .type(Notification.NotificationType.valueOf(request.getType()))
                .title(request.getTitle())
                .message(request.getMessage())
                .priority(request.hasPriority() ? 
                    Notification.NotificationPriority.valueOf(request.getPriority()) : 
                    Notification.NotificationPriority.MEDIUM)
                .metadata(request.getMetadataMap().isEmpty() ? null : new HashMap<>(request.getMetadataMap()))
                .build();
            
            var response = notificationService.sendNotification(notificationRequest);
            
            SendNotificationGrpcResponse grpcResponse = SendNotificationGrpcResponse.newBuilder()
                .setNotificationId(response.getId().toString())
                .setStatus(response.getStatus())
                .setSuccess(!"FAILED".equals(response.getStatus()))
                .setMessage(response.getMessage() != null ? response.getMessage() : "Notification sent successfully")
                .build();
            
            responseObserver.onNext(grpcResponse);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid request parameters", e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid request parameters: " + e.getMessage())
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error sending notification", e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while sending notification: " + e.getMessage())
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void sendBatchNotifications(SendBatchNotificationsRequest request, 
                                       StreamObserver<SendBatchNotificationsResponse> responseObserver) {
        log.debug("gRPC sendBatchNotifications called with {} notifications", request.getNotificationsCount());
        
        try {
            List<SendNotificationRequest> notificationRequests = new ArrayList<>();
            List<String> failedUserIds = new ArrayList<>();
            
            for (NotificationItem item : request.getNotificationsList()) {
                try {
                    UUID userId = UUID.fromString(item.getUserId());
                    Notification.NotificationChannel channel = convertChannel(item.getChannel());
                    
                    SendNotificationRequest notificationRequest = SendNotificationRequest.builder()
                        .userId(userId)
                        .channel(channel)
                        .type(Notification.NotificationType.valueOf(item.getType()))
                        .title(item.getTitle())
                        .message(item.getMessage())
                        .priority(item.hasPriority() ?
                            Notification.NotificationPriority.valueOf(item.getPriority()) :
                            Notification.NotificationPriority.MEDIUM)
                        .build();
                    
                    notificationRequests.add(notificationRequest);
                } catch (Exception e) {
                    log.error("Failed to process notification for user: {}", item.getUserId(), e);
                    failedUserIds.add(item.getUserId());
                }
            }
            
            // Send batch notifications
            notificationService.sendBulkNotifications(notificationRequests);
            
            int successCount = notificationRequests.size();
            int failCount = failedUserIds.size();
            
            SendBatchNotificationsResponse response = SendBatchNotificationsResponse.newBuilder()
                .setTotalRequested(request.getNotificationsCount())
                .setSuccessCount(successCount)
                .setFailureCount(failCount)
                .addAllFailedUserIds(failedUserIds)
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (Exception e) {
            log.error("Error sending batch notifications", e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while sending batch notifications: " + e.getMessage())
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void getUserPreferences(GetUserPreferencesRequest request, 
                                   StreamObserver<UserPreferencesResponse> responseObserver) {
        log.debug("gRPC getUserPreferences called for userId: {}", request.getUserId());
        
        try {
            UUID userId = UUID.fromString(request.getUserId());
            
            NotificationPreference preferences = notificationService.getPreferences(userId);
            
            if (preferences == null) {
                // Create default preferences if none exist
                preferences = notificationService.createDefaultPreferences(userId);
            }
            
            UserPreferencesResponse response = UserPreferencesResponse.newBuilder()
                .setUserId(userId.toString())
                .setEmailEnabled(preferences.isEmailEnabled())
                .setSmsEnabled(preferences.isSmsEnabled())
                .setPushEnabled(preferences.isPushEnabled())
                .setTransactionAlerts(preferences.isTransactionAlertsEnabled())
                .setSecurityAlerts(preferences.isSecurityAlertsEnabled())
                .setMarketingEnabled(preferences.isMarketingEnabled())
                .setQuietHoursEnabled(preferences.isQuietHoursEnabled())
                .setQuietHoursStart(preferences.getQuietHoursStart() != null ? 
                    preferences.getQuietHoursStart().toString() : "")
                .setQuietHoursEnd(preferences.getQuietHoursEnd() != null ? 
                    preferences.getQuietHoursEnd().toString() : "")
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid user ID format: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid user ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error getting user preferences: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while fetching preferences")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void checkNotificationEnabled(CheckNotificationEnabledRequest request, 
                                        StreamObserver<CheckNotificationEnabledResponse> responseObserver) {
        log.debug("gRPC checkNotificationEnabled called for userId: {}, channel: {}", 
                  request.getUserId(), request.getChannel());
        
        try {
            UUID userId = UUID.fromString(request.getUserId());
            String channel = request.getChannel();
            
            NotificationPreference preferences = notificationService.getPreferences(userId);
            
            boolean enabled = false;
            if (preferences != null) {
                switch (channel.toUpperCase()) {
                    case "EMAIL":
                        enabled = preferences.isEmailEnabled();
                        break;
                    case "SMS":
                        enabled = preferences.isSmsEnabled();
                        break;
                    case "PUSH":
                        enabled = preferences.isPushEnabled();
                        break;
                    case "IN_APP":
                        enabled = true; // In-app notifications are always enabled
                        break;
                    default:
                        enabled = false;
                }
            }
            
            CheckNotificationEnabledResponse response = CheckNotificationEnabledResponse.newBuilder()
                .setEnabled(enabled)
                .setChannel(channel)
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid user ID format: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid user ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error checking notification enabled: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while checking notification status")
                    .asRuntimeException()
            );
        }
    }

    /**
     * Convert gRPC channel string to internal NotificationChannel enum
     */
    private Notification.NotificationChannel convertChannel(String channel) {
        return switch (channel.toUpperCase()) {
            case "EMAIL" -> Notification.NotificationChannel.EMAIL;
            case "SMS" -> Notification.NotificationChannel.SMS;
            case "PUSH" -> Notification.NotificationChannel.PUSH;
            case "IN_APP" -> Notification.NotificationChannel.IN_APP;
            default -> throw new IllegalArgumentException("Unknown notification channel: " + channel);
        };
    }
}
