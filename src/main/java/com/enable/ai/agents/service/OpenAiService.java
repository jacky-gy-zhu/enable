package com.enable.ai.agents.service;

import com.enable.ai.agents.config.OpenAiConfig;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;


import java.time.Duration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service for OpenAI API integration
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OpenAiService {
    
    private final OpenAiConfig openAiConfig;
    private final WebClient webClient;
    private final ObjectMapper objectMapper;
    
    /**
     * Get chat completion from OpenAI
     */
    public String getChatCompletion(String message) {
        try {
            // Prepare request payload
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", openAiConfig.getModel());
            requestBody.put("max_tokens", openAiConfig.getMaxTokens());
            requestBody.put("temperature", openAiConfig.getTemperature());
            
            // Prepare messages
            Map<String, String> userMessage = new HashMap<>();
            userMessage.put("role", "user");
            userMessage.put("content", message);
            
            requestBody.put("messages", List.of(userMessage));
            
            // Make API call
            String response = webClient.post()
                    .uri(openAiConfig.getApiUrl() + "/chat/completions")
                    .header("Authorization", "Bearer " + openAiConfig.getApiKey())
                    .header("Content-Type", "application/json")
                    .bodyValue(requestBody)
                    .retrieve()
                    .onStatus(status -> status.is4xxClientError(), clientResponse -> {
                        return clientResponse.bodyToMono(String.class)
                                .map(body -> new RuntimeException("Client error: " + clientResponse.statusCode() + " - " + body));
                    })
                    .onStatus(status -> status.is5xxServerError(), clientResponse -> {
                        return clientResponse.bodyToMono(String.class)
                                .map(body -> new RuntimeException("Server error: " + clientResponse.statusCode() + " - " + body));
                    })
                    .bodyToMono(String.class)
                    .timeout(Duration.ofSeconds(60))
                    .block();
            
            // Parse response and extract content
            return extractContentFromResponse(response);
            
        } catch (Exception e) {
            log.error("Error calling OpenAI API: {}", e.getMessage(), e);
            if (e.getMessage().contains("401") || e.getMessage().contains("Unauthorized")) {
                return "Authentication failed. Please check your OpenAI API key configuration.";
            } else if (e.getMessage().contains("400") || e.getMessage().contains("Bad Request")) {
                return "Invalid request format. Please check the model configuration.";
            } else if (e.getMessage().contains("404")) {
                return "Model not found. Please check if the specified model exists.";
            } else {
                return "I apologize, but I'm currently unable to process your request due to a technical issue: " + e.getMessage();
            }
        }
    }
    
    /**
     * Extract content from OpenAI API response
     */
    private String extractContentFromResponse(String response) {
        try {
            JsonNode jsonResponse = objectMapper.readTree(response);
            JsonNode choices = jsonResponse.get("choices");
            
            if (choices != null && choices.isArray() && choices.size() > 0) {
                JsonNode firstChoice = choices.get(0);
                JsonNode message = firstChoice.get("message");
                
                if (message != null) {
                    JsonNode content = message.get("content");
                    if (content != null) {
                        return content.asText();
                    }
                }
            }
            
            log.warn("Unexpected response format from OpenAI API: {}", response);
            return "I received an unexpected response format. Please try again.";
            
        } catch (Exception e) {
            log.error("Error parsing OpenAI response", e);
            return "Error processing the AI response. Please try again.";
        }
    }
}
