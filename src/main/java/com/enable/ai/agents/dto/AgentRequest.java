package com.enable.ai.agents.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import java.util.Map;

/**
 * Request DTO for agent operations
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AgentRequest {
    
    @NotBlank(message = "User query cannot be empty")
    private String userQuery;
    
    private String sessionId;
    
    private Map<String, Object> context;
    
    private String preferredAgent;
}
