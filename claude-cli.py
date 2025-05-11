import os
import sys
import json
import argparse
import signal
import anthropic
from anthropic import Anthropic
from pathlib import Path

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
        except Exception as e:
            print(f"Warning: Could not load config file: {e}")
            print("Using default settings.")
    
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
            except:
                pass
    
    if not api_key:
        print("Error: ANTHROPIC_API_KEY environment variable not set and no API key found.")
        print("Please set it with: export ANTHROPIC_API_KEY='your_api_key'")
        print("Or create a file at ~/.claude_api_key containing your API key.")
        sys.exit(1)
    
    return Anthropic(api_key=api_key)

def handle_conversation(args):
    """Handle a conversation with Claude."""
    client = get_client()
    
    # Prepare messages
    messages = []
    
    # Add system message if provided
    if args.system:
        messages.append({
            "role": "system",
            "content": args.system
        })
    
    # Add user message
    messages.append({
        "role": "user",
        "content": args.prompt
    })
    
    # Make API call
    try:
        response = client.messages.create(
            model=args.model,
            max_tokens=args.max_tokens,
            temperature=args.temperature,
            messages=messages
        )
        
        if args.json:
            print(json.dumps(response.model_dump(), indent=2))
        else:
            print(response.content[0].text)
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def chat_mode(args):
    """Interactive chat mode with Claude."""
    client = get_client()
    config = load_config()
    
    # Initialize conversation
    messages = []
    
    # Add system message if provided
    if args.system:
        messages.append({
            "role": "system",
            "content": args.system
        })
    
    print(f"Claude Chat ({args.model})")
    print("Type 'exit' or 'quit' to end the conversation.")
    print("-" * 50)
    
    while True:
        # Get user input
        user_input = input(f"\n{config['chat_prompt']}")
        
        # Check for exit command
        if user_input.lower() in ['exit', 'quit']:
            print("Exiting chat.")
            break
        
        # Add user message
        messages.append({
            "role": "user", 
            "content": user_input
        })
        
        # Make API call
        try:
            print("\nClaude is thinking...")
            response = client.messages.create(
                model=args.model,
                max_tokens=args.max_tokens,
                temperature=args.temperature,
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
            print(f"Error: {e}")
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
        print("\nChat session ended.")
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    try:
        chat_mode(Args())
    except KeyboardInterrupt:
        print("\nChat session ended.")
        sys.exit(0)

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
    
    # Handle command line arguments
    if len(sys.argv) > 1:
        args = parser.parse_args()
        
        if args.command == "ask":
            handle_conversation(args)
        elif args.command == "chat":
            chat_mode(args)
        elif args.command == "start":
            start_mode()
        else:
            parser.print_help()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()