// Chat application JavaScript - Claude.ai inspired

class ChatApp {
    constructor() {
        this.apiBaseUrl = 'http://localhost:8080/api'; // Configure this for your deployment
        this.sessionId = null;
        this.conversationId = null;
        this.isLoading = false;
        
        this.init();
    }
    
    init() {
        this.createSession();
        this.setupEventListeners();
        this.autoResizeTextarea();
    }
    
    setupEventListeners() {
        // Send button click
        document.getElementById('sendButton').addEventListener('click', () => this.sendMessage());
        
        // Enter key handling
        document.getElementById('messageInput').addEventListener('keydown', (e) => this.handleKeyDown(e));
        
        // Auto-resize textarea
        document.getElementById('messageInput').addEventListener('input', () => this.autoResizeTextarea());
    }
    
    async createSession() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/chat/session`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                this.sessionId = await response.text();
                this.sessionId = this.sessionId.replace(/"/g, ''); // Remove quotes
                document.getElementById('sessionId').textContent = this.sessionId.substring(0, 8) + '...';
                console.log('Session created:', this.sessionId);
            } else {
                console.error('Failed to create session');
                this.showError('Failed to create chat session');
            }
        } catch (error) {
            console.error('Error creating session:', error);
            this.showError('Network error while creating session');
        }
    }
    
    handleKeyDown(event) {
        const textarea = event.target;
        
        if (event.key === 'Enter') {
            if (event.shiftKey) {
                // Shift+Enter: new line
                return true;
            } else {
                // Enter: send message
                event.preventDefault();
                this.sendMessage();
                return false;
            }
        }
        
        return true;
    }
    
    autoResizeTextarea() {
        const textarea = document.getElementById('messageInput');
        textarea.style.height = 'auto';
        textarea.style.height = Math.min(textarea.scrollHeight, 128) + 'px';
    }
    
    async sendMessage() {
        const messageInput = document.getElementById('messageInput');
        const message = messageInput.value.trim();
        
        if (!message || this.isLoading) {
            return;
        }
        
        // Clear input
        messageInput.value = '';
        this.autoResizeTextarea();
        
        // Add user message to chat
        this.addMessageToChat('user', message);
        
        // Show typing indicator
        this.showTypingIndicator();
        
        try {
            this.setLoading(true);
            
            const response = await fetch(`${this.apiBaseUrl}/chat/send`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: message,
                    sessionId: this.sessionId,
                    conversationId: this.conversationId
                })
            });
            
            const data = await response.json();
            
            // Remove typing indicator
            this.hideTypingIndicator();
            
            if (response.ok && data.success) {
                // Add assistant response to chat
                this.addMessageToChat('assistant', data.response, {
                    agentUsed: data.agentUsed,
                    toolsUsed: data.toolsUsed,
                    metadata: data.metadata
                });
            } else {
                this.showError(data.errorMessage || 'Failed to get response');
            }
            
        } catch (error) {
            console.error('Error sending message:', error);
            this.hideTypingIndicator();
            this.showError('Network error. Please check your connection and try again.');
        } finally {
            this.setLoading(false);
        }
    }
    
    addMessageToChat(type, content, metadata = {}) {
        const messagesContainer = document.getElementById('messagesContainer');
        
        // Remove welcome message if it exists
        const welcomeMessage = messagesContainer.querySelector('.welcome-message');
        if (welcomeMessage) {
            welcomeMessage.remove();
        }
        
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}`;
        
        const avatarDiv = document.createElement('div');
        avatarDiv.className = 'message-avatar';
        
        if (type === 'user') {
            avatarDiv.innerHTML = '<i class="fas fa-user"></i>';
        } else {
            avatarDiv.innerHTML = '<i class="fas fa-robot"></i>';
        }
        
        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';
        
        // Format content (handle line breaks)
        const formattedContent = this.formatMessageContent(content);
        contentDiv.innerHTML = formattedContent;
        
        // Add metadata for assistant messages
        if (type === 'assistant' && metadata) {
            const metaDiv = document.createElement('div');
            metaDiv.className = 'message-meta';
            
            let metaContent = '';
            
            if (metadata.agentUsed) {
                metaContent += '<span class="agent-indicator"><i class="fas fa-robot me-1"></i>Agent</span>';
            }
            
            if (metadata.toolsUsed && metadata.toolsUsed.length > 0) {
                metaContent += '<div class="tools-used mt-2">';
                metaContent += '<i class="fas fa-tools me-1"></i>Tools used: ';
                metadata.toolsUsed.forEach(tool => {
                    metaContent += `<span class="tool-badge">${tool}</span>`;
                });
                metaContent += '</div>';
            }
            
            if (metadata.metadata) {
                metaContent += `<div class="mt-1"><small>Response time: ${metadata.metadata.responseTime}ms</small></div>`;
            }
            
            if (metaContent) {
                metaDiv.innerHTML = metaContent;
                contentDiv.appendChild(metaDiv);
            }
        }
        
        messageDiv.appendChild(avatarDiv);
        messageDiv.appendChild(contentDiv);
        
        messagesContainer.appendChild(messageDiv);
        
        // Scroll to bottom
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
    
    formatMessageContent(content) {
        // Basic formatting: convert line breaks to <br> tags
        return content.replace(/\n/g, '<br>');
    }
    
    showTypingIndicator() {
        const messagesContainer = document.getElementById('messagesContainer');
        
        const typingDiv = document.createElement('div');
        typingDiv.className = 'message assistant typing-message';
        typingDiv.id = 'typingIndicator';
        
        typingDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-robot"></i>
            </div>
            <div class="message-content">
                <div class="typing-indicator">
                    AI is thinking
                    <div class="typing-dots">
                        <span></span>
                        <span></span>
                        <span></span>
                    </div>
                </div>
            </div>
        `;
        
        messagesContainer.appendChild(typingDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
    
    hideTypingIndicator() {
        const typingIndicator = document.getElementById('typingIndicator');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }
    
    showError(message) {
        const messagesContainer = document.getElementById('messagesContainer');
        
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.innerHTML = `<i class="fas fa-exclamation-triangle me-2"></i>${message}`;
        
        messagesContainer.appendChild(errorDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
        
        // Remove error message after 5 seconds
        setTimeout(() => {
            if (errorDiv.parentNode) {
                errorDiv.remove();
            }
        }, 5000);
    }
    
    setLoading(loading) {
        this.isLoading = loading;
        const sendButton = document.getElementById('sendButton');
        const messageInput = document.getElementById('messageInput');
        
        if (loading) {
            sendButton.disabled = true;
            sendButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
            messageInput.disabled = true;
        } else {
            sendButton.disabled = false;
            sendButton.innerHTML = '<i class="fas fa-paper-plane"></i>';
            messageInput.disabled = false;
            messageInput.focus();
        }
    }
    
    sendExampleMessage(message) {
        const messageInput = document.getElementById('messageInput');
        messageInput.value = message;
        this.autoResizeTextarea();
        this.sendMessage();
    }
    
    startNewChat() {
        // Clear current chat
        const messagesContainer = document.getElementById('messagesContainer');
        messagesContainer.innerHTML = `
            <div class="welcome-message">
                <div class="text-center py-5">
                    <i class="fas fa-robot fa-3x text-primary mb-3"></i>
                    <h4>Welcome to AI Agent Chat</h4>
                    <p class="text-muted">I'm your AI assistant with access to powerful tools and knowledge. How can I help you today?</p>
                    <div class="example-prompts">
                        <button class="btn btn-outline-primary btn-sm me-2 mb-2" onclick="chatApp.sendExampleMessage('Help me search for information about artificial intelligence')">
                            Search Information
                        </button>
                        <button class="btn btn-outline-primary btn-sm me-2 mb-2" onclick="chatApp.sendExampleMessage('Can you help me organize my files?')">
                            File Operations
                        </button>
                        <button class="btn btn-outline-primary btn-sm mb-2" onclick="chatApp.sendExampleMessage('Run a database query for me')">
                            Database Query
                        </button>
                    </div>
                </div>
            </div>
        `;
        
        // Create new session
        this.createSession();
        
        // Focus input
        document.getElementById('messageInput').focus();
    }
}

// Global functions for HTML onclick handlers
function sendMessage() {
    if (window.chatApp) {
        window.chatApp.sendMessage();
    }
}

function sendExampleMessage(message) {
    if (window.chatApp) {
        window.chatApp.sendExampleMessage(message);
    }
}

function startNewChat() {
    if (window.chatApp) {
        window.chatApp.startNewChat();
    }
}

function handleKeyDown(event) {
    if (window.chatApp) {
        return window.chatApp.handleKeyDown(event);
    }
    return true;
}

// Initialize chat app when page loads
document.addEventListener('DOMContentLoaded', function() {
    window.chatApp = new ChatApp();
});

// Handle page visibility changes
document.addEventListener('visibilitychange', function() {
    if (!document.hidden && window.chatApp) {
        // Page became visible, you could check connection status here
        const statusIndicator = document.getElementById('statusIndicator');
        if (statusIndicator) {
            statusIndicator.innerHTML = '<i class="fas fa-circle text-success"></i><span class="ms-1">Online</span>';
        }
    }
});
