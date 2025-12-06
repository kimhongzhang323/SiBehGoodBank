"""
Data models for Analytics Service.
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime, date
from enum import Enum


class TimeRange(str, Enum):
    """Time range options for analytics."""
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    QUARTERLY = "quarterly"
    YEARLY = "yearly"


class SpendingCategory(str, Enum):
    """Spending categories."""
    FOOD_DINING = "food_dining"
    GROCERIES = "groceries"
    TRANSPORTATION = "transportation"
    UTILITIES = "utilities"
    ENTERTAINMENT = "entertainment"
    SHOPPING = "shopping"
    HEALTHCARE = "healthcare"
    EDUCATION = "education"
    TRAVEL = "travel"
    BILLS = "bills"
    TRANSFERS = "transfers"
    INVESTMENTS = "investments"
    OTHER = "other"


class Transaction(BaseModel):
    """Transaction model for analysis."""
    transaction_id: str
    account_id: str
    type: str  # credit, debit, transfer, etc.
    amount: float
    currency: str = "MYR"
    description: str
    category: Optional[str] = None
    merchant_name: Optional[str] = None
    date: datetime
    

class SpendingByCategory(BaseModel):
    """Spending breakdown by category."""
    category: str
    amount: float
    percentage: float
    transaction_count: int
    average_transaction: float


class SpendingTrend(BaseModel):
    """Spending trend over time."""
    period: str  # e.g., "2024-01", "Week 1", etc.
    total_spending: float
    total_income: float
    net_flow: float
    categories: Dict[str, float]


class SpendingAnalyticsResponse(BaseModel):
    """Complete spending analytics response."""
    period_start: date
    period_end: date
    total_income: float
    total_expenses: float
    net_savings: float
    savings_rate: float
    by_category: List[SpendingByCategory]
    top_merchants: List[Dict[str, Any]]
    trends: List[SpendingTrend]
    insights: List[str]
    

class BudgetCategory(BaseModel):
    """Budget for a category."""
    category: str
    budget_amount: float
    spent_amount: float
    remaining: float
    percentage_used: float
    is_over_budget: bool


class BudgetSummary(BaseModel):
    """Monthly budget summary."""
    month: str
    total_budget: float
    total_spent: float
    remaining: float
    categories: List[BudgetCategory]
    recommendations: List[str]


class CashFlowForecast(BaseModel):
    """Cash flow forecast."""
    forecast_date: date
    predicted_balance: float
    predicted_income: float
    predicted_expenses: float
    confidence_level: float
    assumptions: List[str]


class FinancialHealthScore(BaseModel):
    """Financial health assessment."""
    overall_score: int  # 0-100
    grade: str  # A, B, C, D, F
    components: Dict[str, int]  # breakdown scores
    strengths: List[str]
    areas_for_improvement: List[str]
    recommendations: List[str]


class AnomalyDetection(BaseModel):
    """Anomaly in transactions."""
    transaction_id: str
    anomaly_type: str
    severity: str  # low, medium, high
    description: str
    expected_value: Optional[float] = None
    actual_value: float


class SpendingInsight(BaseModel):
    """AI-generated spending insight."""
    insight_type: str
    title: str
    description: str
    impact: str  # positive, negative, neutral
    action_items: List[str]


class AnalyticsRequest(BaseModel):
    """Request for analytics."""
    user_id: str
    account_ids: Optional[List[str]] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    time_range: TimeRange = TimeRange.MONTHLY
    include_forecasts: bool = False


class BudgetRequest(BaseModel):
    """Request to create/update budget."""
    user_id: str
    month: str  # Format: YYYY-MM
    budgets: Dict[str, float]  # category -> amount


class ForecastRequest(BaseModel):
    """Request for financial forecast."""
    user_id: str
    forecast_months: int = 3
    include_recurring: bool = True
