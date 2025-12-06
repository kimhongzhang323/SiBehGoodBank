"""
FastAPI Application for the AI Banking Agent.
Provides REST API endpoints for the chatbot functionality.
"""
import uuid
import asyncio
from typing import Dict
from datetime import datetime
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

from config import settings
from agent import BankingAgent, create_agent
from models import (
    ChatRequest,
    ChatResponse,
    StreamChatRequest,
    ClearHistoryRequest,
    ConversationHistory,
    ChatMessage,
    HealthResponse,
    ErrorResponse,
    MessageRole,
)


# Session storage for agents (in production, use Redis or database)
agent_sessions: Dict[str, BankingAgent] = {}


def get_or_create_agent(user_id: str, session_id: str = None) -> tuple[BankingAgent, str]:
    """Get existing agent or create new one for the session."""
    if session_id and session_id in agent_sessions:
        return agent_sessions[session_id], session_id
    
    # Create new session
    new_session_id = session_id or str(uuid.uuid4())
    agent = create_agent(user_id)
    agent_sessions[new_session_id] = agent
    
    return agent, new_session_id


def cleanup_old_sessions():
    """Clean up old sessions (called periodically)."""
    # In production, implement proper session expiration
    if len(agent_sessions) > 1000:
        # Remove oldest half
        sessions_to_remove = list(agent_sessions.keys())[:500]
        for session_id in sessions_to_remove:
            del agent_sessions[session_id]


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    print("🚀 Starting SiBeh Good Bank AI Agent Service...")
    print(f"   Model: {settings.anthropic_model}")
    print(f"   Server: {settings.server_host}:{settings.server_port}")
    yield
    print("👋 Shutting down AI Agent Service...")
    agent_sessions.clear()


# Create FastAPI app
app = FastAPI(
    title="SiBeh Good Bank AI Agent API",
    description="AI-powered banking assistant using Anthropic Claude",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health Check Endpoints
@app.get("/", response_model=HealthResponse, tags=["Health"])
async def root():
    """Root endpoint - health check."""
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        timestamp=datetime.now()
    )


@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """Health check endpoint."""
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        timestamp=datetime.now()
    )


@app.get("/api/v1/health", response_model=HealthResponse, tags=["Health"])
async def api_health_check():
    """API v1 health check endpoint."""
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        timestamp=datetime.now()
    )


# Chat Endpoints
@app.post("/api/v1/chat", response_model=ChatResponse, tags=["Chat"])
async def chat(request: ChatRequest, background_tasks: BackgroundTasks):
    """
    Send a message to the AI banking assistant.
    
    The assistant can help with:
    - Checking account balances
    - Viewing transaction history
    - Making transfers
    - Paying bills
    - Currency exchange rates
    - Loan calculations
    - Cardless withdrawals
    - Finding nearby ATMs
    """
    try:
        agent, session_id = get_or_create_agent(
            request.user_id,
            request.session_id
        )
        
        # Run chat in thread pool to not block
        loop = asyncio.get_event_loop()
        response_text = await loop.run_in_executor(
            None,
            agent.chat,
            request.message
        )
        
        # Schedule cleanup
        background_tasks.add_task(cleanup_old_sessions)
        
        return ChatResponse(
            message=response_text,
            user_id=request.user_id,
            session_id=session_id,
            timestamp=datetime.now()
        )
    
    except Exception as e:
        print(f"[Error] Chat error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process message: {str(e)}"
        )


@app.post("/api/v1/chat/stream", tags=["Chat"])
async def chat_stream(request: StreamChatRequest):
    """
    Send a message and receive a streaming response.
    
    Returns a Server-Sent Events (SSE) stream with the assistant's response.
    """
    try:
        agent, session_id = get_or_create_agent(
            request.user_id,
            request.session_id
        )
        
        async def generate():
            """Generate streaming response."""
            try:
                for chunk in agent.chat_stream(request.message):
                    yield f"data: {chunk}\n\n"
                yield "data: [DONE]\n\n"
            except Exception as e:
                yield f"data: [ERROR] {str(e)}\n\n"
        
        return StreamingResponse(
            generate(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
                "X-Session-Id": session_id,
            }
        )
    
    except Exception as e:
        print(f"[Error] Stream error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to start stream: {str(e)}"
        )


# History Endpoints
@app.get("/api/v1/chat/history/{session_id}", response_model=ConversationHistory, tags=["Chat"])
async def get_chat_history(session_id: str, user_id: str = "user-001"):
    """Get conversation history for a session."""
    if session_id not in agent_sessions:
        raise HTTPException(
            status_code=404,
            detail="Session not found"
        )
    
    agent = agent_sessions[session_id]
    history = agent.get_history()
    
    messages = [
        ChatMessage(
            role=MessageRole(msg["role"]),
            content=msg["content"],
            timestamp=datetime.now()
        )
        for msg in history
    ]
    
    return ConversationHistory(
        user_id=user_id,
        messages=messages,
        message_count=len(messages)
    )


@app.delete("/api/v1/chat/history", tags=["Chat"])
async def clear_chat_history(request: ClearHistoryRequest):
    """Clear conversation history for a session."""
    if request.session_id and request.session_id in agent_sessions:
        agent_sessions[request.session_id].clear_history()
        return {"message": "History cleared", "session_id": request.session_id}
    
    # Clear all sessions for user (not recommended in production)
    return {"message": "No session to clear"}


# Direct Tool Endpoints (optional - for direct API access without chat)
@app.get("/api/v1/accounts/balance", tags=["Banking"])
async def get_balance(user_id: str = "user-001", account_id: str = None, show_all: bool = False):
    """Get account balance directly without chat."""
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    result = executor.execute_tool("check_balance", {
        "account_id": account_id,
        "show_all": show_all
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@app.get("/api/v1/accounts/transactions", tags=["Banking"])
async def get_transactions(
    user_id: str = "user-001",
    account_id: str = None,
    limit: int = 10,
    transaction_type: str = None
):
    """Get transaction history directly without chat."""
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    result = executor.execute_tool("get_transactions", {
        "account_id": account_id,
        "limit": limit,
        "transaction_type": transaction_type
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@app.get("/api/v1/exchange-rates", tags=["Banking"])
async def get_exchange_rates(currency: str = None, show_all: bool = True):
    """Get currency exchange rates."""
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor()
    result = executor.execute_tool("get_exchange_rate", {
        "currency": currency,
        "show_all": show_all
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@app.post("/api/v1/loan/calculate", tags=["Banking"])
async def calculate_loan(principal: float, annual_rate: float, tenure_months: int):
    """Calculate loan repayment details."""
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor()
    result = executor.execute_tool("calculate_loan", {
        "principal": principal,
        "annual_rate": annual_rate,
        "tenure_months": tenure_months
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@app.get("/api/v1/bills/categories", tags=["Banking"])
async def get_bill_categories():
    """Get available bill payment categories and providers."""
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor()
    result = executor.execute_tool("get_bill_categories", {})
    
    return result


@app.get("/api/v1/atms/nearby", tags=["Banking"])
async def get_nearby_atms(latitude: float = None, longitude: float = None, limit: int = 5):
    """Get nearby ATM locations."""
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor()
    result = executor.execute_tool("get_nearby_atms", {
        "latitude": latitude,
        "longitude": longitude,
        "limit": limit
    })
    
    return result


# Run the application
if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host=settings.server_host,
        port=settings.server_port,
        reload=settings.debug,
        log_level="info"
    )
