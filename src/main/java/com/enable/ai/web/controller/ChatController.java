package com.enable.ai.web.controller;

import com.enable.ai.agents.dto.AgentRequest;
import com.enable.ai.agents.dto.AgentResponse;
import com.enable.ai.agents.service.AgentService;
import com.enable.ai.agents.config.OpenAiConfig;
import com.enable.ai.web.dto.ChatRequest;
import com.enable.ai.web.dto.ChatResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * REST controller for chat functionality
 */
@Slf4j
@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
@Validated
@CrossOrigin(origins = "*") // Enable CORS for frontend separation
public class ChatController {
    
    private final AgentService agentService;
    private final OpenAiConfig openAiConfig;
    
    /**
     * Send a chat message and get AI response
     */
    @PostMapping("/send")
    public ResponseEntity<ChatResponse> sendMessage(@Valid @RequestBody ChatRequest request) {
        long startTime = System.currentTimeMillis();
        
        try {
            log.info("Received chat request for session: {}", request.getSessionId());
            
            // Convert to agent request
            AgentRequest agentRequest = new AgentRequest();
            agentRequest.setUserQuery(request.getMessage());
            agentRequest.setSessionId(request.getSessionId());
            
            // Process with agent service
            AgentResponse agentResponse = agentService.processRequest(agentRequest);
            
            // Convert to chat response
            ChatResponse chatResponse = convertToWebResponse(request, agentResponse, startTime);
            
            return ResponseEntity.ok(chatResponse);
            
        } catch (Exception e) {
            log.error("Error processing chat request", e);
            
            ChatResponse errorResponse = ChatResponse.builder()
                    .sessionId(request.getSessionId())
                    .conversationId(request.getConversationId())
                    .message(request.getMessage())
                    .success(false)
                    .errorMessage("Failed to process your message. Please try again.")
                    .timestamp(LocalDateTime.now())
                    .build();
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * Get chat history for a session (placeholder for future implementation)
     */
    @GetMapping("/history/{sessionId}")
    public ResponseEntity<List<ChatResponse>> getChatHistory(@PathVariable String sessionId) {
        // This would typically fetch from a database
        // For now, return empty list
        return ResponseEntity.ok(List.of());
    }
    
    /**
     * Create a new chat session
     */
    @PostMapping("/session")
    public ResponseEntity<String> createSession() {
        String sessionId = UUID.randomUUID().toString();
        log.info("Created new chat session: {}", sessionId);
        return ResponseEntity.ok(sessionId);
    }
    
    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Chat service is healthy");
    }
    
    /**
     * Convert agent response to web response format
     */
    private ChatResponse convertToWebResponse(ChatRequest request, AgentResponse agentResponse, long startTime) {
        int responseTime = (int) (System.currentTimeMillis() - startTime);
        
        List<String> toolsUsed = agentResponse.getMcpServerCalls() != null ?
                agentResponse.getMcpServerCalls().stream()
                        .map(AgentResponse.McpServerCall::getServerName)
                        .collect(Collectors.toList()) : 
                List.of();
        
        List<String> mcpServersInvoked = agentResponse.getMcpServerCalls() != null ?
                agentResponse.getMcpServerCalls().stream()
                        .filter(AgentResponse.McpServerCall::isSuccess)
                        .map(AgentResponse.McpServerCall::getServerName)
                        .collect(Collectors.toList()) :
                List.of();
        
        ChatResponse.ResponseMetadata metadata = ChatResponse.ResponseMetadata.builder()
                .responseTime(responseTime)
                .model(openAiConfig.getModel()) // Dynamic from config
                .tokensUsed(0) // Would need to be calculated from OpenAI response
                .mcpServersInvoked(mcpServersInvoked)
                .build();
        
        return ChatResponse.builder()
                .sessionId(agentResponse.getSessionId())
                .conversationId(request.getConversationId())
                .message(request.getMessage())
                .response(agentResponse.getResponse())
                .agentUsed(agentResponse.isAgentUsed())
                .toolsUsed(toolsUsed)
                .timestamp(agentResponse.getTimestamp())
                .success(agentResponse.isSuccess())
                .errorMessage(agentResponse.getErrorMessage())
                .metadata(metadata)
                .build();
    }
}
