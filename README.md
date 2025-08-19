# N8N Telegram Echo Bot

A simple n8n workflow that creates a Telegram bot that echoes back any message you send to it.

## Prerequisites

1. n8n instance running (Docker or npm)
2. Telegram Bot Token from @BotFather

## Setup Instructions

### 1. Create a Telegram Bot

1. Open Telegram and search for @BotFather
2. Send `/newbot` command
3. Choose a name for your bot (e.g., "My Echo Bot")
4. Choose a username for your bot (must end with 'bot', e.g., "myecho_bot")
5. Copy the bot token (looks like: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 2. Import Workflow to n8n

1. Open your n8n instance at http://localhost:5678
2. Click on "Workflows" in the left sidebar
3. Click "Import from File" button
4. Select the `workflows/telegram-echo-bot.json` file
5. Click "Import"

### 3. Configure Telegram Credentials

1. In the imported workflow, click on the "Send Echo Message" node
2. Click on "Credentials" dropdown
3. Select "Create New" 
4. Enter your Bot Token from step 1
5. Click "Save"

### 4. Activate the Workflow

1. Click the toggle switch in the top-right to activate the workflow
2. Click on the "Telegram Trigger" node
3. Copy the Webhook URL shown
4. The webhook will be automatically registered with Telegram

### 5. Test Your Bot

1. Open Telegram
2. Search for your bot username
3. Send any message
4. The bot will echo back the same message!

## Workflow Structure

- **Telegram Trigger**: Listens for incoming messages
- **Send Echo Message**: Replies with the same text received

## Customization Ideas

- Add a prefix to messages (e.g., "You said: [message]")
- Add emoji reactions
- Filter certain message types
- Add logging to a database
- Connect to other services

## Troubleshooting

- **Bot not responding**: Check if workflow is activated
- **Webhook errors**: Ensure n8n is accessible from internet (use ngrok for local testing)
- **Authentication failed**: Verify bot token is correct

## Files

- `workflows/telegram-echo-bot.json` - The n8n workflow file