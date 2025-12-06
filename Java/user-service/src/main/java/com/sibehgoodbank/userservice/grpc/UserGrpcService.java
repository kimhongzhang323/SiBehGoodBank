package com.sibehgoodbank.userservice.grpc;

import com.sibehgoodbank.common.grpc.*;
import com.sibehgoodbank.userservice.entity.User;
import com.sibehgoodbank.userservice.repository.UserRepository;
import com.sibehgoodbank.common.security.PasswordService;
import io.grpc.Status;
import io.grpc.stub.StreamObserver;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.devh.boot.grpc.server.service.GrpcService;

import java.util.Optional;
import java.util.UUID;

/**
 * gRPC service implementation for User Service
 * Provides high-performance inter-service communication for user operations
 */
@GrpcService
@RequiredArgsConstructor
@Slf4j
public class UserGrpcService extends UserServiceGrpc.UserServiceImplBase {

    private final UserRepository userRepository;
    private final PasswordService passwordService;

    @Override
    public void getUser(GetUserRequest request, StreamObserver<UserResponse> responseObserver) {
        log.debug("gRPC getUser called for userId: {}", request.getUserId());
        
        try {
            UUID userId = UUID.fromString(request.getUserId());
            Optional<User> userOpt = userRepository.findById(userId);
            
            if (userOpt.isEmpty()) {
                responseObserver.onError(
                    Status.NOT_FOUND
                        .withDescription("User not found: " + request.getUserId())
                        .asRuntimeException()
                );
                return;
            }
            
            User user = userOpt.get();
            UserResponse response = buildUserResponse(user);
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid user ID format: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid user ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error getting user: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while fetching user")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void getUserByEmail(GetUserByEmailRequest request, StreamObserver<UserResponse> responseObserver) {
        log.debug("gRPC getUserByEmail called for email: {}", request.getEmail());
        
        try {
            Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
            
            if (userOpt.isEmpty()) {
                responseObserver.onError(
                    Status.NOT_FOUND
                        .withDescription("User not found with email: " + request.getEmail())
                        .asRuntimeException()
                );
                return;
            }
            
            User user = userOpt.get();
            UserResponse response = buildUserResponse(user);
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (Exception e) {
            log.error("Error getting user by email: {}", request.getEmail(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while fetching user")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void validateCredentials(ValidateCredentialsRequest request, 
                                   StreamObserver<ValidateCredentialsResponse> responseObserver) {
        log.debug("gRPC validateCredentials called for email: {}", request.getEmail());
        
        try {
            Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
            
            if (userOpt.isEmpty()) {
                ValidateCredentialsResponse response = ValidateCredentialsResponse.newBuilder()
                    .setValid(false)
                    .setUserId("")
                    .setFailureReason("User not found")
                    .build();
                responseObserver.onNext(response);
                responseObserver.onCompleted();
                return;
            }
            
            User user = userOpt.get();
            
            // Check if account is locked
            if (user.isAccountLocked()) {
                ValidateCredentialsResponse response = ValidateCredentialsResponse.newBuilder()
                    .setValid(false)
                    .setUserId(user.getId().toString())
                    .setFailureReason("Account is locked")
                    .build();
                responseObserver.onNext(response);
                responseObserver.onCompleted();
                return;
            }
            
            // Validate password
            boolean isValid = passwordService.verifyPassword(request.getPassword(), user.getPasswordHash());
            
            ValidateCredentialsResponse.Builder responseBuilder = ValidateCredentialsResponse.newBuilder()
                .setValid(isValid)
                .setUserId(isValid ? user.getId().toString() : "");
            
            if (!isValid) {
                responseBuilder.setFailureReason("Invalid password");
            }
            
            responseObserver.onNext(responseBuilder.build());
            responseObserver.onCompleted();
            
        } catch (Exception e) {
            log.error("Error validating credentials for email: {}", request.getEmail(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while validating credentials")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void checkUserExists(CheckUserExistsRequest request, 
                               StreamObserver<CheckUserExistsResponse> responseObserver) {
        log.debug("gRPC checkUserExists called for userId: {}", request.getUserId());
        
        try {
            UUID userId = UUID.fromString(request.getUserId());
            boolean exists = userRepository.existsById(userId);
            
            CheckUserExistsResponse response = CheckUserExistsResponse.newBuilder()
                .setExists(exists)
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid user ID format: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid user ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error checking user existence: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while checking user existence")
                    .asRuntimeException()
            );
        }
    }

    @Override
    public void getUserStatus(GetUserStatusRequest request, 
                             StreamObserver<UserStatusResponse> responseObserver) {
        log.debug("gRPC getUserStatus called for userId: {}", request.getUserId());
        
        try {
            UUID userId = UUID.fromString(request.getUserId());
            Optional<User> userOpt = userRepository.findById(userId);
            
            if (userOpt.isEmpty()) {
                responseObserver.onError(
                    Status.NOT_FOUND
                        .withDescription("User not found: " + request.getUserId())
                        .asRuntimeException()
                );
                return;
            }
            
            User user = userOpt.get();
            
            UserStatusResponse response = UserStatusResponse.newBuilder()
                .setUserId(user.getId().toString())
                .setStatus(user.getStatus().name())
                .setEmailVerified(user.isEmailVerified())
                .setPhoneVerified(user.isPhoneVerified())
                .setKycVerified(user.isKycVerified())
                .setMfaEnabled(user.isMfaEnabled())
                .setAccountLocked(user.isAccountLocked())
                .build();
            
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            
        } catch (IllegalArgumentException e) {
            log.error("Invalid user ID format: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INVALID_ARGUMENT
                    .withDescription("Invalid user ID format")
                    .asRuntimeException()
            );
        } catch (Exception e) {
            log.error("Error getting user status: {}", request.getUserId(), e);
            responseObserver.onError(
                Status.INTERNAL
                    .withDescription("Internal error while fetching user status")
                    .asRuntimeException()
            );
        }
    }

    /**
     * Build UserResponse from User entity
     */
    private UserResponse buildUserResponse(User user) {
        return UserResponse.newBuilder()
            .setUserId(user.getId().toString())
            .setEmail(user.getEmail())
            .setFirstName(user.getFirstName())
            .setLastName(user.getLastName())
            .setPhoneNumber(user.getPhoneNumber() != null ? user.getPhoneNumber() : "")
            .setStatus(user.getStatus().name())
            .setEmailVerified(user.isEmailVerified())
            .setPhoneVerified(user.isPhoneVerified())
            .setKycVerified(user.isKycVerified())
            .setMfaEnabled(user.isMfaEnabled())
            .setCreatedAt(user.getCreatedAt() != null ? user.getCreatedAt().toString() : "")
            .build();
    }
}
