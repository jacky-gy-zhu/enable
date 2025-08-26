package com.enable.ai.agents.service;

import com.enable.ai.agents.config.AgentConfig;
import com.enable.ai.agents.dto.AgentResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;


import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Service for dynamic MCP server selection and communication
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class McpServerService {
    
    private final AgentConfig agentConfig;
    private final WebClient webClient;

    
    /**
     * Dynamically select and call appropriate MCP servers based on user query
     */
    public List<AgentResponse.McpServerCall> callMcpServers(String userQuery, Map<String, Object> context) {
        List<AgentResponse.McpServerCall> mcpCalls = new ArrayList<>();
        
        // Analyze user query to determine which MCP servers to call
        List<String> selectedServers = selectMcpServers(userQuery);
        
        for (String serverName : selectedServers) {
            AgentConfig.McpServerConfig serverConfig = agentConfig.getMcpServers().get(serverName);
            if (serverConfig != null) {
                try {
                    AgentResponse.McpServerCall mcpCall = callMcpServer(serverConfig, userQuery, context);
                    mcpCalls.add(mcpCall);
                } catch (Exception e) {
                    log.error("Failed to call MCP server: {}", serverName, e);
                    mcpCalls.add(AgentResponse.McpServerCall.builder()
                            .serverName(serverName)
                            .endpoint(serverConfig.getEndpoint())
                            .success(false)
                            .result("Error: " + e.getMessage())
                            .build());
                }
            }
        }
        
        return mcpCalls;
    }
    
    /**
     * Select appropriate MCP servers based on user query content
     */
    private List<String> selectMcpServers(String userQuery) {
        List<String> selectedServers = new ArrayList<>();
        String queryLower = userQuery.toLowerCase();
        
        // File system operations
        if (containsAny(queryLower, "file", "directory", "folder", "path", "save", "read", "write", "delete")) {
            selectedServers.add("filesystem");
        }
        
        // Database operations
        if (containsAny(queryLower, "database", "query", "sql", "table", "select", "insert", "update")) {
            selectedServers.add("database");
        }
        
        // Search operations
        if (containsAny(queryLower, "search", "find", "lookup", "web", "google", "document")) {
            selectedServers.add("search");
        }
        
        // If no specific server is identified, default to search
        if (selectedServers.isEmpty()) {
            selectedServers.add("search");
        }
        
        return selectedServers;
    }
    
    /**
     * Call a specific MCP server
     */
    private AgentResponse.McpServerCall callMcpServer(
            AgentConfig.McpServerConfig serverConfig, 
            String userQuery, 
            Map<String, Object> context) {
        
        try {
            // Prepare request payload
            Map<String, Object> requestPayload = Map.of(
                    "query", userQuery,
                    "context", context != null ? context : Map.of(),
                    "capabilities", serverConfig.getCapabilities()
            );
            
            // Make HTTP call to MCP server
            String response = webClient.post()
                    .uri(serverConfig.getEndpoint() + "/execute")
                    .bodyValue(requestPayload)
                    .retrieve()
                    .bodyToMono(String.class)
                    .timeout(Duration.ofSeconds(30))
                    .block();
            
            return AgentResponse.McpServerCall.builder()
                    .serverName(serverConfig.getName())
                    .endpoint(serverConfig.getEndpoint())
                    .action("execute")
                    .parameters(requestPayload)
                    .result(response)
                    .success(true)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error calling MCP server {}: {}", serverConfig.getName(), e.getMessage());
            throw new RuntimeException("Failed to call MCP server: " + serverConfig.getName(), e);
        }
    }
    
    /**
     * Check if text contains any of the given keywords
     */
    private boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
