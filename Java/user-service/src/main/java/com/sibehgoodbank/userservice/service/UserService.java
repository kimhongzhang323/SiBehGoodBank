package com.sibehgoodbank.userservice.service;

import com.sibehgoodbank.common.dto.ApiResponse;
import com.sibehgoodbank.common.dto.user.UserRegistrationRequest;
import com.sibehgoodbank.common.dto.user.UserResponse;
import com.sibehgoodbank.common.messaging.kafka.KafkaConfig;
import com.sibehgoodbank.common.security.EncryptionService;
import com.sibehgoodbank.common.security.JwtTokenService;
import com.sibehgoodbank.common.security.PasswordService;
import com.sibehgoodbank.userservice.dto.*;
import com.sibehgoodbank.userservice.entity.RefreshToken;
import com.sibehgoodbank.userservice.entity.User;
import com.sibehgoodbank.userservice.entity.UserAuditLog;
import com.sibehgoodbank.userservice.exception.UserAlreadyExistsException;
import com.sibehgoodbank.userservice.exception.UserNotFoundException;
import com.sibehgoodbank.userservice.exception.InvalidCredentialsException;
import com.sibehgoodbank.userservice.exception.AccountLockedException;
import com.sibehgoodbank.userservice.repository.RefreshTokenRepository;
import com.sibehgoodbank.userservice.repository.UserAuditLogRepository;
import com.sibehgoodbank.userservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

/**
 * User service with comprehensive business logic for banking operations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserAuditLogRepository auditLogRepository;
    private final PasswordService passwordService;
    private final JwtTokenService jwtTokenService;
    private final EncryptionService encryptionService;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    /**
     * Register a new user
     */
    @Transactional
    public UserResponse registerUser(UserRegistrationRequest request, String ipAddress, String userAgent) {
        log.info("Registering new user with email: {}", request.getEmail());

        // Check if user already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("Email already registered");
        }
        if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new UserAlreadyExistsException("Phone number already registered");
        }

        // Validate password strength
        if (!passwordService.isPasswordStrongEnough(request.getPassword())) {
            throw new IllegalArgumentException("Password does not meet strength requirements");
        }

        // Create user entity with encrypted sensitive data
        User user = User.builder()
                .email(request.getEmail().toLowerCase())
                .passwordHash(passwordService.hashPassword(request.getPassword()))
                .fullName(request.getFullName())
                .phoneNumber(request.getPhoneNumber())
                .dateOfBirth(request.getDateOfBirth())
                .idType(request.getIdType())
                .idNumberEncrypted(encryptionService.encrypt(request.getIdNumber()))
                .addressEncrypted(encryptionService.encrypt(request.getAddress()))
                .city(request.getCity())
                .state(request.getState())
                .postalCode(request.getPostalCode())
                .country(request.getCountry())
                .roles(Set.of("ROLE_USER"))
                .status(User.UserStatus.PENDING_VERIFICATION)
                .tier(User.UserTier.STANDARD)
                .passwordChangedAt(LocalDateTime.now())
                .build();

        user = userRepository.save(user);

        // Create audit log
        createAuditLog(user.getId(), UserAuditLog.AuditAction.REGISTRATION, 
                "user", user.getId().toString(), "New user registration", 
                ipAddress, userAgent, null, UserAuditLog.AuditStatus.SUCCESS);

        // Publish event to Kafka
        publishUserEvent("USER_REGISTERED", user);

        log.info("User registered successfully with id: {}", user.getId());
        return mapToUserResponse(user);
    }

    /**
     * Authenticate user and return tokens
     */
    @Transactional
    public AuthResponse authenticate(LoginRequest request, String ipAddress, String userAgent, String deviceId) {
        log.info("Authenticating user: {}", request.getEmail());

        User user = userRepository.findByEmail(request.getEmail().toLowerCase())
                .orElseThrow(() -> new InvalidCredentialsException("Invalid email or password"));

        // Check if account is locked
        if (user.isLocked()) {
            createAuditLog(user.getId(), UserAuditLog.AuditAction.LOGIN_FAILED,
                    "user", user.getId().toString(), "Account locked",
                    ipAddress, userAgent, deviceId, UserAuditLog.AuditStatus.FAILURE);
            throw new AccountLockedException("Account is locked until " + user.getLockedUntil());
        }

        // Check account status
        if (user.getStatus() == User.UserStatus.SUSPENDED) {
            throw new AccountLockedException("Account is suspended");
        }
        if (user.getStatus() == User.UserStatus.DEACTIVATED) {
            throw new AccountLockedException("Account is deactivated");
        }

        // Verify password
        if (!passwordService.verifyPassword(request.getPassword(), user.getPasswordHash())) {
            user.incrementFailedLoginAttempts();
            userRepository.save(user);
            
            createAuditLog(user.getId(), UserAuditLog.AuditAction.LOGIN_FAILED,
                    "user", user.getId().toString(), "Invalid password. Attempts: " + user.getFailedLoginAttempts(),
                    ipAddress, userAgent, deviceId, UserAuditLog.AuditStatus.FAILURE);
            
            throw new InvalidCredentialsException("Invalid email or password");
        }

        // Check if password needs rehashing (upgraded algorithm)
        if (passwordService.needsRehash(user.getPasswordHash())) {
            user.setPasswordHash(passwordService.hashPassword(request.getPassword()));
        }

        // Record successful login
        user.recordLogin();
        userRepository.save(user);

        // Generate tokens
        String accessToken = jwtTokenService.generateAccessToken(
                user.getId().toString(),
                user.getEmail(),
                new ArrayList<>(user.getRoles())
        );
        String refreshToken = jwtTokenService.generateRefreshToken(user.getId().toString());

        // Save refresh token
        RefreshToken refreshTokenEntity = RefreshToken.builder()
                .token(refreshToken)
                .user(user)
                .deviceId(deviceId)
                .deviceName(request.getDeviceName())
                .ipAddress(ipAddress)
                .userAgent(userAgent)
                .expiresAt(LocalDateTime.now().plusDays(7))
                .build();
        refreshTokenRepository.save(refreshTokenEntity);

        // Create audit log
        String sessionId = UUID.randomUUID().toString();
        createAuditLog(user.getId(), UserAuditLog.AuditAction.LOGIN,
                "session", sessionId, "User logged in",
                ipAddress, userAgent, deviceId, UserAuditLog.AuditStatus.SUCCESS);

        // Publish event
        publishUserEvent("USER_LOGIN", user);

        log.info("User authenticated successfully: {}", user.getEmail());
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(900) // 15 minutes
                .user(mapToUserResponse(user))
                .build();
    }

    /**
     * Refresh access token
     */
    @Transactional
    public TokenResponse refreshToken(String refreshToken, String ipAddress, String userAgent) {
        log.info("Refreshing access token");

        RefreshToken tokenEntity = refreshTokenRepository.findByTokenAndRevokedFalse(refreshToken)
                .orElseThrow(() -> new InvalidCredentialsException("Invalid refresh token"));

        if (tokenEntity.isExpired()) {
            tokenEntity.revoke("Token expired");
            refreshTokenRepository.save(tokenEntity);
            throw new InvalidCredentialsException("Refresh token expired");
        }

        User user = tokenEntity.getUser();

        // Generate new tokens
        String newAccessToken = jwtTokenService.generateAccessToken(
                user.getId().toString(),
                user.getEmail(),
                new ArrayList<>(user.getRoles())
        );
        String newRefreshToken = jwtTokenService.generateRefreshToken(user.getId().toString());

        // Revoke old token and create new
        tokenEntity.revoke("Token refreshed");
        refreshTokenRepository.save(tokenEntity);

        RefreshToken newTokenEntity = RefreshToken.builder()
                .token(newRefreshToken)
                .user(user)
                .deviceId(tokenEntity.getDeviceId())
                .deviceName(tokenEntity.getDeviceName())
                .ipAddress(ipAddress)
                .userAgent(userAgent)
                .expiresAt(LocalDateTime.now().plusDays(7))
                .build();
        refreshTokenRepository.save(newTokenEntity);

        createAuditLog(user.getId(), UserAuditLog.AuditAction.TOKEN_REFRESH,
                "token", tokenEntity.getId().toString(), "Token refreshed",
                ipAddress, userAgent, tokenEntity.getDeviceId(), UserAuditLog.AuditStatus.SUCCESS);

        return TokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType("Bearer")
                .expiresIn(900)
                .build();
    }

    /**
     * Logout user - revoke refresh token
     */
    @Transactional
    public void logout(String refreshToken, String ipAddress, String userAgent) {
        log.info("Logging out user");

        refreshTokenRepository.findByTokenAndRevokedFalse(refreshToken)
                .ifPresent(token -> {
                    token.revoke("User logout");
                    refreshTokenRepository.save(token);
                    
                    createAuditLog(token.getUser().getId(), UserAuditLog.AuditAction.LOGOUT,
                            "token", token.getId().toString(), "User logged out",
                            ipAddress, userAgent, token.getDeviceId(), UserAuditLog.AuditStatus.SUCCESS);
                });
    }

    /**
     * Logout from all devices
     */
    @Transactional
    public void logoutAllDevices(UUID userId, String ipAddress, String userAgent) {
        log.info("Logging out user from all devices: {}", userId);

        refreshTokenRepository.revokeAllByUserId(userId, LocalDateTime.now(), "Logout from all devices");

        createAuditLog(userId, UserAuditLog.AuditAction.TOKEN_REVOKED,
                "user", userId.toString(), "All tokens revoked",
                ipAddress, userAgent, null, UserAuditLog.AuditStatus.SUCCESS);
    }

    /**
     * Get user by ID
     */
    @Cacheable(value = "user", key = "#userId")
    public UserResponse getUserById(UUID userId) {
        log.info("Getting user by id: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found"));
        
        return mapToUserResponse(user);
    }

    /**
     * Get user by email
     */
    public UserResponse getUserByEmail(String email) {
        log.info("Getting user by email: {}", email);
        
        User user = userRepository.findByEmail(email.toLowerCase())
                .orElseThrow(() -> new UserNotFoundException("User not found"));
        
        return mapToUserResponse(user);
    }

    /**
     * Update user profile
     */
    @Transactional
    @CacheEvict(value = "user", key = "#userId")
    public UserResponse updateProfile(UUID userId, UpdateProfileRequest request, 
                                       String ipAddress, String userAgent) {
        log.info("Updating profile for user: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getNickname() != null) {
            user.setNickname(request.getNickname());
        }
        if (request.getAddress() != null) {
            user.setAddressEncrypted(encryptionService.encrypt(request.getAddress()));
        }
        if (request.getCity() != null) {
            user.setCity(request.getCity());
        }
        if (request.getState() != null) {
            user.setState(request.getState());
        }
        if (request.getPostalCode() != null) {
            user.setPostalCode(request.getPostalCode());
        }
        if (request.getProfileImageUrl() != null) {
            user.setProfileImageUrl(request.getProfileImageUrl());
        }

        user = userRepository.save(user);

        createAuditLog(userId, UserAuditLog.AuditAction.PROFILE_UPDATED,
                "user", userId.toString(), "Profile updated",
                ipAddress, userAgent, null, UserAuditLog.AuditStatus.SUCCESS);

        publishUserEvent("USER_PROFILE_UPDATED", user);

        return mapToUserResponse(user);
    }

    /**
     * Change password
     */
    @Transactional
    public void changePassword(UUID userId, ChangePasswordRequest request,
                               String ipAddress, String userAgent) {
        log.info("Changing password for user: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        // Verify current password
        if (!passwordService.verifyPassword(request.getCurrentPassword(), user.getPasswordHash())) {
            createAuditLog(userId, UserAuditLog.AuditAction.PASSWORD_CHANGE,
                    "user", userId.toString(), "Invalid current password",
                    ipAddress, userAgent, null, UserAuditLog.AuditStatus.FAILURE);
            throw new InvalidCredentialsException("Current password is incorrect");
        }

        // Validate new password
        if (!passwordService.isPasswordStrongEnough(request.getNewPassword())) {
            throw new IllegalArgumentException("New password does not meet strength requirements");
        }

        // Update password
        user.setPasswordHash(passwordService.hashPassword(request.getNewPassword()));
        user.setPasswordChangedAt(LocalDateTime.now());
        userRepository.save(user);

        // Revoke all refresh tokens
        refreshTokenRepository.revokeAllByUserId(userId, LocalDateTime.now(), "Password changed");

        createAuditLog(userId, UserAuditLog.AuditAction.PASSWORD_CHANGE,
                "user", userId.toString(), "Password changed successfully",
                ipAddress, userAgent, null, UserAuditLog.AuditStatus.SUCCESS);

        publishUserEvent("USER_PASSWORD_CHANGED", user);
    }

    /**
     * Enable two-factor authentication
     */
    @Transactional
    @CacheEvict(value = "user", key = "#userId")
    public TwoFactorSetupResponse enableTwoFactor(UUID userId, String ipAddress, String userAgent) {
        log.info("Enabling 2FA for user: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        String secret = passwordService.generateOtp(32);
        user.setTwoFactorSecretEncrypted(encryptionService.encrypt(secret));
        user.setTwoFactorEnabled(true);
        userRepository.save(user);

        createAuditLog(userId, UserAuditLog.AuditAction.TWO_FACTOR_ENABLED,
                "user", userId.toString(), "2FA enabled",
                ipAddress, userAgent, null, UserAuditLog.AuditStatus.SUCCESS);

        return TwoFactorSetupResponse.builder()
                .secret(secret)
                .qrCodeUrl("otpauth://totp/SibehGoodBank:" + user.getEmail() + "?secret=" + secret)
                .build();
    }

    /**
     * Verify email
     */
    @Transactional
    @CacheEvict(value = "user", key = "#userId")
    public void verifyEmail(UUID userId, String ipAddress, String userAgent) {
        log.info("Verifying email for user: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        user.setEmailVerified(true);
        if (user.getStatus() == User.UserStatus.PENDING_VERIFICATION && user.isPhoneVerified()) {
            user.setStatus(User.UserStatus.ACTIVE);
        }
        userRepository.save(user);

        createAuditLog(userId, UserAuditLog.AuditAction.EMAIL_VERIFIED,
                "user", userId.toString(), "Email verified",
                ipAddress, userAgent, null, UserAuditLog.AuditStatus.SUCCESS);
    }

    /**
     * Search users (admin function)
     */
    public Page<UserResponse> searchUsers(String query, Pageable pageable) {
        return userRepository.searchByNameOrEmail(query, pageable)
                .map(this::mapToUserResponse);
    }

    /**
     * Get users by status (admin function)
     */
    public Page<UserResponse> getUsersByStatus(User.UserStatus status, Pageable pageable) {
        return userRepository.findByStatus(status, pageable)
                .map(this::mapToUserResponse);
    }

    // Helper methods

    private UserResponse mapToUserResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .nickname(user.getNickname())
                .phoneNumber(user.getPhoneNumber())
                .dateOfBirth(user.getDateOfBirth())
                .city(user.getCity())
                .state(user.getState())
                .postalCode(user.getPostalCode())
                .country(user.getCountry())
                .profileImageUrl(user.getProfileImageUrl())
                .roles(user.getRoles())
                .emailVerified(user.isEmailVerified())
                .phoneVerified(user.isPhoneVerified())
                .twoFactorEnabled(user.isTwoFactorEnabled())
                .status(user.getStatus().name())
                .tier(user.getTier().name())
                .createdAt(user.getCreatedAt())
                .lastLoginAt(user.getLastLoginAt())
                .build();
    }

    private void createAuditLog(UUID userId, UserAuditLog.AuditAction action,
                                String resourceType, String resourceId, String details,
                                String ipAddress, String userAgent, String deviceId,
                                UserAuditLog.AuditStatus status) {
        UserAuditLog log = UserAuditLog.builder()
                .userId(userId)
                .action(action)
                .resourceType(resourceType)
                .resourceId(resourceId)
                .details(details)
                .ipAddress(ipAddress)
                .userAgent(userAgent)
                .deviceId(deviceId)
                .status(status)
                .build();
        auditLogRepository.save(log);
    }

    private void publishUserEvent(String eventType, User user) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("eventType", eventType);
            event.put("userId", user.getId().toString());
            event.put("email", user.getEmail());
            event.put("timestamp", LocalDateTime.now().toString());
            kafkaTemplate.send(KafkaConfig.USER_EVENTS_TOPIC, user.getId().toString(), event);
        } catch (Exception e) {
            log.error("Failed to publish user event: {}", e.getMessage());
        }
    }
}
