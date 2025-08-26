package com.enable.config;

import lombok.Data;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import java.io.File;

/**
 * Simple logging configuration helper
 */
@Data
@Component
public class LoggingConfig {
    
    /**
     * Default log file path
     */
    private String filePath = "./logs/ai-agent-system.log";
    
    @PostConstruct
    public void init() {
        // Create log directory if it doesn't exist
        String logPath = System.getProperty("LOG_FILE_PATH", filePath);
        File logFile = new File(logPath);
        File logDir = logFile.getParentFile();
        if (logDir != null && !logDir.exists()) {
            boolean created = logDir.mkdirs();
            if (created) {
                System.out.println("Created log directory: " + logDir.getAbsolutePath());
            }
        }
    }
}
