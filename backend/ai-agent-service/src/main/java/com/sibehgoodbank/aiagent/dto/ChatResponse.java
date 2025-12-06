package com.sibehgoodbank.aiagent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatResponse {
    
    private String id;
    private String model;
    private String content;
    private String stopReason;
    private List<ToolCall> toolCalls;
    private Integer inputTokens;
    private Integer outputTokens;
}
