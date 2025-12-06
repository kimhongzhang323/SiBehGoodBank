# SiBeh Good Bank - AI Agent Service (Python)

A Python-based AI banking assistant service powered by Anthropic Claude. This service provides intelligent chatbot capabilities for the SiBeh Good Bank mobile application.

## 🌟 Features

### AI-Powered Banking Assistant
- **Natural Language Understanding**: Understands user queries in natural language
- **Contextual Conversations**: Maintains conversation history for context-aware responses
- **Tool-Based Actions**: Executes banking operations through defined tools

### Banking Capabilities
| Feature | Description |
|---------|-------------|
| 💰 **Balance Inquiry** | Check single or all account balances |
| 📊 **Transaction History** | View recent transactions with filters |
| 💸 **Fund Transfer** | Transfer money to other accounts |
| 📱 **Bill Payment** | Pay utility bills, telco, subscriptions |
| 💱 **Exchange Rates** | Get real-time forex rates |
| 🏦 **Loan Calculator** | Calculate EMI, interest, total repayment |
| 🏧 **Cardless Withdrawal** | Generate ATM withdrawal codes |
| 📍 **ATM Locator** | Find nearby bank ATMs |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    FastAPI Server                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │              REST API Endpoints                  │   │
│  │  /chat  /chat/stream  /health  /api/v1/*        │   │
│  └────────────────────┬────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼────────────────────────────┐   │
│  │              Banking Agent                       │   │
│  │  • Conversation Management                       │   │
│  │  • Tool Orchestration                           │   │
│  │  • Response Generation                          │   │
│  └────────────────────┬────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼────────────────────────────┐   │
│  │           Anthropic Claude API                   │   │
│  │  • Natural Language Processing                   │   │
│  │  • Tool Call Decisions                          │   │
│  │  • Response Synthesis                           │   │
│  └────────────────────┬────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼────────────────────────────┐   │
│  │             Banking Tools                        │   │
│  │  check_balance | transfer_funds | pay_bill       │   │
│  │  get_transactions | calculate_loan | etc.        │   │
│  └────────────────────┬────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼────────────────────────────┐   │
│  │           Mock Data Service                      │   │
│  │  (Replace with real backend integration)         │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
ai-agent-python/
├── main.py              # FastAPI application & endpoints
├── agent.py             # Core banking agent with Claude
├── tools.py             # Banking tool definitions & executor
├── mock_data.py         # Mock data service for testing
├── models.py            # Pydantic request/response models
├── config.py            # Configuration management
├── requirements.txt     # Python dependencies
├── .env.example         # Environment variables template
└── README.md            # This file
```

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- Anthropic API key

### Installation

1. **Clone and navigate to the service**
   ```bash
   cd backend/ai-agent-python
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   
   # Windows
   .\venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env and add your ANTHROPIC_API_KEY
   ```

5. **Run the service**
   ```bash
   python main.py
   ```

   Or with uvicorn directly:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8084
   ```

### Access the API
- **API Documentation**: http://localhost:8084/docs
- **ReDoc**: http://localhost:8084/redoc
- **Health Check**: http://localhost:8084/health

## 📡 API Endpoints

### Chat Endpoints

#### POST `/api/v1/chat`
Send a message and receive a complete response.

```bash
curl -X POST "http://localhost:8084/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "What is my account balance?", "user_id": "user-001"}'
```

**Response:**
```json
{
  "message": "Your Main Savings account balance is **RM 15,847.50**. Would you like to see all your accounts?",
  "user_id": "user-001",
  "session_id": "abc-123-def",
  "timestamp": "2024-01-15T10:30:00"
}
```

#### POST `/api/v1/chat/stream`
Send a message and receive a streaming response (SSE).

```bash
curl -X POST "http://localhost:8084/api/v1/chat/stream" \
  -H "Content-Type: application/json" \
  -d '{"message": "Transfer RM100 to John", "user_id": "user-001"}'
```

### Banking Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/accounts/balance` | Get account balance |
| GET | `/api/v1/accounts/transactions` | Get transaction history |
| GET | `/api/v1/exchange-rates` | Get forex rates |
| POST | `/api/v1/loan/calculate` | Calculate loan details |
| GET | `/api/v1/bills/categories` | Get bill providers |
| GET | `/api/v1/atms/nearby` | Find nearby ATMs |

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ANTHROPIC_API_KEY` | Your Anthropic API key | Required |
| `ANTHROPIC_MODEL` | Claude model to use | `claude-sonnet-4-20250514` |
| `MAX_TOKENS` | Maximum response tokens | `4096` |
| `TEMPERATURE` | Response creativity (0-1) | `0.7` |
| `SERVER_HOST` | Server bind address | `0.0.0.0` |
| `SERVER_PORT` | Server port | `8084` |
| `DEBUG` | Enable debug mode | `false` |

## 🛠️ Available Tools

The agent has access to the following tools:

| Tool | Description |
|------|-------------|
| `check_balance` | Check account balances |
| `get_transactions` | Retrieve transaction history |
| `transfer_funds` | Transfer money between accounts |
| `pay_bill` | Pay utility and service bills |
| `get_contacts` | Get saved transfer recipients |
| `get_pending_bills` | Get bills due for payment |
| `get_exchange_rate` | Get forex exchange rates |
| `calculate_loan` | Calculate loan repayments |
| `get_bill_categories` | List bill payment providers |
| `get_banks` | List supported banks |
| `get_account_details` | Get detailed account info |
| `initiate_withdrawal` | Generate cardless ATM code |
| `get_nearby_atms` | Find nearby ATM locations |

## 💬 Example Conversations

### Balance Inquiry
```
User: "What's my balance?"
Assistant: "Your Main Savings account has a balance of **RM 15,847.50**. 
           Would you like to see all your accounts?"
```

### Fund Transfer
```
User: "Transfer RM500 to Ahmad"
Assistant: "I found Ahmad Razak in your contacts. Let me confirm the transfer:
           
           📤 **Transfer Details**
           • From: Main Savings (****1234)
           • To: Ahmad Razak - Maybank (****5678)
           • Amount: RM 500.00
           
           Should I proceed with this transfer?"

User: "Yes"
Assistant: "✅ Transfer successful!
           
           Reference: TRF20240115-ABC123
           Amount: RM 500.00
           New Balance: RM 15,347.50
           
           Is there anything else I can help you with?"
```

### Bill Payment
```
User: "Pay my TNB bill"
Assistant: "I found your TNB electricity bill:
           
           📋 **Bill Details**
           • Account: 123456789
           • Amount Due: RM 187.50
           • Due Date: 20 Jan 2024
           
           Would you like to pay this amount?"
```

## 🔌 Integration Guide

### Connecting to Real Backend

Replace `mock_data.py` with real service calls:

```python
# In tools.py, modify BankingToolExecutor

class BankingToolExecutor:
    def __init__(self, user_id: str):
        self.user_id = user_id
        # Replace mock service with real HTTP client
        self.account_service = AccountServiceClient("http://account-service:8082")
        self.transaction_service = TransactionServiceClient("http://transaction-service:8083")
    
    def _check_balance(self, params):
        # Call real account service
        return self.account_service.get_balance(self.user_id, params.get("account_id"))
```

### Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8084

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8084"]
```

## 🧪 Testing

### Run the CLI Agent
```bash
python agent.py
```

### Test API with curl
```bash
# Health check
curl http://localhost:8084/health

# Chat
curl -X POST http://localhost:8084/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'
```

## 📊 Monitoring

The service logs all tool executions:
```
[Agent] Iteration 1
[Agent] Executing tool: check_balance
[Agent] Tool input: {"show_all": true}
[Agent] Tool result: {"accounts": [...], "total_balance": 69081.50}
[Agent] Stop reason: end_turn
```

## 🔒 Security Notes

- Never log sensitive data (account numbers, balances in production)
- Implement proper authentication (JWT, OAuth)
- Add rate limiting for API endpoints
- Validate all user inputs
- Use HTTPS in production

## 📄 License

MIT License - See LICENSE file for details.

---

**SiBeh Good Bank** - Making Banking Sibeh Easy! 🏦
