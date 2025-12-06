package com.sibehgoodbank.userservice.dto;

import com.sibehgoodbank.common.dto.user.UserResponse;
import lombok.*;

/**
 * Authentication response with tokens and user info
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private int expiresIn; // seconds
    private UserResponse user;
}
