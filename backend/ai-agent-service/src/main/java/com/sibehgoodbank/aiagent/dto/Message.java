package com.sibehgoodbank.aiagent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Message {
    
    private String role; // "user", "assistant"
    private String content;
}
