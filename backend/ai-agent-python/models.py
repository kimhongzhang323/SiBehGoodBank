"""
Pydantic models for API request/response schemas.
"""
from typing import Any, Dict, List, Optional
from datetime import datetime
from pydantic import BaseModel, Field
from enum import Enum


# Enums
class MessageRole(str, Enum):
    """Message role enum."""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class TransactionType(str, Enum):
    """Transaction type enum."""
    CREDIT = "credit"
    DEBIT = "debit"
    TRANSFER = "transfer"
    BILL_PAYMENT = "bill_payment"
    WITHDRAWAL = "withdrawal"


class AccountType(str, Enum):
    """Account type enum."""
    SAVINGS = "savings"
    CURRENT = "current"
    INVESTMENT = "investment"
    FIXED_DEPOSIT = "fixed_deposit"


# Request Models
class ChatRequest(BaseModel):
    """Request model for chat endpoint."""
    message: str = Field(..., description="User's message", min_length=1, max_length=2000)
    user_id: Optional[str] = Field(default="user-001", description="User ID for the session")
    session_id: Optional[str] = Field(default=None, description="Optional session ID for continuing conversations")
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "What's my account balance?",
                "user_id": "user-001"
            }
        }


class StreamChatRequest(BaseModel):
    """Request model for streaming chat endpoint."""
    message: str = Field(..., description="User's message", min_length=1, max_length=2000)
    user_id: Optional[str] = Field(default="user-001", description="User ID for the session")
    session_id: Optional[str] = Field(default=None, description="Optional session ID")
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "Transfer RM100 to John's account",
                "user_id": "user-001"
            }
        }


class ClearHistoryRequest(BaseModel):
    """Request model for clearing chat history."""
    user_id: str = Field(default="user-001", description="User ID")
    session_id: Optional[str] = Field(default=None, description="Session ID to clear")


# Response Models
class ChatMessage(BaseModel):
    """A single chat message."""
    role: MessageRole
    content: str
    timestamp: Optional[datetime] = None


class ChatResponse(BaseModel):
    """Response model for chat endpoint."""
    message: str = Field(..., description="Assistant's response")
    user_id: str = Field(..., description="User ID")
    session_id: Optional[str] = Field(default=None, description="Session ID for continuation")
    timestamp: datetime = Field(default_factory=datetime.now)
    chart_images: Optional[List[str]] = Field(default=None, description="Base64 encoded chart images if any were generated")
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "Your Main Savings account balance is RM 15,847.50.",
                "user_id": "user-001",
                "timestamp": "2024-01-15T10:30:00",
                "chart_images": None
            }
        }


class ConversationHistory(BaseModel):
    """Response model for conversation history."""
    user_id: str
    messages: List[ChatMessage]
    message_count: int


class HealthResponse(BaseModel):
    """Response model for health check."""
    status: str = Field(..., description="Service status")
    version: str = Field(..., description="API version")
    timestamp: datetime = Field(default_factory=datetime.now)
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "healthy",
                "version": "1.0.0",
                "timestamp": "2024-01-15T10:30:00"
            }
        }


class ErrorResponse(BaseModel):
    """Response model for errors."""
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(default=None, description="Additional error details")
    timestamp: datetime = Field(default_factory=datetime.now)


# Account Models
class Account(BaseModel):
    """Account model."""
    account_id: str
    account_number: str
    account_name: str
    account_type: AccountType
    balance: float
    currency: str = "MYR"
    is_primary: bool = False


class AccountBalance(BaseModel):
    """Account balance response."""
    account_id: str
    account_name: str
    account_type: str
    balance: float
    currency: str = "MYR"


class AllBalancesResponse(BaseModel):
    """Response for all account balances."""
    accounts: List[AccountBalance]
    total_balance: float
    currency: str = "MYR"


# Transaction Models
class Transaction(BaseModel):
    """Transaction model."""
    transaction_id: str
    account_id: str
    type: TransactionType
    amount: float
    currency: str = "MYR"
    description: str
    category: Optional[str] = None
    merchant: Optional[str] = None
    timestamp: datetime
    balance_after: Optional[float] = None


class TransactionHistory(BaseModel):
    """Transaction history response."""
    transactions: List[Transaction]
    count: int
    account_id: Optional[str] = None


# Transfer Models
class TransferRequest(BaseModel):
    """Transfer request model."""
    from_account_id: Optional[str] = None
    to_account_number: str
    to_bank_code: str
    amount: float = Field(..., gt=0)
    recipient_name: str
    description: Optional[str] = None


class TransferResponse(BaseModel):
    """Transfer response model."""
    success: bool
    reference_number: Optional[str] = None
    from_account: str
    to_account: str
    amount: float
    currency: str = "MYR"
    timestamp: datetime
    message: str
    error: Optional[str] = None


# Bill Payment Models
class BillPaymentRequest(BaseModel):
    """Bill payment request model."""
    from_account_id: Optional[str] = None
    bill_provider: str
    bill_account_number: str
    amount: float = Field(..., gt=0)


class BillPaymentResponse(BaseModel):
    """Bill payment response model."""
    success: bool
    reference_number: Optional[str] = None
    provider: str
    bill_account: str
    amount: float
    currency: str = "MYR"
    timestamp: datetime
    message: str
    error: Optional[str] = None


class BillProvider(BaseModel):
    """Bill provider model."""
    name: str
    code: str
    category: str
    logo_url: Optional[str] = None


class BillCategory(BaseModel):
    """Bill category model."""
    name: str
    providers: List[BillProvider]


# Exchange Rate Models
class ExchangeRate(BaseModel):
    """Exchange rate model."""
    currency: str
    currency_name: str
    buy_rate: float
    sell_rate: float
    mid_rate: float
    last_updated: datetime


class ExchangeRatesResponse(BaseModel):
    """Exchange rates response."""
    base_currency: str = "MYR"
    rates: List[ExchangeRate]
    last_updated: datetime


# Loan Calculator Models
class LoanCalculationRequest(BaseModel):
    """Loan calculation request."""
    principal: float = Field(..., gt=0, description="Loan amount")
    annual_rate: float = Field(..., gt=0, le=100, description="Annual interest rate (%)")
    tenure_months: int = Field(..., gt=0, le=480, description="Loan tenure in months")


class LoanCalculationResponse(BaseModel):
    """Loan calculation response."""
    principal: float
    annual_rate: float
    tenure_months: int
    monthly_payment: float
    total_interest: float
    total_repayment: float
    currency: str = "MYR"


# Withdrawal Models
class WithdrawalRequest(BaseModel):
    """Cardless withdrawal request."""
    from_account_id: Optional[str] = None
    amount: float = Field(..., gt=0, le=1500)


class WithdrawalResponse(BaseModel):
    """Cardless withdrawal response."""
    success: bool
    withdrawal_code: Optional[str] = None
    amount: float
    currency: str = "MYR"
    expires_at: Optional[datetime] = None
    instructions: Optional[List[str]] = None
    error: Optional[str] = None


# ATM Models
class ATMLocation(BaseModel):
    """ATM location model."""
    id: str
    name: str
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    distance: Optional[str] = None
    available: bool = True
    services: List[str] = []


class NearbyATMsResponse(BaseModel):
    """Nearby ATMs response."""
    atms: List[ATMLocation]
    count: int


# Contact Models
class Contact(BaseModel):
    """Transfer contact model."""
    id: str
    name: str
    nickname: Optional[str] = None
    bank_name: str
    bank_code: str
    account_number: str
    is_favorite: bool = False


class ContactsResponse(BaseModel):
    """Contacts response."""
    contacts: List[Contact]
    favorites: List[Contact]
    total: int


# Pending Bill Models
class PendingBill(BaseModel):
    """Pending bill model."""
    id: str
    provider: str
    account_number: str
    amount: float
    due_date: datetime
    status: str = "pending"


class PendingBillsResponse(BaseModel):
    """Pending bills response."""
    bills: List[PendingBill]
    total_due: float
    currency: str = "MYR"
    count: int


# Graph/Chart Models
class ChartCategory(BaseModel):
    """Category breakdown for spending charts."""
    name: str
    amount: float
    percentage: float


class SpendingChartResponse(BaseModel):
    """Response model for spending chart generation."""
    success: bool
    chart_type: str = "spending_breakdown"
    chart_format: str
    period_days: int
    total_spending: float
    currency: str = "MYR"
    categories: List[ChartCategory]
    chart_image_base64: str
    message: str
    error: Optional[str] = None


class BalanceTrendChartResponse(BaseModel):
    """Response model for balance trend chart generation."""
    success: bool
    chart_type: str = "balance_trend"
    period_days: int
    current_balance: float
    min_balance: float
    max_balance: float
    average_balance: float
    balance_change: float
    currency: str = "MYR"
    chart_image_base64: str
    message: str
    error: Optional[str] = None


class IncomeExpenseChartResponse(BaseModel):
    """Response model for income vs expense chart generation."""
    success: bool
    chart_type: str = "income_expense"
    chart_format: str
    period_days: int
    total_income: float
    total_expenses: float
    net_cash_flow: float
    savings_rate: float
    currency: str = "MYR"
    chart_image_base64: str
    message: str
    error: Optional[str] = None


class TransactionTimelineResponse(BaseModel):
    """Response model for transaction timeline chart."""
    success: bool
    chart_type: str = "transaction_timeline"
    period_days: int
    total_transactions: int
    average_per_day: float
    busiest_day: Optional[str] = None
    chart_image_base64: str
    message: str
    error: Optional[str] = None


class MonthlyBreakdown(BaseModel):
    """Monthly financial breakdown."""
    month: str
    income: float
    expenses: float
    net: float


class MonthlySummaryChartResponse(BaseModel):
    """Response model for monthly summary chart generation."""
    success: bool
    chart_type: str = "monthly_summary"
    period_months: int
    total_income: float
    total_expenses: float
    net_cash_flow: float
    average_monthly_income: float
    average_monthly_expenses: float
    savings_rate: float
    monthly_breakdown: List[MonthlyBreakdown]
    currency: str = "MYR"
    chart_image_base64: str
    message: str
    error: Optional[str] = None


class ChartGenerationRequest(BaseModel):
    """Generic request model for chart generation."""
    user_id: str = Field(default="user-001", description="User ID")
    account_id: Optional[str] = Field(default=None, description="Account ID to analyze")
    days: Optional[int] = Field(default=30, description="Number of days to analyze")
    months: Optional[int] = Field(default=6, description="Number of months to analyze")
    chart_type: Optional[str] = Field(default=None, description="Type of chart to generate")
