package com.sibehgoodbank.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePreferencesRequest {

    private UUID userId;

    // Email preferences
    private Boolean emailEnabled;
    private Boolean emailTransactions;
    private Boolean emailSecurity;
    private Boolean emailMarketing;
    private Boolean emailStatements;

    // SMS preferences
    private Boolean smsEnabled;
    private Boolean smsTransactions;
    private Boolean smsSecurity;
    private Boolean smsMarketing;
    private Boolean smsOtp;

    // Push notification preferences
    private Boolean pushEnabled;
    private Boolean pushTransactions;
    private Boolean pushSecurity;
    private Boolean pushMarketing;
    private Boolean pushNews;

    // In-app notification preferences
    private Boolean inAppEnabled;

    // Quiet hours
    private Boolean quietHoursEnabled;
    private Integer quietHoursStart;
    private Integer quietHoursEnd;

    // Settings
    private String timezone;
    private String language;
}
