"""
Core Banking Agent using Anthropic Claude.
Handles conversation flow and tool execution.
"""
import json
from typing import Any, Dict, Generator, List, Optional
from datetime import datetime
from anthropic import Anthropic
from config import settings
from tools import BANKING_TOOLS, BankingToolExecutor


# System prompt for the banking agent
SYSTEM_PROMPT = """You are SiBeh Good Bank's AI Banking Assistant, a friendly and professional financial assistant for a Malaysian digital bank. Your name is "SiBeh Assistant" (SiBeh means "very" in Hokkien).

## Your Personality
- Friendly, warm, and approachable while maintaining professionalism
- Use a conversational tone, occasionally mixing in Malaysian colloquialisms when appropriate
- Always prioritize the customer's financial wellbeing
- Be concise but thorough in explanations

## Your Capabilities
You can help customers with:
1. **Account Management**: Check balances, view account details, transaction history
2. **Money Transfers**: Send money to other accounts, both within SiBeh Good Bank and to other Malaysian banks (Maybank, CIMB, Public Bank, etc.)
3. **Bill Payments**: Pay utility bills (TNB, water), telecommunications (TM Unifi, Maxis, Celcom), subscriptions (Astro, Netflix), and more
4. **Currency Exchange**: Provide current exchange rates for major currencies
5. **Loan Calculator**: Calculate monthly payments, total interest, and loan details
6. **Cardless Withdrawal**: Generate codes for ATM withdrawals without a card
7. **Find ATMs**: Locate nearby SiBeh Good Bank ATMs

## Important Guidelines

### Security & Verification
- For financial transactions (transfers, bill payments, withdrawals), always summarize the details clearly before execution
- Never ask for passwords, PINs, OTPs, or TAC codes - those are handled by the app's security layer
- If you detect anything suspicious, flag it and suggest contacting customer service

### Transaction Flow
1. When a user wants to make a transfer:
   - Ask for recipient details if not provided
   - Confirm the amount
   - Summarize the transfer before executing
   - Provide a clear confirmation after completion

2. When a user wants to pay a bill:
   - Help them identify the correct bill provider
   - Confirm the bill account number and amount
   - Execute and provide payment confirmation

### Malaysian Context
- Currency is Malaysian Ringgit (MYR), displayed as "RM"
- Format amounts as "RM X,XXX.XX"
- Common banks: Maybank, CIMB, Public Bank, RHB, Hong Leong, AmBank, Bank Islam, OCBC, UOB, HSBC
- Common bill providers: TNB (electricity), Air Selangor/SYABAS (water), TM Unifi (internet), Astro (TV)

### Response Format
- Use clear formatting with bullet points and sections when listing multiple items
- For transaction confirmations, include reference numbers
- Always offer follow-up assistance ("Is there anything else I can help you with?")

### Error Handling
- If a transaction fails, explain why in simple terms
- Suggest alternatives when possible
- For insufficient funds, show current balance and suggest a lower amount

## Remember
- You cannot access external systems beyond the provided tools
- You cannot modify account settings or update personal information
- For complex issues, suggest visiting a branch or calling the hotline: 1-300-88-1234

Be helpful, be safe, and make banking sibeh easy! 🏦"""


class ConversationMessage:
    """Represents a message in the conversation."""
    
    def __init__(self, role: str, content: str, tool_use: Optional[Dict] = None):
        self.role = role
        self.content = content
        self.tool_use = tool_use
        self.timestamp = datetime.now()
    
    def to_api_format(self) -> Dict[str, Any]:
        """Convert to Anthropic API format."""
        return {
            "role": self.role,
            "content": self.content
        }


class BankingAgent:
    """Main banking agent that handles conversations with Claude."""
    
    def __init__(self, user_id: str = "user-001"):
        self.client = Anthropic(api_key=settings.anthropic_api_key)
        self.user_id = user_id
        self.tool_executor = BankingToolExecutor(user_id)
        self.conversation_history: List[Dict[str, Any]] = []
        self.max_tool_iterations = 10
    
    def _build_messages(self, user_message: str) -> List[Dict[str, Any]]:
        """Build the messages array for the API call."""
        messages = self.conversation_history.copy()
        messages.append({
            "role": "user",
            "content": user_message
        })
        return messages
    
    def _process_tool_calls(self, tool_use_blocks: List[Any]) -> List[Dict[str, Any]]:
        """Process tool calls and return results."""
        results = []
        for tool_use in tool_use_blocks:
            tool_name = tool_use.name
            tool_input = tool_use.input
            tool_id = tool_use.id
            
            print(f"[Agent] Executing tool: {tool_name}")
            print(f"[Agent] Tool input: {json.dumps(tool_input, indent=2)}")
            
            result = self.tool_executor.execute_tool(tool_name, tool_input)
            
            print(f"[Agent] Tool result: {json.dumps(result, indent=2)[:500]}...")
            
            results.append({
                "type": "tool_result",
                "tool_use_id": tool_id,
                "content": json.dumps(result)
            })
        
        return results
    
    def chat(self, user_message: str) -> str:
        """
        Process a user message and return the assistant's response.
        Handles tool calls in a loop until the assistant provides a final response.
        """
        messages = self._build_messages(user_message)
        
        for iteration in range(self.max_tool_iterations):
            print(f"\n[Agent] Iteration {iteration + 1}")
            
            response = self.client.messages.create(
                model=settings.anthropic_model,
                max_tokens=settings.max_tokens,
                temperature=settings.temperature,
                system=SYSTEM_PROMPT,
                tools=BANKING_TOOLS,
                messages=messages
            )
            
            print(f"[Agent] Stop reason: {response.stop_reason}")
            
            # Extract content blocks
            assistant_content = []
            tool_use_blocks = []
            text_response = ""
            
            for block in response.content:
                if block.type == "text":
                    text_response += block.text
                    assistant_content.append({
                        "type": "text",
                        "text": block.text
                    })
                elif block.type == "tool_use":
                    tool_use_blocks.append(block)
                    assistant_content.append({
                        "type": "tool_use",
                        "id": block.id,
                        "name": block.name,
                        "input": block.input
                    })
            
            # Add assistant message to conversation
            messages.append({
                "role": "assistant",
                "content": assistant_content
            })
            
            # If no tool calls, we're done
            if response.stop_reason == "end_turn" or not tool_use_blocks:
                # Update conversation history
                self.conversation_history.append({
                    "role": "user",
                    "content": user_message
                })
                self.conversation_history.append({
                    "role": "assistant",
                    "content": text_response
                })
                return text_response
            
            # Process tool calls
            tool_results = self._process_tool_calls(tool_use_blocks)
            
            # Add tool results to messages
            messages.append({
                "role": "user",
                "content": tool_results
            })
        
        return "I apologize, but I'm having trouble completing your request. Please try again or contact customer service."
    
    def chat_stream(self, user_message: str) -> Generator[str, None, None]:
        """
        Process a user message and stream the assistant's response.
        Yields text chunks as they arrive.
        """
        messages = self._build_messages(user_message)
        
        for iteration in range(self.max_tool_iterations):
            print(f"\n[Agent] Stream Iteration {iteration + 1}")
            
            # For tool use, we need to use non-streaming first to handle tools
            response = self.client.messages.create(
                model=settings.anthropic_model,
                max_tokens=settings.max_tokens,
                temperature=settings.temperature,
                system=SYSTEM_PROMPT,
                tools=BANKING_TOOLS,
                messages=messages
            )
            
            # Extract content blocks
            assistant_content = []
            tool_use_blocks = []
            text_response = ""
            
            for block in response.content:
                if block.type == "text":
                    text_response += block.text
                    assistant_content.append({
                        "type": "text",
                        "text": block.text
                    })
                elif block.type == "tool_use":
                    tool_use_blocks.append(block)
                    assistant_content.append({
                        "type": "tool_use",
                        "id": block.id,
                        "name": block.name,
                        "input": block.input
                    })
            
            # Add assistant message to conversation
            messages.append({
                "role": "assistant",
                "content": assistant_content
            })
            
            # If we have tool calls, process them
            if tool_use_blocks:
                # Process tool calls
                tool_results = self._process_tool_calls(tool_use_blocks)
                
                # Add tool results to messages
                messages.append({
                    "role": "user",
                    "content": tool_results
                })
                continue
            
            # No more tool calls - now stream the final response
            # Update conversation history first
            self.conversation_history.append({
                "role": "user",
                "content": user_message
            })
            
            # Stream the response
            full_response = ""
            with self.client.messages.stream(
                model=settings.anthropic_model,
                max_tokens=settings.max_tokens,
                temperature=settings.temperature,
                system=SYSTEM_PROMPT,
                messages=messages[:-1] + [{"role": "user", "content": user_message}]  # Fresh request for streaming
            ) as stream:
                for text in stream.text_stream:
                    full_response += text
                    yield text
            
            self.conversation_history.append({
                "role": "assistant",
                "content": full_response
            })
            return
        
        yield "I apologize, but I'm having trouble completing your request. Please try again."
    
    def clear_history(self):
        """Clear conversation history."""
        self.conversation_history = []
    
    def get_history(self) -> List[Dict[str, Any]]:
        """Get conversation history."""
        return [
            {
                "role": msg["role"],
                "content": msg["content"],
            }
            for msg in self.conversation_history
        ]


# Factory function for creating agents
def create_agent(user_id: str = "user-001") -> BankingAgent:
    """Create a new banking agent for a user."""
    return BankingAgent(user_id)


# Example usage
if __name__ == "__main__":
    agent = create_agent()
    
    print("=" * 50)
    print("SiBeh Good Bank AI Assistant")
    print("=" * 50)
    print("Type 'quit' to exit, 'clear' to clear history\n")
    
    while True:
        user_input = input("You: ").strip()
        
        if not user_input:
            continue
        
        if user_input.lower() == "quit":
            print("Goodbye! Thank you for banking with SiBeh Good Bank!")
            break
        
        if user_input.lower() == "clear":
            agent.clear_history()
            print("[History cleared]\n")
            continue
        
        print("\nAssistant: ", end="", flush=True)
        response = agent.chat(user_input)
        print(response)
        print()
