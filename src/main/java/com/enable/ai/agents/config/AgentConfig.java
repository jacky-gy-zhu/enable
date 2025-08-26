package com.enable.ai.agents.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * Configuration properties for AI agents
 */
@Data
@Component
@ConfigurationProperties(prefix = "agent")
public class AgentConfig {
    
    private List<String> triggerKeywords;
    
    private Map<String, McpServerConfig> mcpServers;
    
    @Data
    public static class McpServerConfig {
        private String name;
        private String endpoint;
        private List<String> capabilities;
    }
}
