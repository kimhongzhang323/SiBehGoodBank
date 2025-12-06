"""
FastAPI Application for the AI Banking Agent.
Provides REST API endpoints for the chatbot functionality.
"""
import uuid
import asyncio
from typing import Dict, Optional
from datetime import datetime
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, BackgroundTasks, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, Response
from pydantic import BaseModel
import base64

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
    ChartGenerationRequest,
    SpendingChartResponse,
    BalanceTrendChartResponse,
    IncomeExpenseChartResponse,
    TransactionTimelineResponse,
    MonthlySummaryChartResponse,
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
    - Generating financial charts and analytics
    """
    try:
        agent, session_id = get_or_create_agent(
            request.user_id,
            request.session_id
        )
        
        # Run chat in thread pool to not block
        loop = asyncio.get_event_loop()
        response_data = await loop.run_in_executor(
            None,
            agent.chat,
            request.message
        )
        
        # Schedule cleanup
        background_tasks.add_task(cleanup_old_sessions)
        
        # Handle both old string return and new dict return format
        if isinstance(response_data, str):
            response_text = response_data
            chart_images = None
        else:
            response_text = response_data.get("message", "")
            chart_images = response_data.get("chart_images")
        
        return ChatResponse(
            message=response_text,
            user_id=request.user_id,
            session_id=session_id,
            timestamp=datetime.now(),
            chart_images=chart_images
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


# Graph/Chart Generation Endpoints
@app.get("/api/v1/charts/spending", tags=["Charts & Analytics"])
async def get_spending_chart(
    user_id: str = Query(default="user-001", description="User ID"),
    account_id: Optional[str] = Query(default=None, description="Account ID to analyze"),
    days: int = Query(default=30, ge=1, le=365, description="Number of days to analyze"),
    chart_type: str = Query(default="pie", description="Chart type: pie, bar, or horizontal_bar"),
    format: str = Query(default="json", description="Response format: json or image")
):
    """
    Generate a spending breakdown chart showing expenses by category.
    
    Returns either JSON with base64 encoded image or direct PNG image.
    """
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    result = executor.execute_tool("generate_spending_chart", {
        "account_id": account_id,
        "days": days,
        "chart_type": chart_type
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    if format == "image":
        # Return image directly
        image_data = base64.b64decode(result["chart_image_base64"])
        return Response(content=image_data, media_type="image/png")
    
    return result


@app.get("/api/v1/charts/balance-trend", tags=["Charts & Analytics"])
async def get_balance_trend_chart(
    user_id: str = Query(default="user-001", description="User ID"),
    account_id: Optional[str] = Query(default=None, description="Account ID to analyze"),
    days: int = Query(default=30, ge=1, le=365, description="Number of days to show"),
    format: str = Query(default="json", description="Response format: json or image")
):
    """
    Generate a balance trend chart showing account balance over time.
    
    Returns either JSON with base64 encoded image or direct PNG image.
    """
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    result = executor.execute_tool("generate_balance_trend_chart", {
        "account_id": account_id,
        "days": days
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    if format == "image":
        image_data = base64.b64decode(result["chart_image_base64"])
        return Response(content=image_data, media_type="image/png")
    
    return result


@app.get("/api/v1/charts/income-expense", tags=["Charts & Analytics"])
async def get_income_expense_chart(
    user_id: str = Query(default="user-001", description="User ID"),
    account_id: Optional[str] = Query(default=None, description="Account ID to analyze"),
    days: int = Query(default=30, ge=1, le=365, description="Number of days to analyze"),
    chart_type: str = Query(default="bar", description="Chart type: bar, stacked, or comparison"),
    format: str = Query(default="json", description="Response format: json or image")
):
    """
    Generate an income vs expenses comparison chart.
    
    Returns either JSON with base64 encoded image or direct PNG image.
    """
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    result = executor.execute_tool("generate_income_expense_chart", {
        "account_id": account_id,
        "days": days,
        "chart_type": chart_type
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    if format == "image":
        image_data = base64.b64decode(result["chart_image_base64"])
        return Response(content=image_data, media_type="image/png")
    
    return result


@app.get("/api/v1/charts/transaction-timeline", tags=["Charts & Analytics"])
async def get_transaction_timeline_chart(
    user_id: str = Query(default="user-001", description="User ID"),
    account_id: Optional[str] = Query(default=None, description="Account ID to analyze"),
    days: int = Query(default=14, ge=1, le=60, description="Number of days to show"),
    format: str = Query(default="json", description="Response format: json or image")
):
    """
    Generate a transaction timeline chart showing daily transaction patterns.
    
    Returns either JSON with base64 encoded image or direct PNG image.
    """
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    result = executor.execute_tool("generate_transaction_timeline_chart", {
        "account_id": account_id,
        "days": days
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    if format == "image":
        image_data = base64.b64decode(result["chart_image_base64"])
        return Response(content=image_data, media_type="image/png")
    
    return result


@app.get("/api/v1/charts/monthly-summary", tags=["Charts & Analytics"])
async def get_monthly_summary_chart(
    user_id: str = Query(default="user-001", description="User ID"),
    account_id: Optional[str] = Query(default=None, description="Account ID to analyze"),
    months: int = Query(default=6, ge=1, le=12, description="Number of months to show"),
    format: str = Query(default="json", description="Response format: json or image")
):
    """
    Generate a comprehensive monthly financial summary chart.
    
    Returns either JSON with base64 encoded image or direct PNG image.
    """
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    result = executor.execute_tool("generate_monthly_summary_chart", {
        "account_id": account_id,
        "months": months
    })
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    if format == "image":
        image_data = base64.b64decode(result["chart_image_base64"])
        return Response(content=image_data, media_type="image/png")
    
    return result


@app.get("/api/v1/analytics/summary", tags=["Charts & Analytics"])
async def get_analytics_summary(
    user_id: str = Query(default="user-001", description="User ID"),
    account_id: Optional[str] = Query(default=None, description="Account ID to analyze"),
    days: int = Query(default=30, ge=1, le=365, description="Number of days to analyze")
):
    """
    Get a comprehensive analytics summary without charts.
    
    Returns spending breakdown, income/expense summary, and key financial metrics.
    """
    from tools import BankingToolExecutor
    
    executor = BankingToolExecutor(user_id)
    
    # Get spending data
    spending_result = executor.execute_tool("generate_spending_chart", {
        "account_id": account_id,
        "days": days,
        "chart_type": "pie"
    })
    
    # Get income/expense data
    income_expense_result = executor.execute_tool("generate_income_expense_chart", {
        "account_id": account_id,
        "days": days,
        "chart_type": "comparison"
    })
    
    # Get balance data
    balance_result = executor.execute_tool("generate_balance_trend_chart", {
        "account_id": account_id,
        "days": days
    })
    
    summary = {
        "period_days": days,
        "currency": "MYR",
        "spending_summary": {
            "total_spending": spending_result.get("total_spending", 0),
            "categories": spending_result.get("categories", [])
        } if "error" not in spending_result else None,
        "cash_flow_summary": {
            "total_income": income_expense_result.get("total_income", 0),
            "total_expenses": income_expense_result.get("total_expenses", 0),
            "net_cash_flow": income_expense_result.get("net_cash_flow", 0),
            "savings_rate": income_expense_result.get("savings_rate", 0)
        } if "error" not in income_expense_result else None,
        "balance_summary": {
            "current_balance": balance_result.get("current_balance", 0),
            "min_balance": balance_result.get("min_balance", 0),
            "max_balance": balance_result.get("max_balance", 0),
            "average_balance": balance_result.get("average_balance", 0),
            "balance_change": balance_result.get("balance_change", 0)
        } if "error" not in balance_result else None
    }
    
    return summary


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
