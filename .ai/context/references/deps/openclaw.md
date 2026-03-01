# openclaw

> Personal AI assistant you run on your own devices. Gateway connects messaging platforms to AI agents with tool use, voice, and browser automation.

Source: `github:openclaw/openclaw`

### Install and Run OpenClaw Gateway

Source: https://context7.com/openclaw/openclaw/llms.txt

Installs OpenClaw globally using npm or pnpm, runs the onboarding wizard for setup, and starts the Gateway service. The Gateway manages sessions, presence, configuration, and tool execution across multiple messaging channels.

```bash
# Install globally via npm or pnpm
npm install -g openclaw@latest
# or: pnpm add -g openclaw@latest

# Run the onboarding wizard (installs daemon, configures workspace)
openclaw onboard --install-daemon

# Start the gateway
openclaw gateway --port 18789 --verbose
```

______________________________________________________________________

### Send Message via OpenClaw Agent CLI

Source: https://github.com/openclaw/openclaw/blob/main/docs/help/faq.md

Example of using the OpenClaw agent CLI to send a message to another bot or Gateway. This can be used for inter-instance communication, potentially over SSH or Tailscale.

```bash
openclaw agent --message "Hello from local bot" --deliver --channel telegram --reply-to <chat-id>
```

______________________________________________________________________

### Agent Tool (Message) for Polls

Source: https://github.com/openclaw/openclaw/blob/main/docs/automation/poll.md

Instructions on using the 'message' agent tool with the 'poll' action.

```APIDOC
## Agent Tool (Message) for Polls

This section describes how to use the `message` agent tool with the `poll` action to send polls.

### Action

`poll`

### Parameters

- **`to`** (string, required): The recipient identifier.
- **`pollQuestion`** (string, required): The question for the poll.
- **`pollOption`** (string[], required): An array of poll option strings.
- **`pollMulti`** (boolean, optional): Maps to multi-select functionality. Note: For Discord, this enables multi-select as there is no "pick exactly N" mode.
- **`pollDurationHours`** (number, optional): The duration of the poll in hours. See channel-specific differences for details.
- **`channel`** (string, optional): The messaging channel to use (e.g., `whatsapp`, `discord`, `msteams`). Defaults to `whatsapp`.
```

### OpenClaw

Source: https://github.com/openclaw/openclaw/blob/main/docs/index.md

OpenClaw is a self-hosted gateway that connects your favorite chat apps — WhatsApp, Telegram, Discord, iMessage, and more — to AI coding agents like Pi. You run a single Gateway process on your own machine (or a server), and it becomes the bridge between your messaging apps and an always-available AI assistant. It is designed for developers and power users who want a personal AI assistant they can message from anywhere, without giving up control of their data or relying on a hosted service. Key differentiators include being self-hosted, multi-channel support for various messaging platforms simultaneously, agent-native features like tool use and memory, and being open source under the MIT license.

______________________________________________________________________

### OpenClaw

Source: https://context7.com/openclaw/openclaw/llms.txt

OpenClaw is a personal AI assistant platform designed to be run on your own devices. It features a unified control plane called the Gateway, which acts as a central hub to connect with a wide array of messaging channels. These channels include popular services like WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, Matrix, and WebChat. The Gateway is responsible for managing various aspects of the assistant's operation, such as user sessions, presence status, system configuration, scheduled tasks (cron jobs), incoming webhooks, and the execution of tools. A key feature is its ability to maintain conversation continuity, ensuring that interactions are seamless even when users switch between different messaging channels.
