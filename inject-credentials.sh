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

# Function to create or update a credential
create_or_update_credential() {
    local CRED_NAME=$1
    local CRED_TYPE=$2
    local CRED_DATA=$3
    
    echo "Processing credential: $CRED_NAME (type: $CRED_TYPE)"
    
    # Check if credential already exists
    EXISTING_CREDS=$(curl -s "$N8N_URL/credentials" \
      -H "X-N8N-API-KEY: $N8N_API_KEY")
    
    EXISTING_ID=$(echo "$EXISTING_CREDS" | jq -r ".data[] | select(.name == \"$CRED_NAME\") | .id")
    
    CREDENTIAL_JSON=$(cat <<EOF
{
  "name": "$CRED_NAME",
  "type": "$CRED_TYPE",
  "data": $CRED_DATA
}
EOF
)
    
    if [ -n "$EXISTING_ID" ]; then
        echo "  Updating existing credential (ID: $EXISTING_ID)..."
        RESPONSE=$(curl -s -X PATCH "$N8N_URL/credentials/$EXISTING_ID" \
          -H "X-N8N-API-KEY: $N8N_API_KEY" \
          -H "Content-Type: application/json" \
          -d "$CREDENTIAL_JSON")
        echo "  ✅ Updated credential: $CRED_NAME"
    else
        echo "  Creating new credential..."
        RESPONSE=$(curl -s -X POST "$N8N_URL/credentials" \
          -H "X-N8N-API-KEY: $N8N_API_KEY" \
          -H "Content-Type: application/json" \
          -d "$CREDENTIAL_JSON")
        NEW_ID=$(echo "$RESPONSE" | jq -r '.id')
        if [ -n "$NEW_ID" ] && [ "$NEW_ID" != "null" ]; then
            echo "  ✅ Created credential: $CRED_NAME (ID: $NEW_ID)"
        else
            echo "  ❌ Failed to create credential. Response:"
            echo "$RESPONSE" | jq
        fi
    fi
}

echo "=== n8n Credential Injection Script ==="
echo ""

# Telegram Bot Credential
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
    create_or_update_credential \
        "Telegram Bot" \
        "telegramApi" \
        "{\"accessToken\": \"$TELEGRAM_BOT_TOKEN\"}"
fi

# OpenAI Credential (example)
if [ -n "$OPENAI_API_KEY" ]; then
    create_or_update_credential \
        "OpenAI" \
        "openAiApi" \
        "{\"apiKey\": \"$OPENAI_API_KEY\"}"
fi

# GitHub Credential (example)
if [ -n "$GITHUB_TOKEN" ]; then
    create_or_update_credential \
        "GitHub" \
        "githubApi" \
        "{\"accessToken\": \"$GITHUB_TOKEN\"}"
fi

# Slack Credential (example)
if [ -n "$SLACK_TOKEN" ]; then
    create_or_update_credential \
        "Slack" \
        "slackApi" \
        "{\"accessToken\": \"$SLACK_TOKEN\"}"
fi

# Discord Webhook (example)
if [ -n "$DISCORD_WEBHOOK_URL" ]; then
    create_or_update_credential \
        "Discord Webhook" \
        "discordWebhook" \
        "{\"webhookUrl\": \"$DISCORD_WEBHOOK_URL\"}"
fi

# MySQL Database (example)
if [ -n "$MYSQL_HOST" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
    create_or_update_credential \
        "MySQL Database" \
        "mysqlDb" \
        "{
            \"host\": \"$MYSQL_HOST\",
            \"port\": ${MYSQL_PORT:-3306},
            \"database\": \"${MYSQL_DATABASE:-}\",
            \"user\": \"$MYSQL_USER\",
            \"password\": \"$MYSQL_PASSWORD\"
        }"
fi

# PostgreSQL Database (example)
if [ -n "$POSTGRES_HOST" ] && [ -n "$POSTGRES_USER" ] && [ -n "$POSTGRES_PASSWORD" ]; then
    create_or_update_credential \
        "PostgreSQL Database" \
        "postgres" \
        "{
            \"host\": \"$POSTGRES_HOST\",
            \"port\": ${POSTGRES_PORT:-5432},
            \"database\": \"${POSTGRES_DATABASE:-postgres}\",
            \"user\": \"$POSTGRES_USER\",
            \"password\": \"$POSTGRES_PASSWORD\"
        }"
fi

# Redis (example)
if [ -n "$REDIS_HOST" ]; then
    REDIS_DATA="{\"host\": \"$REDIS_HOST\", \"port\": ${REDIS_PORT:-6379}"
    if [ -n "$REDIS_PASSWORD" ]; then
        REDIS_DATA="${REDIS_DATA}, \"password\": \"$REDIS_PASSWORD\""
    fi
    REDIS_DATA="${REDIS_DATA}}"
    
    create_or_update_credential \
        "Redis" \
        "redis" \
        "$REDIS_DATA"
fi

# AWS Credentials (example)
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    create_or_update_credential \
        "AWS" \
        "aws" \
        "{
            \"accessKeyId\": \"$AWS_ACCESS_KEY_ID\",
            \"secretAccessKey\": \"$AWS_SECRET_ACCESS_KEY\",
            \"region\": \"${AWS_DEFAULT_REGION:-us-east-1}\"
        }"
fi

# Google Service Account (example)
if [ -n "$GOOGLE_SERVICE_ACCOUNT_JSON" ]; then
    create_or_update_credential \
        "Google Service Account" \
        "googleApi" \
        "$GOOGLE_SERVICE_ACCOUNT_JSON"
fi

# SMTP Email (example)
if [ -n "$SMTP_HOST" ] && [ -n "$SMTP_USER" ] && [ -n "$SMTP_PASSWORD" ]; then
    create_or_update_credential \
        "Email SMTP" \
        "smtp" \
        "{
            \"host\": \"$SMTP_HOST\",
            \"port\": ${SMTP_PORT:-587},
            \"secure\": ${SMTP_SECURE:-false},
            \"user\": \"$SMTP_USER\",
            \"password\": \"$SMTP_PASSWORD\"
        }"
fi

echo ""
echo "=== Credential injection complete ==="
echo ""
echo "To add more credentials:"
echo "1. Add the credential values to your .env file"
echo "2. Add a new section in this script following the pattern above"
echo "3. Run ./inject-credentials.sh"
echo ""
echo "Supported credential types can be found in n8n documentation"