# Claude CLI

A simple and powerful command-line interface for interacting with Anthropic's Claude AI models directly from your terminal.

![Claude CLI Demo](https://github.com/MortenBeck/ClaudeCLI/raw/main/docs/images/demo.gif)

## Features

- **Quick Start Mode**: Simply type `claude start` to begin chatting immediately
- **Single Question Mode**: Ask Claude one-off questions with `claude ask`
- **Interactive Chat**: Have full conversations with message history using `claude chat`
- **Environment Check**: Verify your setup with `claude check`
- **Configurable**: Easily customize model, temperature, and system prompts
- **Cross-Platform**: Works on macOS, Linux, and Windows

## Installation

### Prerequisites

- Python 3.7 or higher
- Anthropic API key ([Get one here](https://console.anthropic.com/))

### Option 1: Automated Installation (macOS/Linux)

```bash
# Clone the repository
git clone https://github.com/MortenBeck/ClaudeCLI.git
cd ClaudeCLI

# Run the installer
chmod +x install-claude-cli.sh
./install-claude-cli.sh
```

The installer will:
- Detect the correct Python command for your system
- Install required dependencies
- Set up the `claude` command in your system
- Prompt you for your API key and store it securely
- Create a shortcut alias `c` for even quicker access
- Test your installation to ensure everything works

### Option 2: Manual Installation (macOS/Linux)

```bash
# Clone the repository
git clone https://github.com/MortenBeck/ClaudeCLI.git
cd ClaudeCLI

# Install required packages
python3 -m pip install anthropic

# Make the script executable
chmod +x claude_cli.py

# Set up your API key (replace with your actual key)
echo "your_api_key_here" > ~/.claude_api_key
chmod 600 ~/.claude_api_key

# Create an alias in your shell configuration
echo 'alias claude="python3 '"$(pwd)"'/claude_cli.py"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc  # or source ~/.zshrc
```

### Windows Installation

1. **Clone the repository**
   ```
   git clone https://github.com/MortenBeck/ClaudeCLI.git
   cd ClaudeCLI
   ```

2. **Run the Windows installer**
   ```
   install-claude-cli.bat
   ```

   The installer will:
   - Check for Python and install required packages
   - Create the `claude` and `c` commands
   - Offer to add the commands to your PATH
   - Store your API key securely

3. **Alternative: Manual setup**
   
   If you prefer manual setup:
   ```
   pip install anthropic
   
   # Create API key file
   echo your_api_key_here > %USERPROFILE%\.claude_api_key
   
   # Create a batch file
   echo @echo off > claude.bat
   echo python "%CD%\claude_cli.py" %%* >> claude.bat
   ```

## Usage

### Checking Your Environment

To verify your installation and see important configuration details:

```bash
claude check
```

This will display:
- System and Python version information
- Script location and path
- API key status
- Configuration file status
- Required package information

### Quick Start (Recommended)

To immediately start chatting with Claude:

```bash
claude start
```

This starts an interactive session with default settings. Press `Ctrl+C` to exit.

If you set up the shortcut alias, you can simply use:

```bash
c
```

### Single Question Mode

To ask Claude a single question:

```bash
claude ask "What is the capital of France?"
```

Options:
- `--model`, `-m`: Specify the Claude model (default: claude-3-7-sonnet-20250219)
- `--temperature`, `-t`: Set response temperature (default: 0.7)
- `--max-tokens`, `-x`: Set maximum tokens in response (default: 4000)
- `--system`, `-s`: Provide a system message for context
- `--json`, `-j`: Output the full JSON response

Examples:

```bash
# Use a different model
claude ask -m claude-3-opus-20240229 "Explain quantum computing"

# Set a system message
claude ask -s "You are a helpful coding assistant." "How do I create a REST API in Python?"

# Get the full JSON response
claude ask -j "Tell me a joke"
```

### Interactive Chat Mode

For an ongoing conversation with Claude:

```bash
claude chat
```

This starts an interactive session where you can have a back-and-forth conversation with Claude. Type 'exit' or 'quit' to end the session.

## Customization

You can customize Claude CLI by editing the `config.json` file:

```json
{
  "default_model": "claude-3-7-sonnet-20250219",
  "default_temperature": 0.7,
  "default_max_tokens": 4000,
  "default_system_message": "You are Claude, a helpful AI assistant.",
  "chat_prompt": "You: ",
  "welcome_message": "Welcome to Claude CLI! Type your message and press Enter. Use Ctrl+C to exit."
}
```

## Advanced Usage

### Using in Scripts

You can use Claude CLI in shell scripts:

```bash
# macOS/Linux
response=$(claude ask "Generate 5 random numbers between 1 and 100")
echo "Claude generated: $response"

# Windows (PowerShell)
$response = claude ask "Generate 5 random numbers between 1 and 100"
Write-Output "Claude generated: $response"
```

### Piping Input

You can pipe text to Claude CLI:

```bash
# macOS/Linux
cat myfile.txt | xargs claude ask "Summarize this text:"

# Windows
type myfile.txt | claude ask "Summarize this text:"
```

## Troubleshooting

If you encounter issues, the `check` command is your first step for diagnostics:

```bash
claude check
```

### Common Issues

#### Command not found
- **macOS/Linux**: Check if the `claude` command is in your PATH or if your alias is correctly defined
- **Windows**: Ensure the batch file is in your PATH or use the full path to the script

#### Python issues on macOS
On macOS, you may need to use `python3` instead of `python`:
```bash
python3 /path/to/claude_cli.py start
```

#### API Key issues
If you get authentication errors:
```bash
# Check if your API key is correctly stored
cat ~/.claude_api_key

# Or set it directly in your environment
export ANTHROPIC_API_KEY="your-api-key-here"
```

#### Path issues with spaces
If your installation path contains spaces:
```bash
# Use quotes in your alias
alias claude="python3 '/path with spaces/claude_cli.py'"
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request