package com.sibehgoodbank.aiagent.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sibehgoodbank.aiagent.client.AnthropicClient;
import com.sibehgoodbank.aiagent.config.AnthropicConfig;
import com.sibehgoodbank.aiagent.dto.*;
import com.sibehgoodbank.aiagent.service.AIAgentService;
import com.sibehgoodbank.aiagent.tools.BankingToolDefinitions;
import com.sibehgoodbank.aiagent.tools.BankingToolExecutor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Implementation of AI Agent Service using Anthropic Claude
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AIAgentServiceImpl implements AIAgentService {

    private final AnthropicClient anthropicClient;
    private final AnthropicConfig anthropicConfig;
    private final BankingToolExecutor bankingToolExecutor;
    private final ReactiveRedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    // In-memory conversation store (use Redis in production)
    private final Map<UUID, ConversationHistory> conversationStore = new ConcurrentHashMap<>();
    
    // Usage tracking
    private final Map<UUID, UserUsageStats> usageStats = new ConcurrentHashMap<>();
    
    // System prompt for the banking AI agent
    private static final String BANKING_SYSTEM_PROMPT = """
        You are SibehGood AI, a helpful and friendly banking assistant for SibehGoodBank.
        
        Your capabilities include:
        - Checking account balances and transaction history
        - Helping with fund transfers (internal, domestic, and international)
        - Managing beneficiaries
        - Providing exchange rates and currency conversion
        - Analyzing spending patterns and providing financial insights
        - Answering questions about cards and account details
        - Helping report issues and creating support tickets
        - Scheduling future and recurring transfers
        - Managing notifications
        
        Guidelines:
        1. Always be polite, professional, and helpful
        2. Protect customer privacy - never reveal full account numbers
        3. For sensitive operations (transfers, adding beneficiaries), confirm details before proceeding
        4. If a transfer amount exceeds $1000, remind the user about the confirmation requirement
        5. Provide clear explanations of fees and charges
        6. If you're unsure about something, say so and offer to connect to human support
        7. Use Singapore Dollar (SGD) as the default currency unless specified otherwise
        8. Format monetary amounts clearly (e.g., SGD 1,234.56)
        9. When showing dates, use DD MMM YYYY format (e.g., 15 Nov 2024)
        10. Be concise but thorough in your responses
        
        Security reminders:
        - Never ask for passwords, PINs, or OTPs
        - Don't share sensitive account details in full
        - Report any suspicious requests from users
        
        You have access to banking tools to help users. Use them when appropriate.
        """;

    @Override
    public Mono<ChatResponse> chat(ChatRequest request) {
        log.info("Processing chat request for user: {}, session: {}", request.getUserId(), request.getSessionId());
        
        return validateRequest(request)
                .flatMap(this::enrichRequestWithHistory)
                .flatMap(enrichedRequest -> {
                    if (request.isEnableTools()) {
                        return chatWithTools(enrichedRequest);
                    }
                    return processSimpleChat(enrichedRequest);
                })
                .doOnSuccess(response -> {
                    updateConversationHistory(request, response);
                    updateUsageStats(request.getUserId(), response);
                })
                .doOnError(error -> log.error("Error processing chat: {}", error.getMessage()));
    }
    
    private Mono<ChatRequest> validateRequest(ChatRequest request) {
        if (request.getUserId() == null) {
            return Mono.error(new IllegalArgumentException("User ID is required"));
        }
        
        if (request.getMessages() == null || request.getMessages().isEmpty()) {
            return Mono.error(new IllegalArgumentException("At least one message is required"));
        }
        
        // Set defaults
        if (request.getSessionId() == null) {
            request.setSessionId(UUID.randomUUID());
        }
        
        if (request.getModel() == null || request.getModel().isEmpty()) {
            request.setModel(anthropicConfig.getModel());
        }
        
        if (request.getMaxTokens() <= 0) {
            request.setMaxTokens(4096);
        }
        
        if (request.getTemperature() <= 0) {
            request.setTemperature(0.7);
        }
        
        return Mono.just(request);
    }
    
    private Mono<ChatRequest> enrichRequestWithHistory(ChatRequest request) {
        ConversationHistory history = conversationStore.get(request.getSessionId());
        
        if (history != null && history.getMessages() != null && !history.getMessages().isEmpty()) {
            // Prepend historical messages
            List<Message> allMessages = new ArrayList<>(history.getMessages());
            allMessages.addAll(request.getMessages());
            request.setMessages(allMessages);
        }
        
        // Set system prompt if not provided
        if (request.getSystemPrompt() == null || request.getSystemPrompt().isEmpty()) {
            request.setSystemPrompt(BANKING_SYSTEM_PROMPT);
        }
        
        return Mono.just(request);
    }
    
    private Mono<ChatResponse> processSimpleChat(ChatRequest request) {
        return anthropicClient.sendMessage(
                request.getModel(),
                request.getSystemPrompt(),
                request.getMessages(),
                request.getMaxTokens(),
                request.getTemperature()
        ).map(anthropicResponse -> ChatResponse.builder()
                .id(UUID.randomUUID().toString())
                .model(request.getModel())
                .content(anthropicResponse.getContent())
                .stopReason(anthropicResponse.getStopReason())
                .inputTokens(anthropicResponse.getInputTokens())
                .outputTokens(anthropicResponse.getOutputTokens())
                .build());
    }

    @Override
    public Flux<String> chatStream(ChatRequest request) {
        log.info("Processing streaming chat request for user: {}", request.getUserId());
        
        return Mono.just(request)
                .flatMap(this::validateRequest)
                .flatMap(this::enrichRequestWithHistory)
                .flatMapMany(enrichedRequest -> 
                        anthropicClient.streamMessage(
                                enrichedRequest.getModel(),
                                enrichedRequest.getSystemPrompt(),
                                enrichedRequest.getMessages(),
                                enrichedRequest.getMaxTokens()
                        )
                );
    }

    @Override
    public Mono<ChatResponse> chatWithTools(ChatRequest request) {
        log.info("Processing chat with tools for user: {}", request.getUserId());
        
        // Get tool definitions
        List<BankingToolDefinitions.ToolDefinition> tools = BankingToolDefinitions.getAllTools();
        
        return anthropicClient.sendMessageWithTools(
                request.getModel(),
                request.getSystemPrompt(),
                request.getMessages(),
                tools,
                request.getMaxTokens(),
                request.getTemperature()
        ).flatMap(response -> {
            // Check if the response contains tool calls
            if (response.getToolCalls() != null && !response.getToolCalls().isEmpty()) {
                return processToolCalls(request, response);
            }
            return Mono.just(response);
        });
    }
    
    private Mono<ChatResponse> processToolCalls(ChatRequest request, ChatResponse response) {
        List<ToolCall> toolCalls = response.getToolCalls();
        log.info("Processing {} tool calls", toolCalls.size());
        
        // Execute all tool calls
        List<Mono<ToolResult>> toolResults = toolCalls.stream()
                .map(toolCall -> executeTool(toolCall.getName(), toolCall, request.getUserId()))
                .toList();
        
        return Flux.merge(toolResults)
                .collectList()
                .flatMap(results -> {
                    // Build tool results message
                    StringBuilder toolResultsContent = new StringBuilder();
                    toolResultsContent.append("Tool results:\n\n");
                    
                    for (ToolResult result : results) {
                        toolResultsContent.append("Tool: ").append(result.getToolName()).append("\n");
                        if (result.isSuccess()) {
                            try {
                                String resultJson = objectMapper.writeValueAsString(result.getResult());
                                toolResultsContent.append("Result: ").append(resultJson).append("\n\n");
                            } catch (Exception e) {
                                toolResultsContent.append("Result: ").append(result.getResult()).append("\n\n");
                            }
                        } else {
                            toolResultsContent.append("Error: ").append(result.getError()).append("\n\n");
                        }
                    }
                    
                    // Add tool results as a new message and continue conversation
                    List<Message> updatedMessages = new ArrayList<>(request.getMessages());
                    updatedMessages.add(Message.builder()
                            .role("assistant")
                            .content(response.getContent())
                            .build());
                    updatedMessages.add(Message.builder()
                            .role("user")
                            .content(toolResultsContent.toString())
                            .build());
                    
                    // Make another API call to get final response incorporating tool results
                    return anthropicClient.sendMessage(
                            request.getModel(),
                            request.getSystemPrompt(),
                            updatedMessages,
                            request.getMaxTokens(),
                            request.getTemperature()
                    ).map(finalResponse -> ChatResponse.builder()
                            .id(UUID.randomUUID().toString())
                            .model(request.getModel())
                            .content(finalResponse.getContent())
                            .stopReason(finalResponse.getStopReason())
                            .toolCalls(toolCalls)
                            .inputTokens(response.getInputTokens() + finalResponse.getInputTokens())
                            .outputTokens(response.getOutputTokens() + finalResponse.getOutputTokens())
                            .build());
                });
    }

    @Override
    public Mono<ConversationHistory> getConversationHistory(UUID sessionId) {
        ConversationHistory history = conversationStore.get(sessionId);
        
        if (history == null) {
            return Mono.empty();
        }
        
        return Mono.just(history);
    }

    @Override
    public Mono<Void> clearConversationHistory(UUID sessionId) {
        conversationStore.remove(sessionId);
        log.info("Cleared conversation history for session: {}", sessionId);
        return Mono.empty();
    }

    @Override
    public Mono<ToolResult> executeTool(String toolName, ToolCall toolCall, UUID userId) {
        log.info("Executing tool: {} for user: {}", toolName, userId);
        
        return bankingToolExecutor.executeTool(toolName, toolCall.getInput(), userId)
                .map(result -> ToolResult.builder()
                        .toolUseId(toolCall.getId())
                        .toolName(toolName)
                        .success(true)
                        .result(result)
                        .build())
                .onErrorResume(error -> {
                    log.error("Error executing tool {}: {}", toolName, error.getMessage());
                    return Mono.just(ToolResult.builder()
                            .toolUseId(toolCall.getId())
                            .toolName(toolName)
                            .success(false)
                            .error(error.getMessage())
                            .build());
                });
    }

    @Override
    public Mono<Object> getAvailableTools(UUID userId) {
        List<BankingToolDefinitions.ToolDefinition> tools = BankingToolDefinitions.getAllTools();
        
        Map<String, Object> response = new HashMap<>();
        response.put("tools", tools);
        response.put("total_count", tools.size());
        response.put("user_id", userId);
        
        return Mono.just(response);
    }

    @Override
    public Mono<Object> getUsageStats(UUID userId) {
        UserUsageStats stats = usageStats.getOrDefault(userId, new UserUsageStats());
        
        Map<String, Object> response = new HashMap<>();
        response.put("user_id", userId);
        response.put("total_requests", stats.totalRequests);
        response.put("total_input_tokens", stats.totalInputTokens);
        response.put("total_output_tokens", stats.totalOutputTokens);
        response.put("total_tool_calls", stats.totalToolCalls);
        response.put("conversations", stats.conversations);
        response.put("period_start", stats.periodStart);
        response.put("last_request", stats.lastRequest);
        
        return Mono.just(response);
    }
    
    private void updateConversationHistory(ChatRequest request, ChatResponse response) {
        UUID sessionId = request.getSessionId();
        
        ConversationHistory history = conversationStore.computeIfAbsent(sessionId, id -> 
                ConversationHistory.builder()
                        .sessionId(id)
                        .userId(request.getUserId())
                        .messages(new ArrayList<>())
                        .toolResults(new ArrayList<>())
                        .createdAt(LocalDateTime.now())
                        .status("ACTIVE")
                        .build()
        );
        
        // Add user message
        if (request.getMessages() != null && !request.getMessages().isEmpty()) {
            Message lastUserMessage = request.getMessages().get(request.getMessages().size() - 1);
            if (!history.getMessages().contains(lastUserMessage)) {
                history.getMessages().add(lastUserMessage);
            }
        }
        
        // Add assistant response
        history.getMessages().add(Message.builder()
                .role("assistant")
                .content(response.getContent())
                .build());
        
        history.setLastUpdatedAt(LocalDateTime.now());
        history.setTotalTokensUsed(history.getTotalTokensUsed() + 
                response.getInputTokens() + response.getOutputTokens());
        
        // Store tool results
        if (response.getToolCalls() != null) {
            // Tool results would be added here
        }
        
        // Cache conversation in Redis for persistence
        cacheConversation(sessionId, history);
    }
    
    private void cacheConversation(UUID sessionId, ConversationHistory history) {
        try {
            String key = "conversation:" + sessionId;
            String value = objectMapper.writeValueAsString(history);
            redisTemplate.opsForValue()
                    .set(key, value, Duration.ofHours(24))
                    .subscribe();
        } catch (Exception e) {
            log.error("Error caching conversation: {}", e.getMessage());
        }
    }
    
    private void updateUsageStats(UUID userId, ChatResponse response) {
        UserUsageStats stats = usageStats.computeIfAbsent(userId, id -> new UserUsageStats());
        
        stats.totalRequests++;
        stats.totalInputTokens += response.getInputTokens();
        stats.totalOutputTokens += response.getOutputTokens();
        stats.lastRequest = LocalDateTime.now();
        
        if (response.getToolCalls() != null) {
            stats.totalToolCalls += response.getToolCalls().size();
        }
    }
    
    // Inner class for tracking usage
    private static class UserUsageStats {
        long totalRequests = 0;
        long totalInputTokens = 0;
        long totalOutputTokens = 0;
        long totalToolCalls = 0;
        int conversations = 0;
        LocalDateTime periodStart = LocalDateTime.now();
        LocalDateTime lastRequest = null;
    }
}
