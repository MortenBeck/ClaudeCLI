# Claude CLI

A simple and powerful command-line interface for interacting with Anthropic's Claude AI models directly from your terminal.

![Claude CLI Demo](https://github.com/MortenBeck/ClaudeCLI/raw/main/docs/images/demo.gif)

## Features

- **Quick Start Mode**: Simply type `claude start` to begin chatting immediately
- **Single Question Mode**: Ask Claude one-off questions with `claude ask`
- **Interactive Chat**: Have full conversations with message history using `claude chat`
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
- Set up the `claude` command in your system
- Prompt you for your API key and store it securely
- Make the tool accessible from anywhere in your terminal

### Option 2: Manual Installation (macOS/Linux)

```bash
# Clone the repository
git clone https://github.com/MortenBeck/ClaudeCLI.git
cd ClaudeCLI

# Install required packages
pip install -e .

# Make the script executable
chmod +x claude-cli.py

# Set up your API key (replace with your actual key)
echo "your_api_key_here" > ~/.claude_api_key
chmod 600 ~/.claude_api_key

# Create an alias in your shell configuration
echo 'alias claude="python /path/to/ClaudeCLI/claude-cli.py"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc  # or source ~/.zshrc
```

### Windows Installation

1. **Clone the repository**
   ```
   git clone https://github.com/MortenBeck/ClaudeCLI.git
   cd ClaudeCLI
   ```

2. **Install required packages**
   ```
   pip install -e .
   ```

3. **Set up your API key**
   
   Create a file at `%USERPROFILE%\.claude_api_key` containing only your API key.
   
   Or set an environment variable:
   ```
   setx ANTHROPIC_API_KEY "your_api_key_here"
   ```

4. **Create a batch file for easy access**
   
   Create a file named `claude.bat` with the following content:
   ```
   @echo off
   python "C:\path\to\ClaudeCLI\claude-cli.py" %*
   ```
   
   Save this file in a directory that's in your system PATH (e.g., `C:\Windows`)

## Usage

### Quick Start (Recommended)

To immediately start chatting with Claude:

```bash
claude start
```

This starts an interactive session with default settings. Press `Ctrl+C` to exit.

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

## Shortcut Alias

For even faster access, you can set up a short alias:

### macOS/Linux

Add to your `~/.bashrc`, `~/.zshrc`, or equivalent:
```bash
alias c="claude start"
```

Then reload your shell configuration:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Windows

Create a batch file named `c.bat` with:
```
@echo off
claude start %*
```

Save it to a directory in your PATH.

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

- **API Key Error**: Make sure your API key is stored in `~/.claude_api_key` or set as the `ANTHROPIC_API_KEY` environment variable
- **Command Not Found**: Ensure the installation directory is in your PATH, or use the full path to the script
- **Dependency Issues**: Try reinstalling dependencies with `pip install -r requirements.txt`
- **Permission Denied**: On Unix systems, ensure the script is executable with `chmod +x claude-cli.py`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request