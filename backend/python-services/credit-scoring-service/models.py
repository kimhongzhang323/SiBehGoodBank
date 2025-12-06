"""
Data models for Credit Scoring Service.
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime, date
from enum import Enum


class CreditRating(str, Enum):
    """Credit rating classification."""
    EXCELLENT = "excellent"
    GOOD = "good"
    FAIR = "fair"
    POOR = "poor"
    VERY_POOR = "very_poor"


class EmploymentType(str, Enum):
    """Employment type."""
    EMPLOYED = "employed"
    SELF_EMPLOYED = "self_employed"
    BUSINESS_OWNER = "business_owner"
    FREELANCER = "freelancer"
    RETIRED = "retired"
    UNEMPLOYED = "unemployed"
    STUDENT = "student"


class LoanType(str, Enum):
    """Types of loans."""
    PERSONAL = "personal"
    HOME = "home"
    CAR = "car"
    EDUCATION = "education"
    BUSINESS = "business"
    CREDIT_CARD = "credit_card"


class CreditScoreRequest(BaseModel):
    """Request for credit score calculation."""
    user_id: str
    # Personal Information
    age: int = Field(..., ge=18, le=100)
    employment_type: EmploymentType
    employment_years: float = Field(..., ge=0)
    monthly_income: float = Field(..., ge=0)
    
    # Financial Information
    total_assets: float = Field(default=0, ge=0)
    total_liabilities: float = Field(default=0, ge=0)
    savings_balance: float = Field(default=0, ge=0)
    monthly_expenses: float = Field(default=0, ge=0)
    
    # Credit History
    existing_loans: int = Field(default=0, ge=0)
    loan_defaults: int = Field(default=0, ge=0)
    late_payments_12m: int = Field(default=0, ge=0)
    credit_utilization: float = Field(default=0, ge=0, le=100)
    credit_history_years: float = Field(default=0, ge=0)
    
    # Transaction History (from API or mock)
    transaction_history: Optional[List[Dict[str, Any]]] = None


class CreditScoreComponent(BaseModel):
    """Individual component of credit score."""
    name: str
    score: int
    max_score: int
    weight: float
    description: str
    impact: str  # positive, negative, neutral


class CreditScoreResponse(BaseModel):
    """Credit score response."""
    user_id: str
    credit_score: int
    rating: CreditRating
    components: List[CreditScoreComponent]
    summary: str
    recommendations: List[str]
    calculated_at: datetime = Field(default_factory=datetime.now)


class LoanEligibilityRequest(BaseModel):
    """Request for loan eligibility check."""
    user_id: str
    loan_type: LoanType
    loan_amount: float = Field(..., gt=0)
    tenure_months: int = Field(..., ge=6, le=360)
    credit_score: Optional[int] = None
    monthly_income: float = Field(..., gt=0)
    monthly_obligations: float = Field(default=0, ge=0)


class LoanEligibilityResponse(BaseModel):
    """Loan eligibility response."""
    user_id: str
    loan_type: LoanType
    requested_amount: float
    is_eligible: bool
    max_eligible_amount: float
    recommended_tenure: int
    estimated_interest_rate: float
    estimated_monthly_payment: float
    debt_to_income_ratio: float
    eligibility_reasons: List[str]
    improvement_suggestions: List[str]


class DebtToIncomeAnalysis(BaseModel):
    """Debt-to-income ratio analysis."""
    user_id: str
    monthly_income: float
    total_monthly_debt: float
    dti_ratio: float
    rating: str  # excellent, good, fair, poor
    max_additional_debt: float
    recommendations: List[str]


class CreditUtilizationReport(BaseModel):
    """Credit utilization analysis."""
    user_id: str
    total_credit_limit: float
    total_credit_used: float
    utilization_ratio: float
    rating: str
    impact_on_score: str
    recommendations: List[str]


class CreditHistoryFactor(BaseModel):
    """Credit history factor."""
    factor: str
    status: str  # positive, negative, neutral
    impact_score: int
    description: str


class CreditReport(BaseModel):
    """Comprehensive credit report."""
    user_id: str
    generated_at: datetime
    credit_score: int
    rating: CreditRating
    score_history: List[Dict[str, Any]]  # Historical scores
    factors: List[CreditHistoryFactor]
    accounts_summary: Dict[str, Any]
    inquiries: List[Dict[str, Any]]
    public_records: List[Dict[str, Any]]
    recommendations: List[str]


class LoanSimulation(BaseModel):
    """Loan simulation result."""
    loan_amount: float
    tenure_months: int
    interest_rate: float
    monthly_payment: float
    total_interest: float
    total_payment: float
    amortization_schedule: List[Dict[str, float]]


class RiskAssessment(BaseModel):
    """Credit risk assessment."""
    user_id: str
    risk_score: float  # 0-100
    risk_category: str  # low, medium, high, very_high
    probability_of_default: float
    expected_loss: float
    risk_factors: List[Dict[str, Any]]
    mitigating_factors: List[str]
