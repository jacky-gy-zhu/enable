package com.enable.ai.agents.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jakarta.annotation.PostConstruct;

/**
 * Configuration properties for OpenAI integration
 */
@Data
@Component
@ConfigurationProperties(prefix = "openai")
public class OpenAiConfig {
    
    private String apiKey;
    
    private String apiUrl;
    
    private String model;
    
    private Integer maxTokens = 1000;
    
    private Double temperature = 0.7;
    
    /**
     * Validate configuration after properties are loaded
     */
    @PostConstruct
    public void validateConfig() {
        if (!StringUtils.hasText(model)) {
            throw new IllegalStateException("OpenAI model must be configured in application.yml");
        }
        if (!StringUtils.hasText(apiKey)) {
            throw new IllegalStateException("OpenAI API key must be configured");
        }
        if (!StringUtils.hasText(apiUrl)) {
            throw new IllegalStateException("OpenAI API URL must be configured");
        }
    }
}
