package com.sibehgoodbank.notification.provider;

import com.sibehgoodbank.notification.entity.Notification;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailProvider {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.from:noreply@sibehgoodbank.com}")
    private String fromEmail;

    @Value("${spring.mail.from-name:SibehGoodBank}")
    private String fromName;

    @Retryable(
            value = {MessagingException.class},
            maxAttempts = 3,
            backoff = @Backoff(delay = 1000, multiplier = 2)
    )
    public void send(Notification notification) {
        log.info("Sending email to: {} for notification: {}", notification.getUserEmail(), notification.getId());

        if (notification.getUserEmail() == null || notification.getUserEmail().isBlank()) {
            throw new IllegalArgumentException("Email address is required");
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, fromName);
            helper.setTo(notification.getUserEmail());
            helper.setSubject(notification.getSubject());

            String content;
            if (notification.getTemplateId() != null) {
                content = processTemplate(notification);
            } else if (notification.getHtmlBody() != null) {
                content = notification.getHtmlBody();
            } else {
                content = notification.getBody();
            }

            helper.setText(content, notification.getHtmlBody() != null || notification.getTemplateId() != null);

            mailSender.send(message);
            log.info("Email sent successfully: notificationId={}", notification.getId());

        } catch (Exception e) {
            log.error("Failed to send email: notificationId={}, error={}", notification.getId(), e.getMessage());
            throw new RuntimeException("Failed to send email: " + e.getMessage(), e);
        }
    }

    private String processTemplate(Notification notification) {
        Context context = new Context();
        
        // Add default variables
        context.setVariable("subject", notification.getSubject());
        context.setVariable("userName", "Valued Customer");
        context.setVariable("bankName", "SibehGoodBank");
        context.setVariable("supportEmail", "support@sibehgoodbank.com");
        context.setVariable("supportPhone", "+65 6123 4567");
        
        // Parse and add template data if available
        if (notification.getTemplateData() != null) {
            try {
                @SuppressWarnings("unchecked")
                Map<String, Object> data = new com.fasterxml.jackson.databind.ObjectMapper()
                        .readValue(notification.getTemplateData(), HashMap.class);
                data.forEach(context::setVariable);
            } catch (Exception e) {
                log.warn("Failed to parse template data: {}", e.getMessage());
            }
        }

        return templateEngine.process(notification.getTemplateId(), context);
    }

    public void sendOtpEmail(String email, String otp, String purpose) {
        Context context = new Context();
        context.setVariable("otp", otp);
        context.setVariable("purpose", purpose);
        context.setVariable("expiryMinutes", 5);

        String content = templateEngine.process("otp-verification", context);

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromEmail, fromName);
            helper.setTo(email);
            helper.setSubject("Your SibehGoodBank OTP Code");
            helper.setText(content, true);
            mailSender.send(message);
        } catch (Exception e) {
            log.error("Failed to send OTP email: {}", e.getMessage());
            throw new RuntimeException("Failed to send OTP email", e);
        }
    }

    public void sendTransactionAlert(String email, String transactionType, String amount, 
                                     String accountNumber, String description) {
        Context context = new Context();
        context.setVariable("transactionType", transactionType);
        context.setVariable("amount", amount);
        context.setVariable("accountNumber", maskAccountNumber(accountNumber));
        context.setVariable("description", description);
        context.setVariable("timestamp", java.time.LocalDateTime.now().toString());

        String content = templateEngine.process("transaction-alert", context);

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromEmail, fromName);
            helper.setTo(email);
            helper.setSubject("Transaction Alert - " + transactionType);
            helper.setText(content, true);
            mailSender.send(message);
        } catch (Exception e) {
            log.error("Failed to send transaction alert email: {}", e.getMessage());
            throw new RuntimeException("Failed to send transaction alert email", e);
        }
    }

    private String maskAccountNumber(String accountNumber) {
        if (accountNumber == null || accountNumber.length() < 4) {
            return "****";
        }
        return "**** **** " + accountNumber.substring(accountNumber.length() - 4);
    }
}
