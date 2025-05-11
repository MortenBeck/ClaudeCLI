import os
import sys
import json
import argparse
import anthropic
from anthropic import Anthropic

def get_client():
    """Initialize and return the Anthropic client."""
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("Error: ANTHROPIC_API_KEY environment variable not set.")
        print("Please set it with: export ANTHROPIC_API_KEY='your_api_key'")
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
        user_input = input("\nYou: ")
        
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
    
    args = parser.parse_args()
    
    if args.command == "ask":
        handle_conversation(args)
    elif args.command == "chat":
        chat_mode(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()