# Claude CLI

A simple command-line interface for interacting with Anthropic's Claude AI models.

## Installation

### Prerequisites
- Python 3.7 or higher
- Anthropic API key

### Setup

1. Clone this repository:
   ```
   git clone https://github.com/MortenBeck/ClaudeCLI.git
   cd claude-cli
   ```

2. Install the package:
   ```
   pip install -e .
   ```

3. Set your Anthropic API key as an environment variable:
   ```
   export ANTHROPIC_API_KEY='your_api_key_here'
   ```
   
   For permanent setup, add this line to your `~/.bashrc`, `~/.zshrc`, or equivalent shell configuration file.

4. Make the script executable:
   ```
   chmod +x claude-cli.py
   ```

## Usage

### Single Question Mode

To ask Claude a single question:

```
./claude-cli.py ask "What is the capital of France?"
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
./claude-cli.py ask -m claude-3-opus-20240229 "Explain quantum computing"

# Set a system message
./claude-cli.py ask -s "You are a helpful coding assistant." "How do I create a REST API in Python?"

# Lower temperature for more deterministic responses
./claude-cli.py ask -t 0.3 "Write a sorting algorithm"

# Limit the response length
./claude-cli.py ask -x 1000 "Summarize World War II"

# Get the full JSON response
./claude-cli.py ask -j "Tell me a joke"
```

### Interactive Chat Mode

For an ongoing conversation with Claude:

```
./claude-cli.py chat
```

This starts an interactive session where you can have a back-and-forth conversation with Claude. Type 'exit' or 'quit' to end the session.

Options:
- `--model`, `-m`: Specify the Claude model (default: claude-3-7-sonnet-20250219)
- `--temperature`, `-t`: Set response temperature (default: 0.7)
- `--max-tokens`, `-x`: Set maximum tokens in response (default: 4000)
- `--system`, `-s`: Provide a system message for context

Example:

```bash
# Start a chat with Claude as a coding assistant
./claude-cli.py chat -s "You are a helpful coding assistant." -t 0.5
```

## Advanced Usage

### Using in Scripts

You can use the Claude CLI in shell scripts:

```bash
#!/bin/bash
response=$(./claude-cli.py ask "Generate 5 random numbers between 1 and 100")
echo "Claude generated: $response"
```

### Piping Input

You can pipe text to the Claude CLI:

```bash
cat myfile.txt | xargs ./claude-cli.py ask "Summarize this text:"
```

## Troubleshooting

- **API Key Error**: Make sure your ANTHROPIC_API_KEY environment variable is set correctly
- **Dependency Issues**: Try reinstalling dependencies with `pip install -r requirements.txt`
- **Permission Denied**: Ensure the script is executable with `chmod +x claude-cli.py`