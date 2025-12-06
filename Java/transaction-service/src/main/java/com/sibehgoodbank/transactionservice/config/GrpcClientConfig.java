package com.sibehgoodbank.transactionservice.config;

import com.sibehgoodbank.common.grpc.AccountServiceGrpc;
import com.sibehgoodbank.common.grpc.NotificationServiceGrpc;
import com.sibehgoodbank.common.grpc.UserServiceGrpc;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import jakarta.annotation.PreDestroy;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

/**
 * Configuration for gRPC clients used by Transaction Service
 * to communicate with other microservices
 */
@Configuration
@Slf4j
public class GrpcClientConfig {

    @Value("${grpc.client.user-service.address:user-service}")
    private String userServiceHost;

    @Value("${grpc.client.user-service.port:9081}")
    private int userServicePort;

    @Value("${grpc.client.account-service.address:account-service}")
    private String accountServiceHost;

    @Value("${grpc.client.account-service.port:9082}")
    private int accountServicePort;

    @Value("${grpc.client.notification-service.address:notification-service}")
    private String notificationServiceHost;

    @Value("${grpc.client.notification-service.port:9085}")
    private int notificationServicePort;

    private ManagedChannel userChannel;
    private ManagedChannel accountChannel;
    private ManagedChannel notificationChannel;

    @Bean
    public ManagedChannel userServiceChannel() {
        log.info("Creating gRPC channel to User Service at {}:{}", userServiceHost, userServicePort);
        userChannel = ManagedChannelBuilder
                .forAddress(userServiceHost, userServicePort)
                .usePlaintext()
                .keepAliveTime(30, TimeUnit.SECONDS)
                .keepAliveTimeout(10, TimeUnit.SECONDS)
                .maxInboundMessageSize(16 * 1024 * 1024) // 16MB
                .build();
        return userChannel;
    }

    @Bean
    public ManagedChannel accountServiceChannel() {
        log.info("Creating gRPC channel to Account Service at {}:{}", accountServiceHost, accountServicePort);
        accountChannel = ManagedChannelBuilder
                .forAddress(accountServiceHost, accountServicePort)
                .usePlaintext()
                .keepAliveTime(30, TimeUnit.SECONDS)
                .keepAliveTimeout(10, TimeUnit.SECONDS)
                .maxInboundMessageSize(16 * 1024 * 1024)
                .build();
        return accountChannel;
    }

    @Bean
    public ManagedChannel notificationServiceChannel() {
        log.info("Creating gRPC channel to Notification Service at {}:{}", notificationServiceHost, notificationServicePort);
        notificationChannel = ManagedChannelBuilder
                .forAddress(notificationServiceHost, notificationServicePort)
                .usePlaintext()
                .keepAliveTime(30, TimeUnit.SECONDS)
                .keepAliveTimeout(10, TimeUnit.SECONDS)
                .maxInboundMessageSize(16 * 1024 * 1024)
                .build();
        return notificationChannel;
    }

    @Bean
    public UserServiceGrpc.UserServiceBlockingStub userServiceBlockingStub(ManagedChannel userServiceChannel) {
        return UserServiceGrpc.newBlockingStub(userServiceChannel);
    }

    @Bean
    public UserServiceGrpc.UserServiceFutureStub userServiceFutureStub(ManagedChannel userServiceChannel) {
        return UserServiceGrpc.newFutureStub(userServiceChannel);
    }

    @Bean
    public AccountServiceGrpc.AccountServiceBlockingStub accountServiceBlockingStub(ManagedChannel accountServiceChannel) {
        return AccountServiceGrpc.newBlockingStub(accountServiceChannel);
    }

    @Bean
    public AccountServiceGrpc.AccountServiceFutureStub accountServiceFutureStub(ManagedChannel accountServiceChannel) {
        return AccountServiceGrpc.newFutureStub(accountServiceChannel);
    }

    @Bean
    public NotificationServiceGrpc.NotificationServiceBlockingStub notificationServiceBlockingStub(ManagedChannel notificationServiceChannel) {
        return NotificationServiceGrpc.newBlockingStub(notificationServiceChannel);
    }

    @Bean
    public NotificationServiceGrpc.NotificationServiceFutureStub notificationServiceFutureStub(ManagedChannel notificationServiceChannel) {
        return NotificationServiceGrpc.newFutureStub(notificationServiceChannel);
    }

    @PreDestroy
    public void shutdown() {
        log.info("Shutting down gRPC channels");
        shutdownChannel(userChannel, "User Service");
        shutdownChannel(accountChannel, "Account Service");
        shutdownChannel(notificationChannel, "Notification Service");
    }

    private void shutdownChannel(ManagedChannel channel, String serviceName) {
        if (channel != null && !channel.isShutdown()) {
            try {
                channel.shutdown().awaitTermination(5, TimeUnit.SECONDS);
                log.info("gRPC channel to {} shut down successfully", serviceName);
            } catch (InterruptedException e) {
                log.warn("Interrupted while shutting down gRPC channel to {}", serviceName);
                channel.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
    }
}
