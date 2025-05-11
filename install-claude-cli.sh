#!/bin/bash
# Script to install the Claude CLI tool

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error message
error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info message
info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Determine the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
success "Installation directory: $SCRIPT_DIR"

# Detect Python command (python3 on macOS, python on many Linux distros)
for cmd in python3 python; do
    if command -v $cmd &> /dev/null; then
        PYTHON_CMD=$cmd
        PYTHON_VERSION=$($cmd --version)
        success "Found Python: $PYTHON_VERSION using command '$PYTHON_CMD'"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    error "Neither python3 nor python was found in PATH."
    info "Please install Python 3.7 or higher."
    exit 1
fi

# Check if the script exists
if [ ! -f "$SCRIPT_DIR/claude_cli.py" ]; then
    error "Script file claude_cli.py not found in $SCRIPT_DIR"
    exit 1
fi

# Make the main script executable
chmod +x "$SCRIPT_DIR/claude_cli.py"
success "Made script executable"

# Install required packages
info "Installing required packages..."
$PYTHON_CMD -m pip install anthropic || {
    error "Failed to install packages. Please run: $PYTHON_CMD -m pip install anthropic"
    exit 1
}
success "Packages installed successfully"

# Create a symbolic link to the script in /usr/local/bin (or another directory in your PATH)
BIN_PATH="/usr/local/bin"
if [ -d "$BIN_PATH" ] && [ -w "$BIN_PATH" ]; then
    # Create a simple wrapper script
    cat > "$BIN_PATH/claude" << EOF
#!/bin/bash
# Wrapper for claude_cli.py

# Set the API key (if not already set)
if [ -z "\$ANTHROPIC_API_KEY" ]; then
    # Check if we have a stored API key
    if [ -f "\$HOME/.claude_api_key" ]; then
        export ANTHROPIC_API_KEY=\$(cat "\$HOME/.claude_api_key")
    else
        echo -e "${RED}✗ Error: ANTHROPIC_API_KEY not set.${NC}"
        echo -e "${BLUE}→ Please set it with: export ANTHROPIC_API_KEY='your_api_key'${NC}"
        echo -e "${BLUE}→ Or store it in \$HOME/.claude_api_key for automatic loading${NC}"
        exit 1
    fi
fi

# Call the actual script with all arguments passed through
$PYTHON_CMD "$SCRIPT_DIR/claude_cli.py" "\$@"
EOF
    
    # Make the wrapper executable
    chmod +x "$BIN_PATH/claude"
    
    success "Created global 'claude' command in $BIN_PATH"
    info "You can now use the 'claude' command from anywhere."
else
    error "Unable to create symbolic link in $BIN_PATH."
    info "You may need to run this script with sudo privileges."
    
    # Determine shell configuration file
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    else
        SHELL_CONFIG="your shell configuration file"
    fi
    
    alias_line="alias claude='$PYTHON_CMD $SCRIPT_DIR/claude_cli.py'"
    info "Alternatively, add the following alias to $SHELL_CONFIG:"
    echo "    $alias_line"
    
    # Ask to add alias automatically
    read -p "Would you like to add this alias to your shell config now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check if the file exists, create if it doesn't
        touch "$SHELL_CONFIG"
        echo -e "\n# Claude CLI alias" >> "$SHELL_CONFIG"
        echo "$alias_line" >> "$SHELL_CONFIG"
        success "Added alias to $SHELL_CONFIG"
        info "Run 'source $SHELL_CONFIG' to activate the alias in your current session."
    fi
fi

# Prompt for API key if not set
if [ -z "$ANTHROPIC_API_KEY" ] && [ ! -f "$HOME/.claude_api_key" ]; then
    info "Would you like to set up your Anthropic API key now? (y/n)"
    read -r answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        info "Enter your Anthropic API key:"
        read -r api_key
        echo "$api_key" > "$HOME/.claude_api_key"
        chmod 600 "$HOME/.claude_api_key"  # Secure the file
        success "API key saved to $HOME/.claude_api_key"
    else
        info "You'll need to set the ANTHROPIC_API_KEY environment variable later."
        info "Or create ~/.claude_api_key containing just your API key."
    fi
fi

# Create a short alias
info "Creating shortcut alias (c)..."
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="your shell configuration file"
fi

if [ -f "$SHELL_CONFIG" ]; then
    if ! grep -q "alias c='claude start'" "$SHELL_CONFIG"; then
        echo -e "\n# Claude CLI shortcut" >> "$SHELL_CONFIG"
        echo "alias c='claude start'" >> "$SHELL_CONFIG"
        success "Added shortcut 'c' alias to $SHELL_CONFIG"
        info "Run 'source $SHELL_CONFIG' to activate the shortcut in your current session."
    else
        info "Shortcut 'c' alias already exists in $SHELL_CONFIG"
    fi
fi

# Final check
success "Installation complete!"
info "Testing Claude CLI..."
$PYTHON_CMD "$SCRIPT_DIR/claude_cli.py" check

info "You can now use the following commands:"
echo "   claude start  - Start an immediate chat session with Claude"
echo "   claude ask    - Ask Claude a single question"
echo "   claude chat   - Start an interactive chat session with more options"
echo "   claude check  - Check the environment and configuration"
echo ""
echo "If you added the shortcut alias:"
echo "   c             - Quick shortcut to start a chat session"
echo ""
success "Enjoy using Claude CLI!"