package com.sibehgoodbank.userservice.dto;

import lombok.*;

/**
 * Token response for refresh operations
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TokenResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private int expiresIn;
}
