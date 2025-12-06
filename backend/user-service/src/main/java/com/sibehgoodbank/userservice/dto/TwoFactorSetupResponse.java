package com.sibehgoodbank.userservice.dto;

import lombok.*;

/**
 * Two-factor authentication setup response
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TwoFactorSetupResponse {
    private String secret;
    private String qrCodeUrl;
    private String[] backupCodes;
}
