#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if API key is set
if [ -z "$N8N_API_KEY" ]; then
    echo "Error: N8N_API_KEY not set in .env file"
    exit 1
fi

# Configuration
WORKFLOW_URL="https://raw.githubusercontent.com/alidarvishi14/n8n-telegram-echo-bot/master/workflows/telegram-echo-bot.json"

echo "Fetching workflow from GitHub..."
RAW_WORKFLOW=$(curl -s "$WORKFLOW_URL")

# Clean up the workflow JSON - remove fields that n8n API doesn't accept
# Keep only the fields that n8n API accepts: name, nodes, connections, settings
WORKFLOW_JSON=$(echo "$RAW_WORKFLOW" | jq '{name: .name, nodes: .nodes, connections: .connections, settings: (.settings // {})}')

# Check if workflow exists (by name)
WORKFLOW_NAME=$(echo "$WORKFLOW_JSON" | jq -r '.name')
echo "Workflow name: $WORKFLOW_NAME"

# Get existing workflows
echo "Checking for existing workflow..."
EXISTING_WORKFLOWS=$(curl -s -X GET "$N8N_URL/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY")

# Check if workflow already exists
WORKFLOW_ID=$(echo "$EXISTING_WORKFLOWS" | jq -r ".data[] | select(.name == \"$WORKFLOW_NAME\") | .id")

if [ -n "$WORKFLOW_ID" ]; then
    echo "Workflow exists with ID: $WORKFLOW_ID"
    echo "Updating workflow..."
    
    # Update existing workflow
    RESPONSE=$(curl -s -X PUT "$N8N_URL/workflows/$WORKFLOW_ID" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$WORKFLOW_JSON")
    
    echo "Workflow updated!"
else
    echo "Creating new workflow..."
    
    # Create new workflow
    RESPONSE=$(curl -s -X POST "$N8N_URL/workflows" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$WORKFLOW_JSON")
    
    WORKFLOW_ID=$(echo "$RESPONSE" | jq -r '.id')
    if [ "$WORKFLOW_ID" = "null" ]; then
        # Try alternative response format
        WORKFLOW_ID=$(echo "$RESPONSE" | jq -r '.data.id')
    fi
    echo "Workflow created with ID: $WORKFLOW_ID"
fi

# Only activate if we have a valid workflow ID
if [ -n "$WORKFLOW_ID" ] && [ "$WORKFLOW_ID" != "null" ]; then
    echo "Activating workflow..."
    curl -s -X POST "$N8N_URL/workflows/$WORKFLOW_ID/activate" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" > /dev/null
    
    echo "✅ Workflow synced and activated successfully!"
else
    echo "❌ Error: Could not get workflow ID. Response was:"
    echo "$RESPONSE" | jq
fi