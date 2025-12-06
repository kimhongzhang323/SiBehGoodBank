package com.sibehgoodbank.aiagent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ToolResult {
    
    private String toolUseId;
    private String toolName;
    private boolean success;
    private Object result;
    private String error;
    private Map<String, Object> metadata;
}
