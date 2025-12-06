package com.sibehgoodbank.userservice.controller;

import com.sibehgoodbank.common.dto.ApiResponse;
import com.sibehgoodbank.common.dto.user.UserRegistrationRequest;
import com.sibehgoodbank.common.dto.user.UserResponse;
import com.sibehgoodbank.userservice.dto.*;
import com.sibehgoodbank.userservice.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication REST controller
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Authentication", description = "User authentication and registration APIs")
public class AuthController {

    private final UserService userService;

    @PostMapping("/register")
    @Operation(summary = "Register a new user", description = "Create a new user account with full KYC details")
    public ResponseEntity<ApiResponse<UserResponse>> register(
            @Valid @RequestBody UserRegistrationRequest request,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        UserResponse user = userService.registerUser(request, ipAddress, userAgent);
        
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(user));
    }

    @PostMapping("/login")
    @Operation(summary = "User login", description = "Authenticate user and return JWT tokens")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        String deviceId = request.getDeviceId() != null ? request.getDeviceId() : 
                          servletRequest.getHeader("X-Device-Id");
        
        AuthResponse authResponse = userService.authenticate(request, ipAddress, userAgent, deviceId);
        
        return ResponseEntity.ok(ApiResponse.success(authResponse));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token", description = "Get new access token using refresh token")
    public ResponseEntity<ApiResponse<TokenResponse>> refreshToken(
            @RequestHeader("X-Refresh-Token") String refreshToken,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        TokenResponse tokenResponse = userService.refreshToken(refreshToken, ipAddress, userAgent);
        
        return ResponseEntity.ok(ApiResponse.success(tokenResponse));
    }

    @PostMapping("/logout")
    @Operation(summary = "User logout", description = "Revoke refresh token")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestHeader("X-Refresh-Token") String refreshToken,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        userService.logout(refreshToken, ipAddress, userAgent);
        
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/logout-all")
    @Operation(summary = "Logout from all devices", description = "Revoke all refresh tokens for user")
    public ResponseEntity<ApiResponse<Void>> logoutAll(
            @RequestHeader("X-User-Id") String userId,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        userService.logoutAllDevices(java.util.UUID.fromString(userId), ipAddress, userAgent);
        
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/verify-email")
    @Operation(summary = "Verify email", description = "Mark email as verified")
    public ResponseEntity<ApiResponse<Void>> verifyEmail(
            @RequestParam String token,
            HttpServletRequest servletRequest) {
        
        // In real implementation, decode the token to get userId
        // For now, this is a placeholder
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        log.info("Email verification requested with token: {}", token);
        // userService.verifyEmail(userId, ipAddress, userAgent);
        
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/forgot-password")
    @Operation(summary = "Forgot password", description = "Initiate password reset flow")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(
            @RequestParam String email) {
        
        log.info("Password reset requested for: {}", email);
        // TODO: Implement password reset flow with email service
        
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        return request.getRemoteAddr();
    }
}
