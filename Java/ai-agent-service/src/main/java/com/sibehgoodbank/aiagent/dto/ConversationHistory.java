package com.sibehgoodbank.aiagent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConversationHistory {
    
    private UUID sessionId;
    private UUID userId;
    private List<Message> messages;
    private List<ToolResult> toolResults;
    private LocalDateTime createdAt;
    private LocalDateTime lastUpdatedAt;
    private String status; // ACTIVE, COMPLETED, EXPIRED
    private int totalTokensUsed;
    private String summary;
}
