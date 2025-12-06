package com.sibehgoodbank.notification.provider;

import com.sibehgoodbank.notification.entity.Notification;
import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class SmsProvider {

    @Value("${twilio.account-sid:}")
    private String accountSid;

    @Value("${twilio.auth-token:}")
    private String authToken;

    @Value("${twilio.phone-number:}")
    private String twilioPhoneNumber;

    @Value("${twilio.enabled:false}")
    private boolean enabled;

    @PostConstruct
    public void init() {
        if (enabled && accountSid != null && !accountSid.isBlank()) {
            Twilio.init(accountSid, authToken);
            log.info("Twilio SMS provider initialized");
        } else {
            log.info("Twilio SMS provider is disabled or not configured");
        }
    }

    @Retryable(
            value = {Exception.class},
            maxAttempts = 3,
            backoff = @Backoff(delay = 1000, multiplier = 2)
    )
    public void send(Notification notification) {
        log.info("Sending SMS to: {} for notification: {}", 
                maskPhoneNumber(notification.getUserPhone()), notification.getId());

        if (!enabled) {
            log.info("SMS provider disabled, simulating send for notification: {}", notification.getId());
            return;
        }

        if (notification.getUserPhone() == null || notification.getUserPhone().isBlank()) {
            throw new IllegalArgumentException("Phone number is required");
        }

        try {
            String messageBody = buildSmsContent(notification);
            
            Message message = Message.creator(
                    new PhoneNumber(notification.getUserPhone()),
                    new PhoneNumber(twilioPhoneNumber),
                    messageBody
            ).create();

            log.info("SMS sent successfully: notificationId={}, messageSid={}", 
                    notification.getId(), message.getSid());

        } catch (Exception e) {
            log.error("Failed to send SMS: notificationId={}, error={}", notification.getId(), e.getMessage());
            throw new RuntimeException("Failed to send SMS: " + e.getMessage(), e);
        }
    }

    private String buildSmsContent(Notification notification) {
        StringBuilder content = new StringBuilder();
        content.append("[SibehGoodBank] ");
        
        // Add body content, truncated if necessary
        String body = notification.getBody() != null ? notification.getBody() : notification.getSubject();
        if (body.length() > 140) {
            content.append(body.substring(0, 137)).append("...");
        } else {
            content.append(body);
        }

        return content.toString();
    }

    public void sendOtp(String phoneNumber, String otp) {
        if (!enabled) {
            log.info("SMS provider disabled, OTP for {} is: {}", maskPhoneNumber(phoneNumber), otp);
            return;
        }

        try {
            String messageBody = String.format(
                    "[SibehGoodBank] Your OTP code is %s. Valid for 5 minutes. Do not share this code with anyone.",
                    otp
            );

            Message message = Message.creator(
                    new PhoneNumber(phoneNumber),
                    new PhoneNumber(twilioPhoneNumber),
                    messageBody
            ).create();

            log.info("OTP SMS sent: phone={}, messageSid={}", maskPhoneNumber(phoneNumber), message.getSid());

        } catch (Exception e) {
            log.error("Failed to send OTP SMS: phone={}, error={}", maskPhoneNumber(phoneNumber), e.getMessage());
            throw new RuntimeException("Failed to send OTP SMS", e);
        }
    }

    public void sendTransactionAlert(String phoneNumber, String amount, String type) {
        if (!enabled) {
            log.info("SMS provider disabled, simulating transaction alert");
            return;
        }

        try {
            String messageBody = String.format(
                    "[SibehGoodBank] %s of %s processed. If this wasn't you, call +65 6123 4567 immediately.",
                    type, amount
            );

            Message.creator(
                    new PhoneNumber(phoneNumber),
                    new PhoneNumber(twilioPhoneNumber),
                    messageBody
            ).create();

        } catch (Exception e) {
            log.error("Failed to send transaction alert SMS: {}", e.getMessage());
            throw new RuntimeException("Failed to send transaction alert SMS", e);
        }
    }

    private String maskPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.length() < 4) {
            return "****";
        }
        return "***" + phoneNumber.substring(phoneNumber.length() - 4);
    }
}
