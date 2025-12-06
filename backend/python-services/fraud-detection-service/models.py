"""
Data models for Fraud Detection Service.
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum


class RiskLevel(str, Enum):
    """Risk level classification."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class FraudType(str, Enum):
    """Types of fraud detected."""
    UNUSUAL_AMOUNT = "unusual_amount"
    UNUSUAL_LOCATION = "unusual_location"
    UNUSUAL_TIME = "unusual_time"
    VELOCITY_ABUSE = "velocity_abuse"
    ACCOUNT_TAKEOVER = "account_takeover"
    CARD_NOT_PRESENT = "card_not_present"
    DEVICE_ANOMALY = "device_anomaly"
    PATTERN_ANOMALY = "pattern_anomaly"
    MERCHANT_FRAUD = "merchant_fraud"
    MONEY_LAUNDERING = "money_laundering"


class TransactionRequest(BaseModel):
    """Transaction to be evaluated for fraud."""
    transaction_id: str
    user_id: str
    account_id: str
    amount: float
    currency: str = "MYR"
    merchant_name: Optional[str] = None
    merchant_category: Optional[str] = None
    merchant_country: str = "MY"
    transaction_type: str  # purchase, transfer, withdrawal, etc.
    channel: str  # online, pos, atm, mobile
    device_id: Optional[str] = None
    ip_address: Optional[str] = None
    location: Optional[Dict[str, float]] = None  # lat, lng
    timestamp: datetime = Field(default_factory=datetime.now)
    

class FraudIndicator(BaseModel):
    """Individual fraud indicator."""
    indicator_type: FraudType
    score: float  # 0.0 to 1.0
    description: str
    evidence: Dict[str, Any]


class FraudAssessment(BaseModel):
    """Complete fraud assessment result."""
    transaction_id: str
    risk_score: float  # 0.0 to 1.0
    risk_level: RiskLevel
    is_fraudulent: bool
    requires_review: bool
    indicators: List[FraudIndicator]
    recommendation: str
    action: str  # approve, decline, review, challenge
    assessed_at: datetime = Field(default_factory=datetime.now)


class DeviceProfile(BaseModel):
    """Device profile for fraud detection."""
    device_id: str
    user_id: str
    device_type: str  # mobile, desktop, tablet
    os: Optional[str] = None
    browser: Optional[str] = None
    first_seen: datetime
    last_seen: datetime
    trust_score: float = 0.5
    is_known: bool = False


class UserBehaviorProfile(BaseModel):
    """User behavior profile for anomaly detection."""
    user_id: str
    average_transaction_amount: float
    max_transaction_amount: float
    typical_transaction_hours: List[int]
    typical_merchants: List[str]
    typical_locations: List[str]
    transaction_frequency: float  # per day
    last_updated: datetime


class VelocityCheck(BaseModel):
    """Velocity check result."""
    user_id: str
    window_minutes: int
    transaction_count: int
    total_amount: float
    is_exceeded: bool
    limit: int


class FraudAlert(BaseModel):
    """Fraud alert notification."""
    alert_id: str
    user_id: str
    transaction_id: str
    risk_level: RiskLevel
    fraud_types: List[FraudType]
    description: str
    recommended_action: str
    created_at: datetime = Field(default_factory=datetime.now)


class FraudRule(BaseModel):
    """Configurable fraud detection rule."""
    rule_id: str
    name: str
    description: str
    condition: str  # JSON-based condition
    action: str  # approve, decline, review
    risk_score_impact: float
    is_active: bool = True


class FraudStatistics(BaseModel):
    """Fraud statistics summary."""
    period_start: datetime
    period_end: datetime
    total_transactions: int
    flagged_transactions: int
    confirmed_fraud: int
    false_positives: int
    detection_rate: float
    false_positive_rate: float
    average_risk_score: float
    by_fraud_type: Dict[str, int]
    by_risk_level: Dict[str, int]


class TransactionHistory(BaseModel):
    """User's transaction history for analysis."""
    user_id: str
    transactions: List[Dict[str, Any]]
    period_days: int = 90
