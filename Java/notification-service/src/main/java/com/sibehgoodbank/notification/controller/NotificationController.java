package com.sibehgoodbank.notification.controller;

import com.sibehgoodbank.notification.dto.NotificationResponse;
import com.sibehgoodbank.notification.dto.SendNotificationRequest;
import com.sibehgoodbank.notification.dto.UpdatePreferencesRequest;
import com.sibehgoodbank.notification.entity.NotificationPreference;
import com.sibehgoodbank.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Notifications", description = "Notification management endpoints")
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping("/send")
    @Operation(summary = "Send notification", description = "Send a notification to a user")
    public ResponseEntity<NotificationResponse> sendNotification(
            @Valid @RequestBody SendNotificationRequest request) {
        log.info("Sending notification to user: {}", request.getUserId());
        NotificationResponse response = notificationService.sendNotification(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/send-async")
    @Operation(summary = "Send notification asynchronously", description = "Queue notification for async delivery")
    public ResponseEntity<Map<String, String>> sendNotificationAsync(
            @Valid @RequestBody SendNotificationRequest request) {
        log.info("Queueing async notification for user: {}", request.getUserId());
        notificationService.sendNotificationAsync(request);
        return ResponseEntity.accepted()
                .body(Map.of("message", "Notification queued for delivery"));
    }

    @PostMapping("/send-bulk")
    @Operation(summary = "Send bulk notifications", description = "Send notifications to multiple users")
    public ResponseEntity<List<NotificationResponse>> sendBulkNotifications(
            @Valid @RequestBody List<SendNotificationRequest> requests) {
        log.info("Sending bulk notifications, count: {}", requests.size());
        List<NotificationResponse> responses = notificationService.sendBulkNotifications(requests);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user notifications", description = "Get paginated notifications for a user")
    public ResponseEntity<Page<NotificationResponse>> getUserNotifications(
            @PathVariable UUID userId,
            Pageable pageable) {
        log.debug("Getting notifications for user: {}", userId);
        Page<NotificationResponse> notifications = notificationService.getUserNotifications(userId, pageable);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/user/{userId}/unread")
    @Operation(summary = "Get unread notifications", description = "Get all unread notifications for a user")
    public ResponseEntity<List<NotificationResponse>> getUnreadNotifications(
            @PathVariable UUID userId) {
        log.debug("Getting unread notifications for user: {}", userId);
        List<NotificationResponse> notifications = notificationService.getUnreadNotifications(userId);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/user/{userId}/unread-count")
    @Operation(summary = "Get unread count", description = "Get count of unread notifications")
    public ResponseEntity<Map<String, Long>> getUnreadCount(@PathVariable UUID userId) {
        long count = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(Map.of("unreadCount", count));
    }

    @PutMapping("/{notificationId}/read")
    @Operation(summary = "Mark as read", description = "Mark a notification as read")
    public ResponseEntity<Void> markAsRead(@PathVariable UUID notificationId) {
        log.debug("Marking notification as read: {}", notificationId);
        notificationService.markAsRead(notificationId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/user/{userId}/read-all")
    @Operation(summary = "Mark all as read", description = "Mark all notifications as read for a user")
    public ResponseEntity<Map<String, String>> markAllAsRead(@PathVariable UUID userId) {
        log.info("Marking all notifications as read for user: {}", userId);
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(Map.of("message", "All notifications marked as read"));
    }

    @DeleteMapping("/{notificationId}")
    @Operation(summary = "Delete notification", description = "Delete a specific notification")
    public ResponseEntity<Void> deleteNotification(@PathVariable UUID notificationId) {
        log.info("Deleting notification: {}", notificationId);
        notificationService.deleteNotification(notificationId);
        return ResponseEntity.noContent().build();
    }

    // Preference endpoints
    @GetMapping("/preferences/{userId}")
    @Operation(summary = "Get preferences", description = "Get notification preferences for a user")
    public ResponseEntity<NotificationPreference> getPreferences(@PathVariable UUID userId) {
        log.debug("Getting preferences for user: {}", userId);
        NotificationPreference preferences = notificationService.getPreferences(userId);
        return ResponseEntity.ok(preferences);
    }

    @PutMapping("/preferences/{userId}")
    @Operation(summary = "Update preferences", description = "Update notification preferences")
    public ResponseEntity<NotificationPreference> updatePreferences(
            @PathVariable UUID userId,
            @Valid @RequestBody UpdatePreferencesRequest request) {
        log.info("Updating preferences for user: {}", userId);
        NotificationPreference updated = notificationService.updatePreferences(userId, request);
        return ResponseEntity.ok(updated);
    }

    // OTP endpoints
    @PostMapping("/otp/send")
    @Operation(summary = "Send OTP", description = "Send OTP to user via configured channel")
    public ResponseEntity<Map<String, String>> sendOtp(
            @RequestParam UUID userId,
            @RequestParam String channel,
            @RequestParam String purpose) {
        log.info("Sending OTP to user: {} via {}", userId, channel);
        String maskedDestination = notificationService.sendOtp(userId, channel, purpose);
        return ResponseEntity.ok(Map.of(
                "message", "OTP sent successfully",
                "destination", maskedDestination
        ));
    }

    @PostMapping("/otp/verify")
    @Operation(summary = "Verify OTP", description = "Verify OTP code")
    public ResponseEntity<Map<String, Boolean>> verifyOtp(
            @RequestParam UUID userId,
            @RequestParam String otp,
            @RequestParam String purpose) {
        boolean valid = notificationService.verifyOtp(userId, otp, purpose);
        return ResponseEntity.ok(Map.of("valid", valid));
    }

    // Admin endpoints
    @GetMapping("/admin/stats")
    @Operation(summary = "Get notification stats", description = "Get notification delivery statistics")
    public ResponseEntity<Map<String, Object>> getNotificationStats() {
        Map<String, Object> stats = notificationService.getDeliveryStats();
        return ResponseEntity.ok(stats);
    }

    @PostMapping("/admin/retry-failed")
    @Operation(summary = "Retry failed notifications", description = "Retry all failed notifications")
    public ResponseEntity<Map<String, Integer>> retryFailedNotifications() {
        log.info("Retrying failed notifications");
        int retriedCount = notificationService.retryFailedNotifications();
        return ResponseEntity.ok(Map.of("retriedCount", retriedCount));
    }
}
