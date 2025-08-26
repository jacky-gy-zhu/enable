package com.enable.ai.agents.service;

import com.enable.ai.agents.config.AgentConfig;
import com.enable.ai.agents.dto.AgentRequest;
import com.enable.ai.agents.dto.AgentResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Main agent service that orchestrates AI agent functionality
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AgentService {
    
    private final AgentConfig agentConfig;
    private final McpServerService mcpServerService;
    private final OpenAiService openAiService;
    
    /**
     * Process user request and determine if agent functionality should be triggered
     */
    public AgentResponse processRequest(AgentRequest request) {
        try {
            String sessionId = request.getSessionId() != null ? 
                    request.getSessionId() : UUID.randomUUID().toString();
            
            // Check if agent should be triggered based on keywords
            boolean shouldTriggerAgent = shouldTriggerAgent(request.getUserQuery());
            
            if (shouldTriggerAgent) {
                return processWithAgent(request, sessionId);
            } else {
                return processWithoutAgent(request, sessionId);
            }
            
        } catch (Exception e) {
            log.error("Error processing agent request", e);
            return AgentResponse.builder()
                    .sessionId(request.getSessionId())
                    .success(false)
                    .errorMessage("Internal server error: " + e.getMessage())
                    .timestamp(LocalDateTime.now())
                    .build();
        }
    }
    
    /**
     * Process request with agent functionality
     */
    private AgentResponse processWithAgent(AgentRequest request, String sessionId) {
        log.info("Processing request with agent for session: {}", sessionId);
        
        // Call MCP servers based on user query
        List<AgentResponse.McpServerCall> mcpCalls = mcpServerService.callMcpServers(
                request.getUserQuery(), 
                request.getContext()
        );
        
        // Enhance user query with MCP server results
        String enhancedQuery = buildEnhancedQuery(request.getUserQuery(), mcpCalls);
        
        // Get response from OpenAI with enhanced context
        String aiResponse = openAiService.getChatCompletion(enhancedQuery);
        
        return AgentResponse.builder()
                .sessionId(sessionId)
                .response(aiResponse)
                .agentUsed(true)
                .triggeredAgents(List.of("main-agent"))
                .mcpServerCalls(mcpCalls)
                .metadata(Map.of(
                        "enhanced_query_length", enhancedQuery.length(),
                        "mcp_servers_called", mcpCalls.size()
                ))
                .timestamp(LocalDateTime.now())
                .success(true)
                .build();
    }
    
    /**
     * Process request without agent functionality (direct LLM call)
     */
    private AgentResponse processWithoutAgent(AgentRequest request, String sessionId) {
        log.info("Processing request without agent for session: {}", sessionId);
        
        // Direct OpenAI call
        String aiResponse = openAiService.getChatCompletion(request.getUserQuery());
        
        return AgentResponse.builder()
                .sessionId(sessionId)
                .response(aiResponse)
                .agentUsed(false)
                .triggeredAgents(new ArrayList<>())
                .mcpServerCalls(new ArrayList<>())
                .metadata(Map.of("direct_llm_call", true))
                .timestamp(LocalDateTime.now())
                .success(true)
                .build();
    }
    
    /**
     * Check if agent should be triggered based on keyword analysis
     */
    private boolean shouldTriggerAgent(String userQuery) {
        if (userQuery == null || userQuery.trim().isEmpty()) {
            return false;
        }
        
        String queryLower = userQuery.toLowerCase();
        
        // Check for trigger keywords from configuration
        for (String keyword : agentConfig.getTriggerKeywords()) {
            if (queryLower.contains(keyword.toLowerCase())) {
                log.debug("Agent triggered by keyword: {}", keyword);
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Build enhanced query with MCP server results
     */
    private String buildEnhancedQuery(String originalQuery, List<AgentResponse.McpServerCall> mcpCalls) {
        StringBuilder enhancedQuery = new StringBuilder();
        enhancedQuery.append("User Query: ").append(originalQuery).append("\n\n");
        
        if (!mcpCalls.isEmpty()) {
            enhancedQuery.append("Additional Context from Tools:\n");
            for (AgentResponse.McpServerCall mcpCall : mcpCalls) {
                if (mcpCall.isSuccess()) {
                    enhancedQuery.append("- ").append(mcpCall.getServerName())
                            .append(": ").append(mcpCall.getResult()).append("\n");
                }
            }
            enhancedQuery.append("\n");
        }
        
        enhancedQuery.append("Please provide a comprehensive response based on the user query and any additional context provided above.");
        
        return enhancedQuery.toString();
    }
}
