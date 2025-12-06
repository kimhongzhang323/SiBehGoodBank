"""
Fraud Detection Service - Main FastAPI application.
Real-time fraud detection using ML algorithms.
"""
from fastapi import FastAPI, HTTPException, Query, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import structlog
from datetime import datetime, timedelta
from typing import List, Dict, Any
import uuid

from config import settings
from models import (
    TransactionRequest, FraudAssessment, FraudAlert,
    FraudStatistics, RiskLevel, VelocityCheck
)
from fraud_engine import fraud_engine

# Configure logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.stdlib.add_log_level,
        structlog.processors.JSONRenderer()
    ]
)
logger = structlog.get_logger()

# In-memory storage for demo (use Redis in production)
fraud_alerts: List[FraudAlert] = []
assessment_history: Dict[str, FraudAssessment] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    logger.info("Starting Fraud Detection Service", version=settings.service_version)
    yield
    logger.info("Shutting down Fraud Detection Service")


app = FastAPI(
    title="SiBeh Good Bank - Fraud Detection Service",
    description="Real-time ML-based fraud detection for banking transactions",
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


# ===== FRAUD ASSESSMENT =====

@app.post("/api/fraud/assess", response_model=FraudAssessment)
async def assess_transaction(
    transaction: TransactionRequest,
    background_tasks: BackgroundTasks,
):
    """
    Assess a transaction for fraud in real-time.
    
    Returns risk score, risk level, and recommended action.
    """
    try:
        # Get user's transaction history (mock for now)
        historical_transactions = _get_mock_history(transaction.user_id)
        
        # Perform assessment
        assessment = fraud_engine.assess_transaction(
            transaction,
            historical_transactions,
        )
        
        # Store assessment
        assessment_history[transaction.transaction_id] = assessment
        
        # Create alert if high risk
        if assessment.risk_level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
            background_tasks.add_task(
                _create_fraud_alert,
                transaction,
                assessment,
            )
        
        logger.info(
            "Transaction assessed",
            transaction_id=transaction.transaction_id,
            risk_score=assessment.risk_score,
            risk_level=assessment.risk_level.value,
            action=assessment.action,
        )
        
        return assessment
        
    except Exception as e:
        logger.error("Error assessing transaction", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/fraud/batch-assess")
async def batch_assess_transactions(
    transactions: List[TransactionRequest],
):
    """
    Assess multiple transactions in batch.
    """
    try:
        results = []
        
        for transaction in transactions:
            historical = _get_mock_history(transaction.user_id)
            assessment = fraud_engine.assess_transaction(transaction, historical)
            results.append(assessment)
            assessment_history[transaction.transaction_id] = assessment
        
        high_risk_count = sum(
            1 for r in results 
            if r.risk_level in [RiskLevel.HIGH, RiskLevel.CRITICAL]
        )
        
        logger.info(
            "Batch assessment completed",
            total=len(transactions),
            high_risk=high_risk_count,
        )
        
        return {
            "assessments": results,
            "summary": {
                "total": len(results),
                "approved": sum(1 for r in results if r.action == "approve"),
                "declined": sum(1 for r in results if r.action == "decline"),
                "review": sum(1 for r in results if r.action == "review"),
                "challenge": sum(1 for r in results if r.action == "challenge"),
            },
        }
        
    except Exception as e:
        logger.error("Error in batch assessment", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== VELOCITY CHECKS =====

@app.get("/api/fraud/velocity/{user_id}", response_model=VelocityCheck)
async def check_velocity(user_id: str):
    """
    Check transaction velocity for a user.
    """
    try:
        result = fraud_engine.get_velocity_check(user_id)
        return result
    except Exception as e:
        logger.error("Error checking velocity", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== ALERTS =====

@app.get("/api/fraud/alerts")
async def get_fraud_alerts(
    user_id: str = Query(None, description="Filter by user ID"),
    risk_level: RiskLevel = Query(None, description="Filter by risk level"),
    limit: int = Query(50, ge=1, le=200),
):
    """
    Get fraud alerts.
    """
    try:
        alerts = fraud_alerts
        
        if user_id:
            alerts = [a for a in alerts if a.user_id == user_id]
        
        if risk_level:
            alerts = [a for a in alerts if a.risk_level == risk_level]
        
        # Sort by date descending
        alerts = sorted(alerts, key=lambda x: x.created_at, reverse=True)
        
        return {
            "alerts": alerts[:limit],
            "total": len(alerts),
        }
        
    except Exception as e:
        logger.error("Error getting alerts", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/fraud/alerts/{alert_id}")
async def get_alert(alert_id: str):
    """
    Get specific fraud alert.
    """
    alert = next((a for a in fraud_alerts if a.alert_id == alert_id), None)
    
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    
    return alert


@app.post("/api/fraud/alerts/{alert_id}/resolve")
async def resolve_alert(
    alert_id: str,
    resolution: str = Query(..., description="Resolution: confirmed_fraud, false_positive, legitimate"),
):
    """
    Resolve a fraud alert.
    """
    alert = next((a for a in fraud_alerts if a.alert_id == alert_id), None)
    
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    
    logger.info(
        "Alert resolved",
        alert_id=alert_id,
        resolution=resolution,
    )
    
    return {
        "alert_id": alert_id,
        "resolution": resolution,
        "resolved_at": datetime.now().isoformat(),
    }


# ===== STATISTICS =====

@app.get("/api/fraud/statistics")
async def get_fraud_statistics(
    days: int = Query(30, ge=1, le=365, description="Number of days to analyze"),
):
    """
    Get fraud detection statistics.
    """
    try:
        period_end = datetime.now()
        period_start = period_end - timedelta(days=days)
        
        # Filter assessments by date
        recent_assessments = [
            a for a in assessment_history.values()
            if a.assessed_at >= period_start
        ]
        
        total = len(recent_assessments)
        flagged = sum(1 for a in recent_assessments if a.requires_review or a.is_fraudulent)
        
        by_risk_level = {}
        for level in RiskLevel:
            by_risk_level[level.value] = sum(
                1 for a in recent_assessments if a.risk_level == level
            )
        
        by_fraud_type = {}
        for a in recent_assessments:
            for indicator in a.indicators:
                fraud_type = indicator.indicator_type.value
                by_fraud_type[fraud_type] = by_fraud_type.get(fraud_type, 0) + 1
        
        avg_risk = (
            sum(a.risk_score for a in recent_assessments) / total
            if total > 0 else 0
        )
        
        return FraudStatistics(
            period_start=period_start,
            period_end=period_end,
            total_transactions=total,
            flagged_transactions=flagged,
            confirmed_fraud=sum(1 for a in recent_assessments if a.is_fraudulent),
            false_positives=0,  # Would come from resolution data
            detection_rate=flagged / total if total > 0 else 0,
            false_positive_rate=0,  # Would come from resolution data
            average_risk_score=round(avg_risk, 4),
            by_fraud_type=by_fraud_type,
            by_risk_level=by_risk_level,
        )
        
    except Exception as e:
        logger.error("Error getting statistics", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== USER PROFILE =====

@app.post("/api/fraud/profile/{user_id}/update")
async def update_user_profile(
    user_id: str,
    transactions: List[Dict[str, Any]],
):
    """
    Update user behavior profile with transaction history.
    """
    try:
        fraud_engine.update_user_profile(user_id, transactions)
        
        logger.info(
            "User profile updated",
            user_id=user_id,
            transactions_count=len(transactions),
        )
        
        return {
            "success": True,
            "user_id": user_id,
            "message": "Profile updated successfully",
        }
        
    except Exception as e:
        logger.error("Error updating profile", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/fraud/profile/{user_id}")
async def get_user_profile(user_id: str):
    """
    Get user behavior profile.
    """
    profile = fraud_engine.user_profiles.get(user_id)
    
    if not profile:
        return {
            "user_id": user_id,
            "message": "No profile found. Profile will be created after first transactions.",
        }
    
    return profile


# ===== HELPER FUNCTIONS =====

def _get_mock_history(user_id: str) -> List[Dict[str, Any]]:
    """Get mock transaction history for a user."""
    import random
    
    transactions = []
    base_date = datetime.now()
    
    templates = [
        {"type": "debit", "desc": "Groceries - Tesco", "range": (50, 300)},
        {"type": "debit", "desc": "Petrol - Shell", "range": (80, 150)},
        {"type": "debit", "desc": "Restaurant", "range": (30, 120)},
        {"type": "debit", "desc": "Online Shopping", "range": (50, 500)},
        {"type": "transfer", "desc": "Transfer", "range": (100, 1000)},
        {"type": "credit", "desc": "Salary", "range": (4000, 6000)},
    ]
    
    for i in range(30):
        template = random.choice(templates)
        amount = round(random.uniform(*template["range"]), 2)
        
        transactions.append({
            "transaction_id": f"TXN{uuid.uuid4().hex[:12].upper()}",
            "type": template["type"],
            "amount": amount,
            "description": template["desc"],
            "date": (base_date - timedelta(days=i, hours=random.randint(8, 20))).isoformat(),
            "merchant_category": "general",
        })
    
    return transactions


async def _create_fraud_alert(
    transaction: TransactionRequest,
    assessment: FraudAssessment,
):
    """Create fraud alert for high-risk transactions."""
    alert = FraudAlert(
        alert_id=f"ALERT-{uuid.uuid4().hex[:8].upper()}",
        user_id=transaction.user_id,
        transaction_id=transaction.transaction_id,
        risk_level=assessment.risk_level,
        fraud_types=[i.indicator_type for i in assessment.indicators],
        description=f"Suspicious transaction detected: RM {transaction.amount:.2f}",
        recommended_action=assessment.action,
    )
    
    fraud_alerts.append(alert)
    
    logger.warning(
        "Fraud alert created",
        alert_id=alert.alert_id,
        transaction_id=transaction.transaction_id,
        risk_level=assessment.risk_level.value,
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
