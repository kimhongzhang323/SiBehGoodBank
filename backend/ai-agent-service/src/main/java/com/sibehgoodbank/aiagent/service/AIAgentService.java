package com.sibehgoodbank.aiagent.service;

import com.sibehgoodbank.aiagent.dto.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Service interface for AI Agent operations
 */
public interface AIAgentService {
    
    /**
     * Process a chat message and return a response
     */
    Mono<ChatResponse> chat(ChatRequest request);
    
    /**
     * Process a chat message with streaming response
     */
    Flux<String> chatStream(ChatRequest request);
    
    /**
     * Process a chat with tool execution
     */
    Mono<ChatResponse> chatWithTools(ChatRequest request);
    
    /**
     * Get conversation history for a session
     */
    Mono<ConversationHistory> getConversationHistory(UUID sessionId);
    
    /**
     * Clear conversation history for a session
     */
    Mono<Void> clearConversationHistory(UUID sessionId);
    
    /**
     * Execute a specific tool directly (for testing)
     */
    Mono<ToolResult> executeTool(String toolName, ToolCall toolCall, UUID userId);
    
    /**
     * Get available tools for a user
     */
    Mono<Object> getAvailableTools(UUID userId);
    
    /**
     * Get usage statistics for a user
     */
    Mono<Object> getUsageStats(UUID userId);
}
