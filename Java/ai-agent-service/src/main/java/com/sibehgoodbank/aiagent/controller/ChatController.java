package com.sibehgoodbank.aiagent.controller;

import com.sibehgoodbank.aiagent.dto.*;
import com.sibehgoodbank.aiagent.service.AIAgentService;
import com.sibehgoodbank.aiagent.tools.BankingToolDefinitions;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * REST Controller for AI Chat Agent endpoints
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
@Tag(name = "AI Chat Agent", description = "Endpoints for interacting with the AI banking assistant")
public class ChatController {

    private final AIAgentService aiAgentService;

    @PostMapping
    @Operation(summary = "Send a chat message", 
               description = "Send a message to the AI banking assistant and receive a response")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Chat processed successfully",
                    content = @Content(schema = @Schema(implementation = ChatResponse.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "429", description = "Rate limit exceeded"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public Mono<ResponseEntity<ChatResponse>> chat(
            @Valid @RequestBody ChatRequest request,
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Received chat request from user: {}", userId);
        request.setUserId(userId);
        
        return aiAgentService.chat(request)
                .map(ResponseEntity::ok)
                .onErrorResume(IllegalArgumentException.class, e ->
                        Mono.just(ResponseEntity.badRequest().build()))
                .onErrorResume(e -> {
                    log.error("Error processing chat: {}", e.getMessage());
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
                });
    }

    @PostMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    @Operation(summary = "Stream chat response", 
               description = "Send a message and receive a streaming response via Server-Sent Events")
    public Flux<String> chatStream(
            @Valid @RequestBody ChatRequest request,
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Received streaming chat request from user: {}", userId);
        request.setUserId(userId);
        
        return aiAgentService.chatStream(request)
                .onErrorResume(e -> {
                    log.error("Error in chat stream: {}", e.getMessage());
                    return Flux.just("Error: " + e.getMessage());
                });
    }

    @PostMapping("/with-tools")
    @Operation(summary = "Chat with tool execution",
               description = "Send a message that may trigger banking tool executions")
    public Mono<ResponseEntity<ChatResponse>> chatWithTools(
            @Valid @RequestBody ChatRequest request,
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Received chat with tools request from user: {}", userId);
        request.setUserId(userId);
        request.setEnableTools(true);
        
        return aiAgentService.chatWithTools(request)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> {
                    log.error("Error processing chat with tools: {}", e.getMessage());
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
                });
    }

    @GetMapping("/session/{sessionId}")
    @Operation(summary = "Get conversation history",
               description = "Retrieve the conversation history for a specific session")
    public Mono<ResponseEntity<ConversationHistory>> getConversationHistory(
            @PathVariable UUID sessionId,
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Getting conversation history for session: {}", sessionId);
        
        return aiAgentService.getConversationHistory(sessionId)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/session/{sessionId}")
    @Operation(summary = "Clear conversation history",
               description = "Clear the conversation history for a specific session")
    public Mono<ResponseEntity<Void>> clearConversationHistory(
            @PathVariable UUID sessionId,
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Clearing conversation history for session: {}", sessionId);
        
        return aiAgentService.clearConversationHistory(sessionId)
                .then(Mono.just(ResponseEntity.noContent().<Void>build()));
    }

    @GetMapping("/tools")
    @Operation(summary = "List available tools",
               description = "Get a list of all banking tools available to the AI assistant")
    public Mono<ResponseEntity<Object>> getAvailableTools(
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Getting available tools for user: {}", userId);
        
        return aiAgentService.getAvailableTools(userId)
                .map(ResponseEntity::ok);
    }

    @PostMapping("/tools/{toolName}/execute")
    @Operation(summary = "Execute a specific tool",
               description = "Directly execute a banking tool (for testing purposes)")
    public Mono<ResponseEntity<ToolResult>> executeTool(
            @PathVariable String toolName,
            @RequestBody ToolCall toolCall,
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Executing tool: {} for user: {}", toolName, userId);
        
        return aiAgentService.executeTool(toolName, toolCall, userId)
                .map(ResponseEntity::ok)
                .onErrorResume(IllegalArgumentException.class, e ->
                        Mono.just(ResponseEntity.badRequest().build()));
    }

    @GetMapping("/usage")
    @Operation(summary = "Get usage statistics",
               description = "Get AI chat usage statistics for the current user")
    public Mono<ResponseEntity<Object>> getUsageStats(
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Getting usage stats for user: {}", userId);
        
        return aiAgentService.getUsageStats(userId)
                .map(ResponseEntity::ok);
    }

    @GetMapping("/health")
    @Operation(summary = "Health check",
               description = "Check if the AI agent service is healthy")
    public Mono<ResponseEntity<Map<String, Object>>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "ai-agent-service");
        health.put("timestamp", System.currentTimeMillis());
        health.put("tools_available", BankingToolDefinitions.getAllTools().size());
        
        return Mono.just(ResponseEntity.ok(health));
    }

    @PostMapping("/feedback")
    @Operation(summary = "Submit feedback",
               description = "Submit feedback for an AI response")
    public Mono<ResponseEntity<Map<String, Object>>> submitFeedback(
            @RequestBody FeedbackRequest feedbackRequest,
            @RequestHeader("X-User-Id") UUID userId) {
        
        log.info("Received feedback from user: {} for response: {}", userId, feedbackRequest.getResponseId());
        
        // In production, this would store feedback for model improvement
        Map<String, Object> response = new HashMap<>();
        response.put("status", "received");
        response.put("feedback_id", UUID.randomUUID().toString());
        response.put("message", "Thank you for your feedback!");
        
        return Mono.just(ResponseEntity.ok(response));
    }

    /**
     * Request object for feedback submission
     */
    @lombok.Data
    public static class FeedbackRequest {
        private String responseId;
        private String sessionId;
        private int rating; // 1-5
        private String feedbackType; // HELPFUL, NOT_HELPFUL, INCORRECT, INAPPROPRIATE
        private String comment;
    }

    @ExceptionHandler(Exception.class)
    public Mono<ResponseEntity<Map<String, Object>>> handleException(Exception e) {
        log.error("Unhandled exception: {}", e.getMessage(), e);
        
        Map<String, Object> error = new HashMap<>();
        error.put("error", "An unexpected error occurred");
        error.put("message", e.getMessage());
        error.put("timestamp", System.currentTimeMillis());
        
        return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error));
    }
}
