#!/bin/bash

echo "Testing Different OpenAI Models"
echo "================================"

API_KEY="sk-OO7p1CfMcRawUDr1t-kNDpLaQPEhdM_1vDBqoQRc5VT3BlbkFJHkjyAytcqU3GvHIqYWBILYVfc5nWo3_XkHvSZ1iT4A"

# Array of models to test
MODELS=("gpt-3.5-turbo" "gpt-4" "gpt-4-turbo" "gpt-4o" "gpt-4o-mini" "gpt-5-mini")

echo "Testing models with OpenAI API to find which ones are available..."
echo ""

for model in "${MODELS[@]}"; do
    echo "Testing model: $model"
    
    response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d "{
        \"model\": \"$model\",
        \"messages\": [{\"role\": \"user\", \"content\": \"你好\"}],
        \"max_tokens\": 10
      }" \
      --max-time 30)
    
    # Check if the response contains an error
    if echo "$response" | grep -q '"error"'; then
        error_type=$(echo "$response" | grep -o '"type":"[^"]*"' | cut -d'"' -f4)
        error_message=$(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        echo "  ❌ Failed: $error_type - $error_message"
    else
        # Extract the actual model used from response
        actual_model=$(echo "$response" | grep -o '"model":"[^"]*"' | cut -d'"' -f4)
        content=$(echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4)
        echo "  ✅ Success: Model '$actual_model' responded with: '$content'"
    fi
    echo ""
done

echo "Recommendation:"
echo "Use 'gpt-3.5-turbo' as it's reliable and cost-effective"
echo "Or 'gpt-4' for better quality responses"
echo ""
echo "Update your application.yml with a working model from the list above."
