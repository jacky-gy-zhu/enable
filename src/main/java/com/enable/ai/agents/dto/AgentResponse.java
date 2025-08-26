package com.enable.ai.agents.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Response DTO for agent operations
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentResponse {
    
    private String sessionId;
    
    private String response;
    
    private boolean agentUsed;
    
    private List<String> triggeredAgents;
    
    private List<McpServerCall> mcpServerCalls;
    
    private Map<String, Object> metadata;
    
    private LocalDateTime timestamp;
    
    private boolean success;
    
    private String errorMessage;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class McpServerCall {
        private String serverName;
        private String endpoint;
        private String action;
        private Map<String, Object> parameters;
        private Object result;
        private boolean success;
    }
}
