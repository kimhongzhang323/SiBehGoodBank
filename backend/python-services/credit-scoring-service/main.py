"""
Credit Scoring Service - Main FastAPI application.
Credit assessment, loan eligibility, and risk analysis.
"""
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import structlog
from typing import List, Dict, Optional

from config import settings
from models import (
    CreditScoreRequest, CreditScoreResponse, CreditRating,
    LoanEligibilityRequest, LoanEligibilityResponse, LoanType,
    DebtToIncomeAnalysis, RiskAssessment, LoanSimulation,
    EmploymentType
)
from credit_engine import credit_engine

# Configure logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.stdlib.add_log_level,
        structlog.processors.JSONRenderer()
    ]
)
logger = structlog.get_logger()

# Cache for credit scores
credit_score_cache: Dict[str, CreditScoreResponse] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    logger.info("Starting Credit Scoring Service", version=settings.service_version)
    yield
    logger.info("Shutting down Credit Scoring Service")


app = FastAPI(
    title="SiBeh Good Bank - Credit Scoring Service",
    description="Credit assessment, loan eligibility, and risk analysis service",
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


# ===== CREDIT SCORE =====

@app.post("/api/credit/score", response_model=CreditScoreResponse)
async def calculate_credit_score(request: CreditScoreRequest):
    """
    Calculate comprehensive credit score.
    
    Returns score (300-850), rating, component breakdown, and recommendations.
    """
    try:
        result = credit_engine.calculate_credit_score(request)
        
        # Cache result
        credit_score_cache[request.user_id] = result
        
        logger.info(
            "Credit score calculated",
            user_id=request.user_id,
            score=result.credit_score,
            rating=result.rating.value,
        )
        
        return result
        
    except Exception as e:
        logger.error("Error calculating credit score", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/credit/score/{user_id}")
async def get_cached_credit_score(user_id: str):
    """
    Get cached credit score for a user.
    """
    if user_id not in credit_score_cache:
        raise HTTPException(
            status_code=404, 
            detail="Credit score not found. Please calculate first."
        )
    
    return credit_score_cache[user_id]


@app.get("/api/credit/score/quick")
async def quick_credit_score(
    user_id: str = Query(...),
    monthly_income: float = Query(..., gt=0),
    employment_years: float = Query(..., ge=0),
    credit_utilization: float = Query(30, ge=0, le=100),
    late_payments: int = Query(0, ge=0),
    existing_loans: int = Query(0, ge=0),
):
    """
    Quick credit score estimation with minimal inputs.
    """
    try:
        request = CreditScoreRequest(
            user_id=user_id,
            age=30,  # Default
            employment_type=EmploymentType.EMPLOYED,
            employment_years=employment_years,
            monthly_income=monthly_income,
            credit_utilization=credit_utilization,
            late_payments_12m=late_payments,
            existing_loans=existing_loans,
            credit_history_years=employment_years,  # Approximate
        )
        
        result = credit_engine.calculate_credit_score(request)
        
        return {
            "user_id": user_id,
            "credit_score": result.credit_score,
            "rating": result.rating.value,
            "summary": result.summary,
        }
        
    except Exception as e:
        logger.error("Error in quick score", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== LOAN ELIGIBILITY =====

@app.post("/api/credit/loan/eligibility", response_model=LoanEligibilityResponse)
async def check_loan_eligibility(request: LoanEligibilityRequest):
    """
    Check loan eligibility and get estimated terms.
    
    Returns eligibility status, maximum amount, interest rate, and monthly payment.
    """
    try:
        # Get credit score from cache or use provided
        credit_score = request.credit_score
        if not credit_score and request.user_id in credit_score_cache:
            credit_score = credit_score_cache[request.user_id].credit_score
        
        result = credit_engine.check_loan_eligibility(request, credit_score)
        
        logger.info(
            "Loan eligibility checked",
            user_id=request.user_id,
            loan_type=request.loan_type.value,
            is_eligible=result.is_eligible,
            max_amount=result.max_eligible_amount,
        )
        
        return result
        
    except Exception as e:
        logger.error("Error checking eligibility", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/credit/loan/eligibility/quick")
async def quick_eligibility_check(
    monthly_income: float = Query(..., gt=0),
    loan_amount: float = Query(..., gt=0),
    loan_type: LoanType = Query(LoanType.PERSONAL),
    monthly_obligations: float = Query(0, ge=0),
    credit_score: int = Query(650, ge=300, le=850),
):
    """
    Quick loan eligibility check without user registration.
    """
    try:
        request = LoanEligibilityRequest(
            user_id="quick-check",
            loan_type=loan_type,
            loan_amount=loan_amount,
            tenure_months=60,  # Default 5 years
            credit_score=credit_score,
            monthly_income=monthly_income,
            monthly_obligations=monthly_obligations,
        )
        
        result = credit_engine.check_loan_eligibility(request, credit_score)
        
        return {
            "is_eligible": result.is_eligible,
            "max_eligible_amount": result.max_eligible_amount,
            "estimated_interest_rate": result.estimated_interest_rate,
            "estimated_monthly_payment": result.estimated_monthly_payment,
            "debt_to_income_ratio": result.debt_to_income_ratio,
        }
        
    except Exception as e:
        logger.error("Error in quick eligibility", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== LOAN SIMULATION =====

@app.get("/api/credit/loan/simulate", response_model=LoanSimulation)
async def simulate_loan(
    loan_amount: float = Query(..., gt=0, description="Loan amount in MYR"),
    tenure_months: int = Query(..., ge=6, le=360, description="Loan tenure in months"),
    interest_rate: Optional[float] = Query(None, ge=0, le=30, description="Annual interest rate %"),
    credit_score: int = Query(650, ge=300, le=850, description="Credit score for rate estimation"),
):
    """
    Simulate loan repayment with amortization schedule.
    """
    try:
        # Use provided rate or estimate from credit score
        if interest_rate is None:
            rating = credit_engine._score_to_rating(credit_score)
            interest_rate = credit_engine.BASE_RATES.get(rating, 8.0)
        
        result = credit_engine.simulate_loan(loan_amount, interest_rate, tenure_months)
        
        logger.info(
            "Loan simulation completed",
            amount=loan_amount,
            tenure=tenure_months,
            rate=interest_rate,
        )
        
        return result
        
    except Exception as e:
        logger.error("Error in loan simulation", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/credit/loan/compare")
async def compare_loans(
    loan_amount: float = Query(..., gt=0),
    tenures: str = Query("12,24,36,48,60", description="Comma-separated tenure months"),
    credit_score: int = Query(650, ge=300, le=850),
):
    """
    Compare loan options across different tenures.
    """
    try:
        tenure_list = [int(t.strip()) for t in tenures.split(",")]
        rating = credit_engine._score_to_rating(credit_score)
        interest_rate = credit_engine.BASE_RATES.get(rating, 8.0)
        
        comparisons = []
        for tenure in tenure_list:
            sim = credit_engine.simulate_loan(loan_amount, interest_rate, tenure)
            comparisons.append({
                "tenure_months": tenure,
                "tenure_years": tenure / 12,
                "monthly_payment": sim.monthly_payment,
                "total_interest": sim.total_interest,
                "total_payment": sim.total_payment,
            })
        
        return {
            "loan_amount": loan_amount,
            "interest_rate": interest_rate,
            "credit_rating": rating.value,
            "comparisons": comparisons,
        }
        
    except Exception as e:
        logger.error("Error comparing loans", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== RISK ASSESSMENT =====

@app.get("/api/credit/risk/{user_id}", response_model=RiskAssessment)
async def assess_credit_risk(
    user_id: str,
    loan_amount: float = Query(..., gt=0),
    monthly_income: float = Query(..., gt=0),
    existing_debt: float = Query(0, ge=0),
    credit_score: Optional[int] = Query(None, ge=300, le=850),
):
    """
    Assess credit risk for a potential loan.
    """
    try:
        # Get credit score from cache if not provided
        if credit_score is None:
            if user_id in credit_score_cache:
                credit_score = credit_score_cache[user_id].credit_score
            else:
                credit_score = 650  # Default
        
        result = credit_engine.assess_risk(
            user_id=user_id,
            credit_score=credit_score,
            loan_amount=loan_amount,
            monthly_income=monthly_income,
            existing_debt=existing_debt,
        )
        
        logger.info(
            "Risk assessment completed",
            user_id=user_id,
            risk_score=result.risk_score,
            risk_category=result.risk_category,
        )
        
        return result
        
    except Exception as e:
        logger.error("Error assessing risk", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== DEBT-TO-INCOME ANALYSIS =====

@app.get("/api/credit/dti/{user_id}", response_model=DebtToIncomeAnalysis)
async def analyze_debt_to_income(
    user_id: str,
    monthly_income: float = Query(..., gt=0),
    total_monthly_debt: float = Query(0, ge=0),
):
    """
    Analyze debt-to-income ratio.
    """
    try:
        dti_ratio = (total_monthly_debt / monthly_income * 100) if monthly_income > 0 else 100
        
        # Determine rating
        if dti_ratio <= 20:
            rating = "excellent"
        elif dti_ratio <= 35:
            rating = "good"
        elif dti_ratio <= 45:
            rating = "fair"
        else:
            rating = "poor"
        
        # Calculate max additional debt (to reach 45% DTI)
        max_dti = 45
        max_additional = max(0, (max_dti / 100 * monthly_income) - total_monthly_debt)
        
        # Generate recommendations
        recommendations = []
        if dti_ratio > 45:
            recommendations.append("Your DTI is too high. Focus on paying down existing debt.")
            recommendations.append("Consider debt consolidation for lower monthly payments.")
        elif dti_ratio > 35:
            recommendations.append("Your DTI is manageable but could be improved.")
            recommendations.append(f"You can afford up to RM {max_additional:.2f} additional monthly debt.")
        else:
            recommendations.append(f"Great DTI ratio! You can afford up to RM {max_additional:.2f} additional monthly debt.")
        
        return DebtToIncomeAnalysis(
            user_id=user_id,
            monthly_income=monthly_income,
            total_monthly_debt=total_monthly_debt,
            dti_ratio=round(dti_ratio, 2),
            rating=rating,
            max_additional_debt=round(max_additional, 2),
            recommendations=recommendations,
        )
        
    except Exception as e:
        logger.error("Error analyzing DTI", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== RATING INFO =====

@app.get("/api/credit/ratings")
async def get_rating_info():
    """
    Get credit rating thresholds and descriptions.
    """
    return {
        "ratings": [
            {
                "rating": CreditRating.EXCELLENT.value,
                "min_score": settings.excellent_threshold,
                "max_score": settings.max_credit_score,
                "description": "Excellent credit - Best rates and terms available",
                "typical_rate": f"{credit_engine.BASE_RATES[CreditRating.EXCELLENT]}%",
            },
            {
                "rating": CreditRating.GOOD.value,
                "min_score": settings.good_threshold,
                "max_score": settings.excellent_threshold - 1,
                "description": "Good credit - Competitive rates available",
                "typical_rate": f"{credit_engine.BASE_RATES[CreditRating.GOOD]}%",
            },
            {
                "rating": CreditRating.FAIR.value,
                "min_score": settings.fair_threshold,
                "max_score": settings.good_threshold - 1,
                "description": "Fair credit - Standard rates, may need additional documentation",
                "typical_rate": f"{credit_engine.BASE_RATES[CreditRating.FAIR]}%",
            },
            {
                "rating": CreditRating.POOR.value,
                "min_score": settings.poor_threshold,
                "max_score": settings.fair_threshold - 1,
                "description": "Poor credit - Higher rates, may require collateral",
                "typical_rate": f"{credit_engine.BASE_RATES[CreditRating.POOR]}%",
            },
            {
                "rating": CreditRating.VERY_POOR.value,
                "min_score": settings.min_credit_score,
                "max_score": settings.poor_threshold - 1,
                "description": "Very poor credit - Limited options, focus on credit building",
                "typical_rate": f"{credit_engine.BASE_RATES[CreditRating.VERY_POOR]}%",
            },
        ],
        "score_range": {
            "min": settings.min_credit_score,
            "max": settings.max_credit_score,
        },
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
