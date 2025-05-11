import os
import sys
import json
import argparse
import signal
import platform
from pathlib import Path
from anthropic import Anthropic

def print_success(message):
    """Print a success message in green if supported."""
    if sys.stdout.isatty():
        print(f"\033[92m✓ {message}\033[0m")
    else:
        print(f"SUCCESS: {message}")

def print_error(message):
    """Print an error message in red if supported."""
    if sys.stdout.isatty():
        print(f"\033[91m✗ {message}\033[0m")
    else:
        print(f"ERROR: {message}")

def print_info(message):
    """Print an info message in blue if supported."""
    if sys.stdout.isatty():
        print(f"\033[94m→ {message}\033[0m")
    else:
        print(f"INFO: {message}")

def load_config():
    """Load configuration from config.json file."""
    script_dir = Path(__file__).parent.absolute()
    config_file = script_dir / "config.json"
    
    defaults = {
        "default_model": "claude-3-7-sonnet-20250219",
        "default_temperature": 0.7,
        "default_max_tokens": 4000,
        "default_system_message": "You are Claude, a helpful AI assistant.",
        "chat_prompt": "You: ",
        "welcome_message": "Welcome to Claude CLI! Type your message and press Enter. Use Ctrl+C to exit."
    }
    
    if config_file.exists():
        try:
            with open(config_file, 'r') as f:
                loaded_config = json.load(f)
                # Update defaults with loaded values
                defaults.update(loaded_config)
            print_info(f"Config loaded from {config_file}")
        except Exception as e:
            print_error(f"Could not load config file: {e}")
            print_info("Using default settings.")
    else:
        print_info("No config file found, using default settings.")
    
    return defaults

def get_client():
    """Initialize and return the Anthropic client."""
    # First check environment variable
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    
    # If not found, check for stored key
    if not api_key:
        api_key_file = os.path.expanduser("~/.claude_api_key")
        if os.path.exists(api_key_file):
            try:
                with open(api_key_file, 'r') as f:
                    api_key = f.read().strip()
                print_info(f"Using API key from {api_key_file}")
            except Exception as e:
                print_error(f"Error reading API key file: {e}")
    
    if not api_key:
        print_error("ANTHROPIC_API_KEY environment variable not set and no API key found.")
        print_info("Please set it with: export ANTHROPIC_API_KEY='your_api_key'")
        print_info("Or create a file at ~/.claude_api_key containing your API key.")
        sys.exit(1)
    
    try:
        client = Anthropic(api_key=api_key)
        return client
    except Exception as e:
        print_error(f"Failed to initialize Anthropic client: {e}")
        sys.exit(1)

def handle_conversation(args):
    """Handle a conversation with Claude."""
    client = get_client()
    
    # Prepare messages
    messages = []
    
    # Add user message
    messages.append({
        "role": "user",
        "content": args.prompt
    })
    
    print_info(f"Sending message to Claude... (model: {args.model}, temperature: {args.temperature})")
    
    # Make API call - using system parameter instead of system message
    try:
        response = client.messages.create(
            model=args.model,
            max_tokens=args.max_tokens,
            temperature=args.temperature,
            system=args.system,  # Pass system message as a parameter, not as a message
            messages=messages
        )
        
        print_success("Response received successfully")
        
        if args.json:
            print(json.dumps(response.model_dump(), indent=2))
        else:
            print("\n" + response.content[0].text)
            
    except Exception as e:
        print_error(f"API call failed: {e}")
        sys.exit(1)

def chat_mode(args):
    """Interactive chat mode with Claude."""
    client = get_client()
    config = load_config()
    
    # Initialize conversation
    messages = []
    
    # Store system message for API calls
    system_message = args.system
    
    print(f"Claude Chat ({args.model})")
    print("Type 'exit' or 'quit' to end the conversation.")
    print("-" * 50)
    
    while True:
        # Get user input
        try:
            user_input = input(f"\n{config['chat_prompt']}")
        except EOFError:
            print("\nInput stream ended. Exiting chat.")
            break
            
        # Check for exit command
        if user_input.lower() in ['exit', 'quit']:
            print_success("Exiting chat session.")
            break
        
        if not user_input.strip():
            continue
            
        # Add user message
        messages.append({
            "role": "user", 
            "content": user_input
        })
        
        # Make API call
        try:
            print_info("Claude is thinking...")
            response = client.messages.create(
                model=args.model,
                max_tokens=args.max_tokens,
                temperature=args.temperature,
                system=system_message,  # Pass system message as a parameter
                messages=messages
            )
            
            # Print response
            assistant_response = response.content[0].text
            print(f"\nClaude: {assistant_response}")
            
            # Add assistant response to messages
            messages.append({
                "role": "assistant",
                "content": assistant_response
            })
            
        except Exception as e:
            print_error(f"Error: {e}")
            continue

def start_mode():
    """Quick-start chat mode with default settings, runs until Ctrl+C."""
    config = load_config()
    
    print(config["welcome_message"])
    print("-" * 50)
    
    # Create args object with default values from config
    class Args:
        model = config["default_model"]
        temperature = config["default_temperature"]
        max_tokens = config["default_max_tokens"]
        system = config["default_system_message"]
    
    # Set up signal handler for graceful exit
    def signal_handler(sig, frame):
        print("\n")
        print_success("Chat session ended.")
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    try:
        chat_mode(Args())
    except KeyboardInterrupt:
        print("\n")
        print_success("Chat session ended.")
        sys.exit(0)
    except Exception as e:
        print_error(f"An unexpected error occurred: {e}")
        sys.exit(1)

def check_environment():
    """Check and report on the environment."""
    print_info("Environment Check:")
    
    # System information
    print(f"  System: {platform.system()} {platform.release()}")
    print(f"  Python: {platform.python_version()}")
    
    # Script path
    script_path = Path(__file__).resolve()
    print(f"  Script location: {script_path}")
    
    # Check API key
    api_key_env = "ANTHROPIC_API_KEY" in os.environ
    api_key_file = os.path.exists(os.path.expanduser("~/.claude_api_key"))
    
    if api_key_env:
        print_success("  API key: Found in environment variables")
    elif api_key_file:
        print_success("  API key: Found in ~/.claude_api_key file")
    else:
        print_error("  API key: Not found")
    
    # Check for config file
    config_file = Path(__file__).parent.absolute() / "config.json"
    if config_file.exists():
        print_success(f"  Config file: Found at {config_file}")
    else:
        print_info(f"  Config file: Not found, will use defaults")
    
    # Check for Anthropic package
    try:
        import anthropic
        print_success(f"  Anthropic package: Installed (version {anthropic.__version__})")
    except ImportError:
        print_error("  Anthropic package: Not installed")
        print_info("  Install with: pip install anthropic")
    except AttributeError:
        print_info("  Anthropic package: Installed (version unknown)")
        
    # Test the API key without making a full API call
    try:
        client = get_client()
        print_success("  API key: Valid format")
        print_info("  Ready to use Claude CLI!")
    except Exception as e:
        print_error(f"  API key issue: {e}")

def main():
    parser = argparse.ArgumentParser(description="CLI tool for interacting with Anthropic's Claude")
    
    # Common arguments
    parser.add_argument("--model", "-m", default="claude-3-7-sonnet-20250219", 
                        help="Claude model to use (default: claude-3-7-sonnet-20250219)")
    parser.add_argument("--temperature", "-t", type=float, default=0.7,
                        help="Temperature for response generation (default: 0.7)")
    parser.add_argument("--max-tokens", "-x", type=int, default=4000,
                        help="Maximum number of tokens in the response (default: 4000)")
    parser.add_argument("--system", "-s", type=str, default=None,
                        help="System message to set context for Claude")
    
    # Create subparsers for different modes
    subparsers = parser.add_subparsers(dest="command", help="Command to run")
    
    # Single message mode
    message_parser = subparsers.add_parser("ask", help="Send a single message to Claude")
    message_parser.add_argument("prompt", help="The prompt to send to Claude")
    message_parser.add_argument("--json", "-j", action="store_true",
                              help="Output the full JSON response")
    
    # Chat mode
    chat_parser = subparsers.add_parser("chat", help="Start an interactive chat session with Claude")
    
    # Quick start mode
    start_parser = subparsers.add_parser("start", help="Start a chat session immediately (Ctrl+C to exit)")
    
    # Environment check mode
    env_parser = subparsers.add_parser("check", help="Check the environment and configuration")
    
    # Handle command line arguments
    if len(sys.argv) > 1:
        args = parser.parse_args()
        
        if args.command == "ask":
            handle_conversation(args)
        elif args.command == "chat":
            chat_mode(args)
        elif args.command == "start":
            start_mode()
        elif args.command == "check":
            check_environment()
        else:
            parser.print_help()
    else:
        parser.print_help()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print_error(f"An unexpected error occurred: {e}")
        sys.exit(1)