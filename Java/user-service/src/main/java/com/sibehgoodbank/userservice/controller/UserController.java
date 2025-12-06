package com.sibehgoodbank.userservice.controller;

import com.sibehgoodbank.common.dto.ApiResponse;
import com.sibehgoodbank.common.dto.user.UserResponse;
import com.sibehgoodbank.userservice.dto.*;
import com.sibehgoodbank.userservice.entity.User;
import com.sibehgoodbank.userservice.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * User management REST controller
 */
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Users", description = "User management APIs")
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    @Operation(summary = "Get current user", description = "Get profile of authenticated user")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(
            @RequestHeader("X-User-Id") String userId) {
        
        UserResponse user = userService.getUserById(UUID.fromString(userId));
        return ResponseEntity.ok(ApiResponse.success(user));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID", description = "Get user profile by ID (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserResponse>> getUserById(@PathVariable UUID id) {
        UserResponse user = userService.getUserById(id);
        return ResponseEntity.ok(ApiResponse.success(user));
    }

    @PutMapping("/me")
    @Operation(summary = "Update profile", description = "Update current user's profile")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @RequestHeader("X-User-Id") String userId,
            @Valid @RequestBody UpdateProfileRequest request,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        UserResponse user = userService.updateProfile(
                UUID.fromString(userId), request, ipAddress, userAgent);
        
        return ResponseEntity.ok(ApiResponse.success(user));
    }

    @PostMapping("/me/change-password")
    @Operation(summary = "Change password", description = "Change current user's password")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @RequestHeader("X-User-Id") String userId,
            @Valid @RequestBody ChangePasswordRequest request,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        userService.changePassword(UUID.fromString(userId), request, ipAddress, userAgent);
        
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/me/two-factor/enable")
    @Operation(summary = "Enable 2FA", description = "Enable two-factor authentication")
    public ResponseEntity<ApiResponse<TwoFactorSetupResponse>> enableTwoFactor(
            @RequestHeader("X-User-Id") String userId,
            HttpServletRequest servletRequest) {
        
        String ipAddress = getClientIp(servletRequest);
        String userAgent = servletRequest.getHeader("User-Agent");
        
        TwoFactorSetupResponse response = userService.enableTwoFactor(
                UUID.fromString(userId), ipAddress, userAgent);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    // Admin endpoints

    @GetMapping
    @Operation(summary = "List users", description = "Get paginated list of users (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<UserResponse>>> listUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection) {
        
        Sort sort = sortDirection.equalsIgnoreCase("asc") 
                ? Sort.by(sortBy).ascending() 
                : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<UserResponse> users = userService.getUsersByStatus(User.UserStatus.ACTIVE, pageable);
        return ResponseEntity.ok(ApiResponse.success(users));
    }

    @GetMapping("/search")
    @Operation(summary = "Search users", description = "Search users by name or email (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<UserResponse>>> searchUsers(
            @RequestParam String query,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<UserResponse> users = userService.searchUsers(query, pageable);
        return ResponseEntity.ok(ApiResponse.success(users));
    }

    @GetMapping("/by-status/{status}")
    @Operation(summary = "Get users by status", description = "Get users filtered by status (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<UserResponse>>> getUsersByStatus(
            @PathVariable User.UserStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<UserResponse> users = userService.getUsersByStatus(status, pageable);
        return ResponseEntity.ok(ApiResponse.success(users));
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
