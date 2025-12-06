package com.sibehgoodbank.common.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Set;

/**
 * User response DTO (excluding sensitive data)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private String userId;
    private String email;
    private String fullName;
    private String nickname;
    private String phoneNumber;
    private LocalDate dateOfBirth;
    private String idType;
    private String maskedIdNumber; // Only last 4 digits visible
    private String address;
    private String city;
    private String state;
    private String postalCode;
    private String country;
    private String profileImageUrl;
    private Set<String> roles;
    private boolean emailVerified;
    private boolean phoneVerified;
    private boolean biometricEnabled;
    private boolean familyChainEnabled;
    private String accountStatus;
    private String tier; // STANDARD, GOLD, PLATINUM
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;
}
