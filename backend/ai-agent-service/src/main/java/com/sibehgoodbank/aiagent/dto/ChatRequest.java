package com.sibehgoodbank.aiagent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRequest {
    
    private String sessionId;
    private String userId;
    private String model;
    private String systemPrompt;
    private List<Message> messages;
    private Integer maxTokens;
    private Double temperature;
    private boolean enableTools;
    private List<String> enabledTools;
}
