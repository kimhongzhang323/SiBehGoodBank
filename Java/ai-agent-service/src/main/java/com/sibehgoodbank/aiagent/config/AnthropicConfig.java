package com.sibehgoodbank.aiagent.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "anthropic")
public class AnthropicConfig {
    
    private String apiKey;
    private String apiUrl = "https://api.anthropic.com/v1";
    private String model = "claude-3-sonnet-20240229";
    private int maxTokens = 4096;
    private double temperature = 0.7;
    private int timeoutSeconds = 60;
    private int maxRetries = 3;
    
    // Rate limiting
    private int requestsPerMinute = 60;
    private int tokensPerMinute = 100000;
}
