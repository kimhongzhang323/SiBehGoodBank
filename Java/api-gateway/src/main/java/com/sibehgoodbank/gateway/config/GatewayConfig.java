package com.sibehgoodbank.gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                // User Service Routes
                .route("user-service", r -> r
                        .path("/api/v1/users/**", "/api/v1/auth/**")
                        .filters(f -> f
                                .circuitBreaker(config -> config
                                        .setName("userServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/user"))
                                .retry(config -> config
                                        .setRetries(3)
                                        .setStatuses(org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE))
                                .addRequestHeader("X-Gateway-Request", "true")
                                .preserveHostHeader())
                        .uri("lb://user-service"))
                
                // Account Service Routes
                .route("account-service", r -> r
                        .path("/api/v1/accounts/**")
                        .filters(f -> f
                                .circuitBreaker(config -> config
                                        .setName("accountServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/account"))
                                .retry(config -> config
                                        .setRetries(3)
                                        .setStatuses(org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE))
                                .addRequestHeader("X-Gateway-Request", "true"))
                        .uri("lb://account-service"))
                
                // Transaction Service Routes
                .route("transaction-service", r -> r
                        .path("/api/v1/transactions/**", "/api/v1/transfers/**")
                        .filters(f -> f
                                .circuitBreaker(config -> config
                                        .setName("transactionServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/transaction"))
                                .retry(config -> config
                                        .setRetries(2)
                                        .setStatuses(org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE))
                                .addRequestHeader("X-Gateway-Request", "true"))
                        .uri("lb://transaction-service"))
                
                // AI Agent Service Routes
                .route("ai-agent-service", r -> r
                        .path("/api/v1/ai/**", "/api/v1/chat/**")
                        .filters(f -> f
                                .circuitBreaker(config -> config
                                        .setName("aiAgentCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/ai"))
                                .addRequestHeader("X-Gateway-Request", "true"))
                        .uri("lb://ai-agent-service"))
                
                // Notification Service Routes
                .route("notification-service", r -> r
                        .path("/api/v1/notifications/**")
                        .filters(f -> f
                                .circuitBreaker(config -> config
                                        .setName("notificationCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/notification"))
                                .addRequestHeader("X-Gateway-Request", "true"))
                        .uri("lb://notification-service"))
                
                // Analytics Service Routes
                .route("analytics-service", r -> r
                        .path("/api/v1/analytics/**")
                        .filters(f -> f
                                .circuitBreaker(config -> config
                                        .setName("analyticsCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/analytics"))
                                .addRequestHeader("X-Gateway-Request", "true"))
                        .uri("lb://analytics-service"))
                
                .build();
    }
}
