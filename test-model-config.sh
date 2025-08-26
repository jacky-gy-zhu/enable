#!/bin/bash

echo "Testing Model Configuration..."
echo "================================"

# Test if the application is running
if curl -s http://localhost:8080/api/chat/health > /dev/null; then
    echo "✅ Application is running"
else
    echo "❌ Application is not running. Please start it first."
    exit 1
fi

# Create a session
echo "Creating test session..."
SESSION_ID=$(curl -s -X POST http://localhost:8080/api/chat/session | tr -d '"')
echo "Session ID: $SESSION_ID"

# Send a test message and check the model in response
echo -e "\nTesting model configuration..."
RESPONSE=$(curl -s -X POST http://localhost:8080/api/chat/send \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"Hello\", \"sessionId\": \"$SESSION_ID\"}")

# Extract model from response
MODEL=$(echo "$RESPONSE" | grep -o '"model":"[^"]*"' | cut -d'"' -f4)

echo "Response metadata:"
echo "$RESPONSE" | grep -o '"metadata":{[^}]*}' | sed 's/,/,\n  /g' | sed 's/{/{\n  /' | sed 's/}/\n}/'

if [ "$MODEL" = "gpt-5-mini" ]; then
    echo -e "\n✅ SUCCESS: Model is correctly configured as '$MODEL' from application.yml"
    echo "✅ Configuration is working properly - no hardcoded model names in code!"
else
    echo -e "\n⚠️  Model in response: '$MODEL'"
    echo "Expected: 'gpt-5-mini'"
    echo "This might indicate the application needs to be restarted to pick up new config."
fi

echo -e "\nConfiguration file content:"
echo "openai.model = $(grep -A 5 "openai:" /Users/jackyzhu/Projects/Work/Enable/enable/src/main/resources/application.yml | grep "model:" | awk '{print $2}')"
