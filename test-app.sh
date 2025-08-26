#!/bin/bash

echo "Testing the AI Agent Chat API..."

# Test the health endpoint first
echo "1. Testing health endpoint..."
curl -s http://localhost:8080/api/chat/health
echo -e "\n"

# Create a new session
echo "2. Creating new session..."
SESSION_ID=$(curl -s -X POST http://localhost:8080/api/chat/session | tr -d '"')
echo "Session ID: $SESSION_ID"
echo ""

# Test sending a message
echo "3. Testing Chinese message '你好'..."
curl -X POST http://localhost:8080/api/chat/send \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"你好\", \"sessionId\": \"$SESSION_ID\"}" \
  -s | python3 -m json.tool 2>/dev/null || echo "Response received but not valid JSON"

echo -e "\n"

echo "4. Testing English message 'Hello'..."
curl -X POST http://localhost:8080/api/chat/send \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"Hello\", \"sessionId\": \"$SESSION_ID\"}" \
  -s | python3 -m json.tool 2>/dev/null || echo "Response received but not valid JSON"

echo -e "\n"

echo "5. Testing agent trigger message 'Please help me run a search'..."
curl -X POST http://localhost:8080/api/chat/send \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"Please help me run a search\", \"sessionId\": \"$SESSION_ID\"}" \
  -s | python3 -m json.tool 2>/dev/null || echo "Response received but not valid JSON"
