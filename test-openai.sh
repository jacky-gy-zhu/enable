#!/bin/bash

# Test OpenAI API Key
API_KEY="sk-OO7p1CfMcRawUDr1t-kNDpLaQPEhdM_1vDBqoQRc5VT3BlbkFJHkjyAytcqU3GvHIqYWBILYVfc5nWo3_XkHvSZ1iT4A"

echo "Testing OpenAI API connection..."
echo "API Key: ${API_KEY:0:10}...${API_KEY: -10}"

# Test with a simple request
curl -X POST https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }' \
  --max-time 30 \
  --silent \
  --show-error \
  --write-out "\nHTTP Status: %{http_code}\n"
