## 1. Install Node.js on macOS

### Option A: Using Homebrew (Recommended)
1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Node.js**:
   ```bash
   brew install node
   ```

### Option B: Direct Download
1. **Download Node.js**:
   - Go to [nodejs.org](https://nodejs.org/)
   - Download the macOS Installer (.pkg) - LTS version
   - Run the installer and follow the setup wizard

### Option C: Using Node Version Manager (nvm)
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload your shell configuration
source ~/.bashrc  # or ~/.zshrc

# Install and use latest LTS Node.js
nvm install --lts
nvm use --lts
```

3. **Verify Installation**:
   ```bash
   node --version
   npm --version
   ```

## 2. Install Claude Desktop

1. **Download Claude Desktop**:
   - Visit the official Anthropic website
   - Download the macOS version (.dmg file)
   - Open the .dmg and drag Claude to your Applications folder


2. Open Claude, Settings, Developer, and **Edit the Configuration**:
  
```json
   {
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--sse",
        "https://<YOUR URL>/mcp/agent",
      ]
    }
  }
}
```


## 3. Test Your Setup

1. **Test with Claude Desktop**:
   - Launch Claude Desktop
   - Check that it connects to your MCP server
   - Look for any connection logs

## 4. Debugging and Logs

1. **Check Claude Desktop logs**:
   ```bash
   tail -f ~/Library/Logs/Claude/claude-desktop.log
   ```

2. **Add logging to your server**:
   ```javascript
   console.error('Server starting...');
   console.error('Tool called:', request.params.name);
   ```

## 5. macOS-Specific Considerations

1. **Permissions**: You may need to grant Claude Desktop permissions in System Preferences > Security & Privacy

2. **Path Issues**: Ensure your PATH includes Node.js:
   ```bash
   echo $PATH
   which node
   ```

3. **Firewall**: Check macOS firewall settings if you have connection issues


## 6 . Troubleshooting Common Issues

- **Permission denied**: Use `chmod +x` on your server file
- **Module not found**: Check your import paths and node_modules
- **Claude Desktop not connecting**: Verify the path in `claude_desktop_config.json`
- **Port conflicts**: Ensure no other processes are using the same ports