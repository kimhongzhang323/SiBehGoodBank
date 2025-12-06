package com.sibehgoodbank.aiagent.client;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sibehgoodbank.aiagent.config.AnthropicConfig;
import com.sibehgoodbank.aiagent.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class AnthropicClient {
    
    private final AnthropicConfig config;
    private final ObjectMapper objectMapper;
    private WebClient webClient;
    
    @jakarta.annotation.PostConstruct
    public void init() {
        this.webClient = WebClient.builder()
                .baseUrl(config.getApiUrl())
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .defaultHeader("x-api-key", config.getApiKey())
                .defaultHeader("anthropic-version", "2023-06-01")
                .build();
    }
    
    /**
     * Send a message to Claude and get a complete response
     */
    public Mono<ChatResponse> sendMessage(ChatRequest request) {
        log.debug("Sending message to Anthropic API: {}", request.getModel());
        
        AnthropicRequest anthropicRequest = buildAnthropicRequest(request);
        
        return webClient.post()
                .uri("/messages")
                .bodyValue(anthropicRequest)
                .retrieve()
                .bodyToMono(AnthropicResponse.class)
                .timeout(Duration.ofSeconds(config.getTimeoutSeconds()))
                .map(this::mapToChatResponse)
                .doOnSuccess(response -> log.debug("Received response from Anthropic"))
                .doOnError(error -> log.error("Error calling Anthropic API: {}", error.getMessage()))
                .onErrorResume(WebClientResponseException.class, e -> {
                    log.error("Anthropic API error: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
                    return Mono.error(new RuntimeException("AI service error: " + e.getMessage()));
                });
    }
    
    /**
     * Stream response from Claude for real-time chat experience
     */
    public Flux<StreamChunk> streamMessage(ChatRequest request) {
        log.debug("Starting streaming message to Anthropic API");
        
        AnthropicRequest anthropicRequest = buildAnthropicRequest(request);
        anthropicRequest.setStream(true);
        
        return webClient.post()
                .uri("/messages")
                .bodyValue(anthropicRequest)
                .retrieve()
                .bodyToFlux(String.class)
                .filter(line -> line.startsWith("data: ") && !line.contains("[DONE]"))
                .map(line -> line.substring(6)) // Remove "data: " prefix
                .flatMap(this::parseStreamEvent)
                .timeout(Duration.ofSeconds(config.getTimeoutSeconds()))
                .doOnComplete(() -> log.debug("Stream completed"))
                .doOnError(error -> log.error("Stream error: {}", error.getMessage()));
    }
    
    /**
     * Send a message with function/tool calling support
     */
    public Mono<ChatResponse> sendMessageWithTools(ChatRequest request, List<Tool> tools) {
        log.debug("Sending message with {} tools", tools.size());
        
        AnthropicRequest anthropicRequest = buildAnthropicRequest(request);
        anthropicRequest.setTools(tools);
        
        return webClient.post()
                .uri("/messages")
                .bodyValue(anthropicRequest)
                .retrieve()
                .bodyToMono(AnthropicResponse.class)
                .timeout(Duration.ofSeconds(config.getTimeoutSeconds()))
                .map(this::mapToChatResponse)
                .doOnSuccess(response -> {
                    if (response.getToolCalls() != null && !response.getToolCalls().isEmpty()) {
                        log.debug("AI requested {} tool calls", response.getToolCalls().size());
                    }
                });
    }
    
    private AnthropicRequest buildAnthropicRequest(ChatRequest request) {
        return AnthropicRequest.builder()
                .model(request.getModel() != null ? request.getModel() : config.getModel())
                .maxTokens(request.getMaxTokens() != null ? request.getMaxTokens() : config.getMaxTokens())
                .temperature(request.getTemperature() != null ? request.getTemperature() : config.getTemperature())
                .system(request.getSystemPrompt())
                .messages(request.getMessages())
                .build();
    }
    
    private ChatResponse mapToChatResponse(AnthropicResponse response) {
        ChatResponse.ChatResponseBuilder builder = ChatResponse.builder()
                .id(response.getId())
                .model(response.getModel())
                .stopReason(response.getStopReason());
        
        if (response.getContent() != null && !response.getContent().isEmpty()) {
            StringBuilder textContent = new StringBuilder();
            List<ToolCall> toolCalls = new java.util.ArrayList<>();
            
            for (ContentBlock block : response.getContent()) {
                if ("text".equals(block.getType())) {
                    textContent.append(block.getText());
                } else if ("tool_use".equals(block.getType())) {
                    toolCalls.add(ToolCall.builder()
                            .id(block.getId())
                            .name(block.getName())
                            .arguments(block.getInput())
                            .build());
                }
            }
            
            builder.content(textContent.toString());
            if (!toolCalls.isEmpty()) {
                builder.toolCalls(toolCalls);
            }
        }
        
        if (response.getUsage() != null) {
            builder.inputTokens(response.getUsage().getInputTokens());
            builder.outputTokens(response.getUsage().getOutputTokens());
        }
        
        return builder.build();
    }
    
    private Flux<StreamChunk> parseStreamEvent(String json) {
        try {
            StreamEvent event = objectMapper.readValue(json, StreamEvent.class);
            
            if ("content_block_delta".equals(event.getType())) {
                Delta delta = event.getDelta();
                if (delta != null && "text_delta".equals(delta.getType())) {
                    return Flux.just(StreamChunk.builder()
                            .type("text")
                            .text(delta.getText())
                            .build());
                }
            } else if ("message_stop".equals(event.getType())) {
                return Flux.just(StreamChunk.builder()
                        .type("end")
                        .build());
            }
            
            return Flux.empty();
        } catch (Exception e) {
            log.warn("Failed to parse stream event: {}", e.getMessage());
            return Flux.empty();
        }
    }
    
    // Request/Response DTOs for Anthropic API
    
    @lombok.Data
    @lombok.Builder
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class AnthropicRequest {
        private String model;
        
        @JsonProperty("max_tokens")
        private Integer maxTokens;
        
        private Double temperature;
        private String system;
        private List<Message> messages;
        private List<Tool> tools;
        private Boolean stream;
    }
    
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class AnthropicResponse {
        private String id;
        private String type;
        private String role;
        private List<ContentBlock> content;
        private String model;
        
        @JsonProperty("stop_reason")
        private String stopReason;
        
        @JsonProperty("stop_sequence")
        private String stopSequence;
        
        private Usage usage;
    }
    
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class ContentBlock {
        private String type;
        private String text;
        private String id;
        private String name;
        private Map<String, Object> input;
    }
    
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class Usage {
        @JsonProperty("input_tokens")
        private Integer inputTokens;
        
        @JsonProperty("output_tokens")
        private Integer outputTokens;
    }
    
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class StreamEvent {
        private String type;
        private Integer index;
        
        @JsonProperty("content_block")
        private ContentBlock contentBlock;
        
        private Delta delta;
    }
    
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class Delta {
        private String type;
        private String text;
        
        @JsonProperty("partial_json")
        private String partialJson;
    }
}
