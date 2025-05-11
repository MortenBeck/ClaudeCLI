# Determine the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Make the main script executable
chmod +x "$SCRIPT_DIR/claude_cli.py"

# Create a symbolic link to the script in /usr/local/bin (or another directory in your PATH)
if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
    # Create a simple wrapper script
    cat > /usr/local/bin/claude << 'EOF'
#!/bin/bash
# Wrapper for claude_cli.py

# Set the API key (if not already set)
if [ -z "$ANTHROPIC_API_KEY" ]; then
    # Check if we have a stored API key
    if [ -f "$HOME/.claude_api_key" ]; then
        export ANTHROPIC_API_KEY=$(cat "$HOME/.claude_api_key")
    else
        echo "Error: ANTHROPIC_API_KEY not set."
        echo "Please set it with: export ANTHROPIC_API_KEY='your_api_key'"
        echo "Or store it in $HOME/.claude_api_key for automatic loading"
        exit 1
    fi
fi

# Call the actual script with all arguments passed through
SCRIPT_PATH="SCRIPT_DIR_PLACEHOLDER/claude_cli.py"
"$SCRIPT_PATH" "$@"
EOF

    # Replace the placeholder with the actual script directory
    sed -i "s|SCRIPT_DIR_PLACEHOLDER|$SCRIPT_DIR|g" /usr/local/bin/claude
    
    # Make the wrapper executable
    chmod +x /usr/local/bin/claude
    
    echo "Installation successful!"
    echo "You can now use the 'claude' command from anywhere."
    echo "Try 'claude start' to begin a chat session."
else
    echo "Error: Unable to create symbolic link in /usr/local/bin."
    echo "You may need to run this script with sudo privileges."
    echo "Alternatively, you can add the following alias to your shell configuration:"
    echo "alias claude='$SCRIPT_DIR/claude_cli.py'"
fi

# Prompt for API key if not set
if [ -z "$ANTHROPIC_API_KEY" ] && [ ! -f "$HOME/.claude_api_key" ]; then
    echo "Would you like to set up your Anthropic API key now? (y/n)"
    read -r answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        echo "Enter your Anthropic API key:"
        read -r api_key
        echo "$api_key" > "$HOME/.claude_api_key"
        chmod 600 "$HOME/.claude_api_key"  
        echo "API key saved to $HOME/.claude_api_key"
    else
        echo "You'll need to set the ANTHROPIC_API_KEY environment variable later."
    fi
fi

echo "Installation complete!"