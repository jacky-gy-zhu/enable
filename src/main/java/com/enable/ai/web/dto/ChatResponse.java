package com.enable.ai.web.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Chat response DTO for web interface
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatResponse {
    
    private String sessionId;
    
    private String conversationId;
    
    private String message;
    
    private String response;
    
    private boolean agentUsed;
    
    private List<String> toolsUsed;
    
    private LocalDateTime timestamp;
    
    private boolean success;
    
    private String errorMessage;
    
    private ResponseMetadata metadata;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ResponseMetadata {
        private int responseTime;
        private String model;
        private int tokensUsed;
        private List<String> mcpServersInvoked;
    }
}
