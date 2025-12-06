package com.sibehgoodbank.gateway.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/user")
    public Mono<ResponseEntity<Map<String, Object>>> userServiceFallback() {
        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(createFallbackResponse("User Service")));
    }

    @GetMapping("/account")
    public Mono<ResponseEntity<Map<String, Object>>> accountServiceFallback() {
        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(createFallbackResponse("Account Service")));
    }

    @GetMapping("/transaction")
    public Mono<ResponseEntity<Map<String, Object>>> transactionServiceFallback() {
        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(createFallbackResponse("Transaction Service")));
    }

    @GetMapping("/ai")
    public Mono<ResponseEntity<Map<String, Object>>> aiAgentServiceFallback() {
        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(createFallbackResponse("AI Agent Service")));
    }

    @GetMapping("/notification")
    public Mono<ResponseEntity<Map<String, Object>>> notificationServiceFallback() {
        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(createFallbackResponse("Notification Service")));
    }

    @GetMapping("/analytics")
    public Mono<ResponseEntity<Map<String, Object>>> analyticsServiceFallback() {
        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(createFallbackResponse("Analytics Service")));
    }

    private Map<String, Object> createFallbackResponse(String serviceName) {
        return Map.of(
                "status", "error",
                "code", "SERVICE_UNAVAILABLE",
                "message", serviceName + " is temporarily unavailable. Please try again later.",
                "timestamp", LocalDateTime.now().toString(),
                "service", serviceName.toLowerCase().replace(" ", "-")
        );
    }
}
