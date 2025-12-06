"""
Analytics Service - Main FastAPI application.
Provides spending analytics, budgeting, forecasting, and financial health assessment.
"""
from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import structlog
from datetime import date, timedelta
from typing import Optional, List, Dict, Any

from config import settings
from models import (
    AnalyticsRequest, BudgetRequest, ForecastRequest,
    SpendingAnalyticsResponse, BudgetSummary, CashFlowForecast,
    FinancialHealthScore, AnomalyDetection, TimeRange
)
from analytics_engine import analytics_engine
from mock_data import MockTransactionData

# Configure structured logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.stdlib.add_log_level,
        structlog.processors.JSONRenderer()
    ]
)
logger = structlog.get_logger()

# Mock data service (in production, this would be an API call)
mock_data = MockTransactionData()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    logger.info("Starting Analytics Service", version=settings.service_version)
    yield
    logger.info("Shutting down Analytics Service")


app = FastAPI(
    title="SiBeh Good Bank - Analytics Service",
    description="Financial analytics, budgeting, and insights service",
    version=settings.service_version,
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check
@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": settings.service_name,
        "version": settings.service_version,
    }


# ===== SPENDING ANALYTICS =====

@app.get("/api/analytics/spending", response_model=SpendingAnalyticsResponse)
async def get_spending_analytics(
    user_id: str = Query(..., description="User ID"),
    start_date: Optional[date] = Query(None, description="Start date"),
    end_date: Optional[date] = Query(None, description="End date"),
    time_range: TimeRange = Query(TimeRange.MONTHLY, description="Time range"),
):
    """
    Get comprehensive spending analytics.
    
    Returns detailed spending breakdown by category, trends over time,
    and AI-generated insights.
    """
    try:
        # Default to last 30 days if no dates provided
        if not end_date:
            end_date = date.today()
        if not start_date:
            if time_range == TimeRange.WEEKLY:
                start_date = end_date - timedelta(days=7)
            elif time_range == TimeRange.MONTHLY:
                start_date = end_date - timedelta(days=30)
            elif time_range == TimeRange.QUARTERLY:
                start_date = end_date - timedelta(days=90)
            elif time_range == TimeRange.YEARLY:
                start_date = end_date - timedelta(days=365)
            else:
                start_date = end_date - timedelta(days=1)
        
        # Get transactions (mock data for now)
        transactions = mock_data.get_transactions(user_id)
        
        # Analyze spending
        result = analytics_engine.analyze_spending(transactions, start_date, end_date)
        
        logger.info(
            "Spending analytics generated",
            user_id=user_id,
            start_date=str(start_date),
            end_date=str(end_date),
        )
        
        return result
        
    except Exception as e:
        logger.error("Error generating spending analytics", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/analytics/spending")
async def analyze_spending_with_transactions(
    request: AnalyticsRequest,
    transactions: List[Dict[str, Any]],
):
    """
    Analyze spending with provided transaction data.
    
    Useful for custom analysis with specific transaction sets.
    """
    try:
        result = analytics_engine.analyze_spending(
            transactions,
            request.start_date,
            request.end_date,
        )
        return result
    except Exception as e:
        logger.error("Error analyzing spending", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== BUDGET MANAGEMENT =====

@app.get("/api/analytics/budget", response_model=BudgetSummary)
async def get_budget_analysis(
    user_id: str = Query(..., description="User ID"),
    month: str = Query(..., description="Month in YYYY-MM format"),
):
    """
    Get budget analysis for a specific month.
    
    Returns spending vs budget comparison with recommendations.
    """
    try:
        # Get user's budget (mock data for now)
        budgets = mock_data.get_user_budgets(user_id)
        transactions = mock_data.get_transactions(user_id)
        
        result = analytics_engine.analyze_budget(transactions, budgets, month)
        
        logger.info("Budget analysis generated", user_id=user_id, month=month)
        
        return result
        
    except Exception as e:
        logger.error("Error generating budget analysis", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/analytics/budget")
async def create_budget(request: BudgetRequest):
    """
    Create or update a monthly budget.
    """
    try:
        # In production, save to database
        mock_data.set_user_budgets(request.user_id, request.budgets)
        
        logger.info(
            "Budget created/updated",
            user_id=request.user_id,
            month=request.month,
            categories=len(request.budgets),
        )
        
        return {
            "success": True,
            "message": f"Budget for {request.month} saved successfully",
            "budgets": request.budgets,
        }
        
    except Exception as e:
        logger.error("Error creating budget", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== CASH FLOW FORECAST =====

@app.get("/api/analytics/forecast")
async def get_cash_flow_forecast(
    user_id: str = Query(..., description="User ID"),
    months: int = Query(3, ge=1, le=12, description="Months to forecast"),
):
    """
    Get cash flow forecast for upcoming months.
    
    Uses machine learning to predict income and expenses based on
    historical patterns.
    """
    try:
        transactions = mock_data.get_transactions(user_id)
        
        forecasts = analytics_engine.forecast_cash_flow(transactions, months)
        
        logger.info(
            "Cash flow forecast generated",
            user_id=user_id,
            months=months,
            forecasts=len(forecasts),
        )
        
        return {
            "user_id": user_id,
            "forecasts": forecasts,
            "generated_at": date.today().isoformat(),
        }
        
    except Exception as e:
        logger.error("Error generating forecast", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== FINANCIAL HEALTH =====

@app.get("/api/analytics/health", response_model=FinancialHealthScore)
async def get_financial_health(
    user_id: str = Query(..., description="User ID"),
    account_balance: float = Query(..., description="Current account balance"),
):
    """
    Get comprehensive financial health assessment.
    
    Returns overall score, component scores, and actionable recommendations.
    """
    try:
        transactions = mock_data.get_transactions(user_id)
        
        result = analytics_engine.calculate_financial_health(transactions, account_balance)
        
        logger.info(
            "Financial health calculated",
            user_id=user_id,
            score=result.overall_score,
            grade=result.grade,
        )
        
        return result
        
    except Exception as e:
        logger.error("Error calculating financial health", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== ANOMALY DETECTION =====

@app.get("/api/analytics/anomalies")
async def detect_anomalies(
    user_id: str = Query(..., description="User ID"),
):
    """
    Detect unusual transactions.
    
    Uses machine learning to identify spending anomalies that might
    indicate fraud or unusual behavior.
    """
    try:
        transactions = mock_data.get_transactions(user_id)
        
        anomalies = analytics_engine.detect_anomalies(transactions)
        
        logger.info(
            "Anomaly detection completed",
            user_id=user_id,
            anomalies_found=len(anomalies),
        )
        
        return {
            "user_id": user_id,
            "anomalies": anomalies,
            "total_found": len(anomalies),
            "analyzed_at": date.today().isoformat(),
        }
        
    except Exception as e:
        logger.error("Error detecting anomalies", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== CATEGORY INSIGHTS =====

@app.get("/api/analytics/categories/{category}")
async def get_category_details(
    category: str,
    user_id: str = Query(..., description="User ID"),
    months: int = Query(6, ge=1, le=24, description="Months of history"),
):
    """
    Get detailed analytics for a specific spending category.
    """
    try:
        transactions = mock_data.get_transactions(user_id)
        
        # Filter by category
        category_transactions = [
            t for t in transactions
            if analytics_engine.categorize_transaction(t.get('description', '')) == category
        ]
        
        if not category_transactions:
            return {
                "category": category,
                "message": "No transactions found for this category",
            }
        
        # Calculate category-specific stats
        import pandas as pd
        df = pd.DataFrame(category_transactions)
        df['date'] = pd.to_datetime(df['date'])
        
        return {
            "category": category,
            "total_spent": round(df['amount'].sum(), 2),
            "average_transaction": round(df['amount'].mean(), 2),
            "transaction_count": len(df),
            "max_transaction": round(df['amount'].max(), 2),
            "min_transaction": round(df['amount'].min(), 2),
            "monthly_average": round(df['amount'].sum() / max(1, len(df['date'].dt.to_period('M').unique())), 2),
            "top_merchants": df.groupby('description')['amount'].sum().nlargest(5).to_dict(),
        }
        
    except Exception as e:
        logger.error("Error getting category details", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== COMPARISON TOOLS =====

@app.get("/api/analytics/compare")
async def compare_periods(
    user_id: str = Query(..., description="User ID"),
    period1_start: date = Query(..., description="First period start"),
    period1_end: date = Query(..., description="First period end"),
    period2_start: date = Query(..., description="Second period start"),
    period2_end: date = Query(..., description="Second period end"),
):
    """
    Compare spending between two time periods.
    """
    try:
        transactions = mock_data.get_transactions(user_id)
        
        # Analyze both periods
        analysis1 = analytics_engine.analyze_spending(transactions, period1_start, period1_end)
        analysis2 = analytics_engine.analyze_spending(transactions, period2_start, period2_end)
        
        # Calculate changes
        expense_change = analysis2.total_expenses - analysis1.total_expenses
        expense_change_pct = (expense_change / analysis1.total_expenses * 100) if analysis1.total_expenses > 0 else 0
        
        income_change = analysis2.total_income - analysis1.total_income
        income_change_pct = (income_change / analysis1.total_income * 100) if analysis1.total_income > 0 else 0
        
        return {
            "period_1": {
                "start": period1_start,
                "end": period1_end,
                "total_expenses": analysis1.total_expenses,
                "total_income": analysis1.total_income,
                "savings_rate": analysis1.savings_rate,
            },
            "period_2": {
                "start": period2_start,
                "end": period2_end,
                "total_expenses": analysis2.total_expenses,
                "total_income": analysis2.total_income,
                "savings_rate": analysis2.savings_rate,
            },
            "changes": {
                "expense_change": round(expense_change, 2),
                "expense_change_percent": round(expense_change_pct, 2),
                "income_change": round(income_change, 2),
                "income_change_percent": round(income_change_pct, 2),
                "savings_rate_change": round(analysis2.savings_rate - analysis1.savings_rate, 2),
            },
            "insights": [
                f"Expenses {'increased' if expense_change > 0 else 'decreased'} by {abs(expense_change_pct):.1f}%",
                f"Income {'increased' if income_change > 0 else 'decreased'} by {abs(income_change_pct):.1f}%",
            ],
        }
        
    except Exception as e:
        logger.error("Error comparing periods", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
