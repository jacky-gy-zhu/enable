# AI Agent System

A SpringBoot-based AI chatbot system that dynamically integrates with MCP (Model Context Protocol) servers and OpenAI's language models.

## Features

- **Dynamic Agent Triggering**: Agents are triggered based on specific keywords in user queries
- **MCP Server Integration**: Dynamically selects and calls appropriate MCP servers based on query content
- **OpenAI Integration**: Uses OpenAI's API for natural language processing
- **Modern Web UI**: Claude.ai-inspired chat interface with Bootstrap
- **Frontend-Backend Separation**: Static HTML/CSS/JS can be deployed independently

## Architecture

```
com.enable.ai.agents/     # AI Agent core functionality
├── dto/                  # Data Transfer Objects
├── config/              # Configuration classes
└── service/             # Business logic services

com.enable.ai.web/       # Web interface controllers
├── dto/                 # Web-specific DTOs
├── controller/          # REST controllers
└── config/             # Web configuration
```

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- OpenAI API Key
- MCP servers (optional, for full functionality)

## Setup Instructions

### 1. Clone and Build

```bash
git clone <repository-url>
cd enable
mvn clean install
```

### 2. Configure OpenAI API

Set your OpenAI API key in one of the following ways:

**Option A: Environment Variable**
```bash
export OPENAI_API_KEY=your-openai-api-key-here
```

**Option B: application.yml**
```yaml
openai:
  api-key: your-openai-api-key-here
```

### 3. Configure MCP Servers (Optional)

Update `src/main/resources/application.yml` to configure your MCP servers:

```yaml
agent:
  mcp-servers:
    filesystem:
      name: "filesystem"
      endpoint: "http://localhost:3001"
      capabilities: ["file_operations", "directory_listing"]
    database:
      name: "database"
      endpoint: "http://localhost:3002"
      capabilities: ["query_execution", "schema_analysis"]
    search:
      name: "search"
      endpoint: "http://localhost:3003"
      capabilities: ["web_search", "document_search"]
```

### 4. Run the Application

```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

### 5. Access the Chat Interface

Open your browser and navigate to:
```
http://localhost:8080/index.html
```

## API Endpoints

### Chat API
- `POST /api/chat/send` - Send a message to the AI
- `POST /api/chat/session` - Create a new chat session
- `GET /api/chat/health` - Health check
- `GET /api/chat/history/{sessionId}` - Get chat history (placeholder)

### Example API Usage

```bash
# Create a session
curl -X POST http://localhost:8080/api/chat/session

# Send a message
curl -X POST http://localhost:8080/api/chat/send \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Help me search for information about AI",
    "sessionId": "your-session-id"
  }'
```

## Agent Triggering

The system automatically triggers AI agents when user queries contain specific keywords:

- `agent`
- `tool`
- `function`
- `execute`
- `run`
- `perform`

When triggered, the system:
1. Analyzes the query to select appropriate MCP servers
2. Calls the relevant MCP servers
3. Enhances the query with MCP server results
4. Sends the enhanced query to OpenAI

## MCP Server Selection Logic

The system dynamically selects MCP servers based on query content:

- **Filesystem**: Keywords like "file", "directory", "folder", "save", "read"
- **Database**: Keywords like "database", "query", "sql", "table"
- **Search**: Keywords like "search", "find", "web", "google"

## Frontend Deployment

The frontend is designed for complete separation from the backend. To deploy the frontend independently:

1. Copy the contents of `src/main/resources/static/` to your web server
2. Update the `apiBaseUrl` in `js/chat.js` to point to your backend
3. Ensure CORS is properly configured on the backend

## Configuration

### Logging Configuration

The system supports flexible logging configuration that can be customized through configuration files or environment variables.

**Quick Setup:**
```bash
# Set log file path
export LOG_FILE_PATH=./logs/ai-agent-system.log

# Set log level (TRACE, DEBUG, INFO, WARN, ERROR)
export LOG_LEVEL=DEBUG

# Control console/file output
export LOG_ENABLE_CONSOLE=true
export LOG_ENABLE_FILE=true
```

**Configuration in application.yml:**
```yaml
app:
  logging:
    file-path: ${LOG_FILE_PATH:./logs/ai-agent-system.log}
    level: ${LOG_LEVEL:DEBUG}
    max-file-size: ${LOG_MAX_FILE_SIZE:50MB}
    max-history: ${LOG_MAX_HISTORY:30}
    enable-console: ${LOG_ENABLE_CONSOLE:true}
    enable-file: ${LOG_ENABLE_FILE:true}
```

For detailed logging configuration, see [LOGGING_CONFIGURATION.md](LOGGING_CONFIGURATION.md).

### Model Configuration

The system is designed to be flexible with different AI models. You can configure the OpenAI model in the `application.yml` file:

```yaml
openai:
dou  model: gpt-3.5-turbo  # Change this to your preferred model
```

**Supported Models:**
- `gpt-4` - Most capable model, higher cost
- `gpt-4-turbo` - Faster GPT-4 variant  
- `gpt-4o` - Optimized GPT-4 model
- `gpt-4o-mini` - Smaller, faster GPT-4o variant
- `gpt-3.5-turbo` - Balanced performance and cost (recommended for development)

**Note:** The model name you specify here will be used throughout the entire application automatically. No code changes are required when switching models.

### Key Configuration Properties

```yaml
# Server configuration
server:
  port: 8080
  servlet:
    context-path: /api

# OpenAI configuration
openai:
  api-key: ${OPENAI_API_KEY}
  model: gpt-5-mini  # Available models: gpt-4, gpt-3.5-turbo, gpt-5-mini, etc.
  max-tokens: 1000   # Maximum tokens in response
  temperature: 0.7   # Creativity level (0.0-1.0)

# Agent configuration
agent:
  trigger-keywords:
    - "agent"
    - "tool"
    # ... more keywords
  
  mcp-servers:
    # MCP server configurations
```

## Development

### Adding New MCP Servers

1. Add server configuration to `application.yml`
2. Update the selection logic in `McpServerService.selectMcpServers()`
3. Optionally add server-specific handling in `McpServerService.callMcpServer()`

### Customizing Agent Behavior

- Modify trigger keywords in `application.yml`
- Update selection logic in `AgentService.shouldTriggerAgent()`
- Customize query enhancement in `AgentService.buildEnhancedQuery()`

### Frontend Customization

- Styles: Edit `css/chat.css`
- Behavior: Modify `js/chat.js`
- Layout: Update `index.html`

## Troubleshooting

### Common Issues

1. **OpenAI API Errors**: Verify your API key and check rate limits
2. **MCP Server Connectivity**: Ensure MCP servers are running and accessible
3. **CORS Issues**: Check CORS configuration in `WebConfig.java`
4. **Session Creation Failed**: Check server logs for detailed error messages

### Logging

Enable debug logging by setting:
```yaml
logging:
  level:
    com.enable: DEBUG
```

## License

[Your License Here]

## Contributing

[Contributing Guidelines Here]
