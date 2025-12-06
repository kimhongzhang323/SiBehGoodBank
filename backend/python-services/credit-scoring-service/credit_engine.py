"""
Credit Scoring Engine - Core credit assessment logic.
"""
import numpy as np
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple

from config import settings
from models import (
    CreditScoreRequest, CreditScoreResponse, CreditScoreComponent,
    CreditRating, LoanEligibilityRequest, LoanEligibilityResponse,
    LoanType, DebtToIncomeAnalysis, RiskAssessment, LoanSimulation
)


class CreditScoringEngine:
    """Credit scoring and loan assessment engine."""
    
    # Scoring weights
    WEIGHTS = {
        'payment_history': 0.35,
        'credit_utilization': 0.30,
        'credit_history_length': 0.15,
        'credit_mix': 0.10,
        'new_credit': 0.10,
    }
    
    # Interest rates by credit rating (annual %)
    BASE_RATES = {
        CreditRating.EXCELLENT: 3.5,
        CreditRating.GOOD: 5.0,
        CreditRating.FAIR: 7.5,
        CreditRating.POOR: 10.0,
        CreditRating.VERY_POOR: 15.0,
    }
    
    # Loan type adjustments
    LOAN_TYPE_ADJUSTMENTS = {
        LoanType.HOME: -0.5,
        LoanType.CAR: 0.5,
        LoanType.PERSONAL: 1.5,
        LoanType.EDUCATION: 0.0,
        LoanType.BUSINESS: 1.0,
        LoanType.CREDIT_CARD: 3.0,
    }
    
    def calculate_credit_score(self, request: CreditScoreRequest) -> CreditScoreResponse:
        """Calculate comprehensive credit score."""
        components = []
        
        # 1. Payment History Score (35%)
        payment_score = self._calculate_payment_history_score(
            request.late_payments_12m,
            request.loan_defaults,
        )
        components.append(CreditScoreComponent(
            name="Payment History",
            score=payment_score,
            max_score=100,
            weight=self.WEIGHTS['payment_history'],
            description=f"Based on {request.late_payments_12m} late payments and {request.loan_defaults} defaults",
            impact="positive" if payment_score >= 70 else "negative" if payment_score < 50 else "neutral",
        ))
        
        # 2. Credit Utilization Score (30%)
        utilization_score = self._calculate_utilization_score(request.credit_utilization)
        components.append(CreditScoreComponent(
            name="Credit Utilization",
            score=utilization_score,
            max_score=100,
            weight=self.WEIGHTS['credit_utilization'],
            description=f"Current utilization: {request.credit_utilization:.1f}%",
            impact="positive" if request.credit_utilization <= 30 else "negative" if request.credit_utilization > 50 else "neutral",
        ))
        
        # 3. Credit History Length Score (15%)
        history_score = self._calculate_history_length_score(request.credit_history_years)
        components.append(CreditScoreComponent(
            name="Credit History Length",
            score=history_score,
            max_score=100,
            weight=self.WEIGHTS['credit_history_length'],
            description=f"{request.credit_history_years:.1f} years of credit history",
            impact="positive" if request.credit_history_years >= 5 else "neutral",
        ))
        
        # 4. Credit Mix Score (10%)
        mix_score = self._calculate_credit_mix_score(request.existing_loans)
        components.append(CreditScoreComponent(
            name="Credit Mix",
            score=mix_score,
            max_score=100,
            weight=self.WEIGHTS['credit_mix'],
            description=f"{request.existing_loans} active credit accounts",
            impact="positive" if 2 <= request.existing_loans <= 5 else "neutral",
        ))
        
        # 5. New Credit / Income Stability Score (10%)
        income_score = self._calculate_income_stability_score(
            request.monthly_income,
            request.employment_years,
            request.employment_type.value,
        )
        components.append(CreditScoreComponent(
            name="Income Stability",
            score=income_score,
            max_score=100,
            weight=self.WEIGHTS['new_credit'],
            description=f"RM {request.monthly_income:,.0f}/month, {request.employment_years:.1f} years employed",
            impact="positive" if income_score >= 70 else "neutral",
        ))
        
        # Calculate weighted average
        weighted_sum = sum(c.score * c.weight for c in components)
        
        # Convert to credit score range (300-850)
        credit_score = int(
            settings.min_credit_score + 
            (weighted_sum / 100) * (settings.max_credit_score - settings.min_credit_score)
        )
        
        # Determine rating
        rating = self._score_to_rating(credit_score)
        
        # Generate summary and recommendations
        summary = self._generate_summary(credit_score, rating, components)
        recommendations = self._generate_recommendations(request, components, rating)
        
        return CreditScoreResponse(
            user_id=request.user_id,
            credit_score=credit_score,
            rating=rating,
            components=components,
            summary=summary,
            recommendations=recommendations,
        )
    
    def _calculate_payment_history_score(
        self,
        late_payments: int,
        defaults: int,
    ) -> int:
        """Calculate payment history component score."""
        score = 100
        
        # Deductions for late payments
        if late_payments > 0:
            score -= min(40, late_payments * 8)
        
        # Heavy penalty for defaults
        if defaults > 0:
            score -= min(50, defaults * 25)
        
        return max(0, score)
    
    def _calculate_utilization_score(self, utilization: float) -> int:
        """Calculate credit utilization component score."""
        if utilization <= 10:
            return 100
        elif utilization <= 30:
            return 90
        elif utilization <= 50:
            return 70
        elif utilization <= 75:
            return 50
        elif utilization <= 90:
            return 30
        else:
            return 10
    
    def _calculate_history_length_score(self, years: float) -> int:
        """Calculate credit history length score."""
        if years >= 10:
            return 100
        elif years >= 7:
            return 90
        elif years >= 5:
            return 80
        elif years >= 3:
            return 65
        elif years >= 1:
            return 50
        else:
            return 30
    
    def _calculate_credit_mix_score(self, num_accounts: int) -> int:
        """Calculate credit mix score."""
        if 3 <= num_accounts <= 5:
            return 100
        elif num_accounts == 2 or num_accounts == 6:
            return 85
        elif num_accounts == 1 or num_accounts == 7:
            return 70
        elif num_accounts == 0:
            return 50
        else:
            return 60  # Too many accounts
    
    def _calculate_income_stability_score(
        self,
        monthly_income: float,
        employment_years: float,
        employment_type: str,
    ) -> int:
        """Calculate income stability score."""
        score = 50  # Base score
        
        # Income level bonus
        if monthly_income >= 10000:
            score += 25
        elif monthly_income >= 5000:
            score += 20
        elif monthly_income >= 3000:
            score += 10
        
        # Employment tenure bonus
        if employment_years >= 5:
            score += 20
        elif employment_years >= 3:
            score += 15
        elif employment_years >= 1:
            score += 10
        
        # Employment type adjustment
        stable_types = ['employed', 'business_owner']
        if employment_type in stable_types:
            score += 5
        elif employment_type == 'self_employed':
            score += 0
        else:
            score -= 10
        
        return min(100, max(0, score))
    
    def _score_to_rating(self, score: int) -> CreditRating:
        """Convert numeric score to rating."""
        if score >= settings.excellent_threshold:
            return CreditRating.EXCELLENT
        elif score >= settings.good_threshold:
            return CreditRating.GOOD
        elif score >= settings.fair_threshold:
            return CreditRating.FAIR
        elif score >= settings.poor_threshold:
            return CreditRating.POOR
        else:
            return CreditRating.VERY_POOR
    
    def _generate_summary(
        self,
        score: int,
        rating: CreditRating,
        components: List[CreditScoreComponent],
    ) -> str:
        """Generate credit score summary."""
        summaries = {
            CreditRating.EXCELLENT: f"Your credit score of {score} is excellent! You qualify for the best rates and terms.",
            CreditRating.GOOD: f"Your credit score of {score} is good. You'll likely qualify for competitive rates.",
            CreditRating.FAIR: f"Your credit score of {score} is fair. You may qualify for credit but not the best rates.",
            CreditRating.POOR: f"Your credit score of {score} is poor. You may have difficulty getting approved.",
            CreditRating.VERY_POOR: f"Your credit score of {score} needs improvement. Focus on building positive credit history.",
        }
        return summaries.get(rating, f"Your credit score is {score}.")
    
    def _generate_recommendations(
        self,
        request: CreditScoreRequest,
        components: List[CreditScoreComponent],
        rating: CreditRating,
    ) -> List[str]:
        """Generate personalized recommendations."""
        recommendations = []
        
        # Payment history recommendations
        if request.late_payments_12m > 0:
            recommendations.append(
                "Set up automatic payments to avoid late payments. "
                f"You've had {request.late_payments_12m} late payments in the past year."
            )
        
        # Credit utilization recommendations
        if request.credit_utilization > 30:
            recommendations.append(
                f"Try to reduce your credit utilization from {request.credit_utilization:.1f}% to below 30%. "
                "Pay down balances or request credit limit increases."
            )
        
        # Credit history recommendations
        if request.credit_history_years < 2:
            recommendations.append(
                "Keep your oldest accounts open to build credit history length. "
                "Consider becoming an authorized user on a family member's old account."
            )
        
        # Credit mix recommendations
        if request.existing_loans < 2:
            recommendations.append(
                "Having a mix of credit types (credit card, installment loan) "
                "can improve your score. Consider a small installment loan if needed."
            )
        
        # Income/savings recommendations
        if request.savings_balance < request.monthly_income * 3:
            recommendations.append(
                "Build an emergency fund of 3-6 months of expenses. "
                "This improves your financial stability and loan eligibility."
            )
        
        # Add general tip based on rating
        if rating in [CreditRating.POOR, CreditRating.VERY_POOR]:
            recommendations.append(
                "Consider a secured credit card to rebuild credit. "
                "Make small purchases and pay in full each month."
            )
        
        return recommendations[:5]  # Limit to 5 recommendations
    
    def check_loan_eligibility(
        self,
        request: LoanEligibilityRequest,
        credit_score: Optional[int] = None,
    ) -> LoanEligibilityResponse:
        """Check loan eligibility and calculate terms."""
        # Use provided credit score or default
        score = credit_score or 650
        rating = self._score_to_rating(score)
        
        # Calculate debt-to-income ratio
        dti = (request.monthly_obligations / request.monthly_income * 100) if request.monthly_income > 0 else 100
        
        # Calculate maximum eligible amount based on income
        max_dti = 45  # Maximum acceptable DTI after new loan
        available_for_debt = (max_dti / 100) * request.monthly_income - request.monthly_obligations
        
        # Calculate interest rate
        base_rate = self.BASE_RATES.get(rating, 10.0)
        type_adjustment = self.LOAN_TYPE_ADJUSTMENTS.get(request.loan_type, 0)
        interest_rate = base_rate + type_adjustment
        
        # Calculate maximum loan amount based on available monthly payment
        if available_for_debt > 0:
            max_loan = self._calculate_max_loan_amount(
                available_for_debt,
                interest_rate,
                request.tenure_months,
            )
        else:
            max_loan = 0
        
        # Determine eligibility
        is_eligible = (
            request.loan_amount <= max_loan and
            dti < max_dti and
            rating not in [CreditRating.VERY_POOR] and
            score >= 500
        )
        
        # Calculate estimated monthly payment
        monthly_payment = self._calculate_monthly_payment(
            min(request.loan_amount, max_loan),
            interest_rate,
            request.tenure_months,
        )
        
        # Determine recommended tenure
        recommended_tenure = self._recommend_tenure(
            request.loan_amount,
            request.monthly_income,
            request.loan_type,
        )
        
        # Generate reasons and suggestions
        eligibility_reasons = self._generate_eligibility_reasons(
            is_eligible, score, dti, request.loan_amount, max_loan
        )
        improvement_suggestions = self._generate_improvement_suggestions(
            is_eligible, score, dti, rating
        )
        
        return LoanEligibilityResponse(
            user_id=request.user_id,
            loan_type=request.loan_type,
            requested_amount=request.loan_amount,
            is_eligible=is_eligible,
            max_eligible_amount=round(max_loan, 2),
            recommended_tenure=recommended_tenure,
            estimated_interest_rate=round(interest_rate, 2),
            estimated_monthly_payment=round(monthly_payment, 2),
            debt_to_income_ratio=round(dti, 2),
            eligibility_reasons=eligibility_reasons,
            improvement_suggestions=improvement_suggestions,
        )
    
    def _calculate_monthly_payment(
        self,
        principal: float,
        annual_rate: float,
        months: int,
    ) -> float:
        """Calculate monthly loan payment using amortization formula."""
        if principal <= 0 or months <= 0:
            return 0
        
        monthly_rate = annual_rate / 100 / 12
        
        if monthly_rate == 0:
            return principal / months
        
        payment = principal * (
            monthly_rate * (1 + monthly_rate) ** months
        ) / (
            (1 + monthly_rate) ** months - 1
        )
        
        return payment
    
    def _calculate_max_loan_amount(
        self,
        max_monthly_payment: float,
        annual_rate: float,
        months: int,
    ) -> float:
        """Calculate maximum loan amount based on monthly payment capacity."""
        if max_monthly_payment <= 0 or months <= 0:
            return 0
        
        monthly_rate = annual_rate / 100 / 12
        
        if monthly_rate == 0:
            return max_monthly_payment * months
        
        max_loan = max_monthly_payment * (
            (1 + monthly_rate) ** months - 1
        ) / (
            monthly_rate * (1 + monthly_rate) ** months
        )
        
        return max_loan
    
    def _recommend_tenure(
        self,
        loan_amount: float,
        monthly_income: float,
        loan_type: LoanType,
    ) -> int:
        """Recommend appropriate loan tenure."""
        # Target monthly payment as percentage of income
        target_payment_ratio = 0.25  # 25% of income
        target_monthly_payment = monthly_income * target_payment_ratio
        
        # Estimate tenure for this payment
        if target_monthly_payment <= 0:
            return 12
        
        estimated_months = loan_amount / target_monthly_payment
        
        # Apply loan type constraints
        max_tenures = {
            LoanType.HOME: 360,  # 30 years
            LoanType.CAR: 84,    # 7 years
            LoanType.PERSONAL: 60,  # 5 years
            LoanType.EDUCATION: 120,  # 10 years
            LoanType.BUSINESS: 84,   # 7 years
            LoanType.CREDIT_CARD: 36,  # 3 years
        }
        
        max_tenure = max_tenures.get(loan_type, 60)
        recommended = min(max_tenure, max(12, int(estimated_months * 1.2)))
        
        # Round to nearest 12 months
        return (recommended // 12) * 12 or 12
    
    def _generate_eligibility_reasons(
        self,
        is_eligible: bool,
        score: int,
        dti: float,
        requested: float,
        max_amount: float,
    ) -> List[str]:
        """Generate eligibility reasons."""
        reasons = []
        
        if is_eligible:
            reasons.append("✅ Credit score meets minimum requirements")
            reasons.append("✅ Debt-to-income ratio is acceptable")
            reasons.append("✅ Requested amount is within eligible limit")
        else:
            if score < 500:
                reasons.append("❌ Credit score is below minimum requirement (500)")
            if dti >= 45:
                reasons.append(f"❌ Debt-to-income ratio ({dti:.1f}%) exceeds maximum (45%)")
            if requested > max_amount:
                reasons.append(f"❌ Requested amount exceeds maximum eligible (RM {max_amount:,.2f})")
        
        return reasons
    
    def _generate_improvement_suggestions(
        self,
        is_eligible: bool,
        score: int,
        dti: float,
        rating: CreditRating,
    ) -> List[str]:
        """Generate improvement suggestions."""
        suggestions = []
        
        if not is_eligible or rating in [CreditRating.FAIR, CreditRating.POOR, CreditRating.VERY_POOR]:
            if score < 700:
                suggestions.append("Improve credit score by paying bills on time")
            if dti > 30:
                suggestions.append("Reduce existing debt to lower debt-to-income ratio")
            
            suggestions.append("Consider a smaller loan amount")
            suggestions.append("Add a co-signer with good credit")
            suggestions.append("Provide collateral for a secured loan")
        
        return suggestions
    
    def simulate_loan(
        self,
        principal: float,
        annual_rate: float,
        tenure_months: int,
    ) -> LoanSimulation:
        """Generate loan simulation with amortization schedule."""
        monthly_payment = self._calculate_monthly_payment(principal, annual_rate, tenure_months)
        total_payment = monthly_payment * tenure_months
        total_interest = total_payment - principal
        
        # Generate amortization schedule
        schedule = []
        balance = principal
        monthly_rate = annual_rate / 100 / 12
        
        for month in range(1, tenure_months + 1):
            interest_payment = balance * monthly_rate
            principal_payment = monthly_payment - interest_payment
            balance -= principal_payment
            
            schedule.append({
                "month": month,
                "payment": round(monthly_payment, 2),
                "principal": round(principal_payment, 2),
                "interest": round(interest_payment, 2),
                "balance": round(max(0, balance), 2),
            })
            
            # Only include first 12 and last 12 months for long loans
            if tenure_months > 24 and month == 12:
                schedule.append({
                    "month": "...",
                    "payment": "...",
                    "principal": "...",
                    "interest": "...",
                    "balance": "...",
                })
                # Skip to last 12 months
                for skip_month in range(13, tenure_months - 11):
                    interest_payment = balance * monthly_rate
                    principal_payment = monthly_payment - interest_payment
                    balance -= principal_payment
                break
        
        # Add last 12 months for long loans
        if tenure_months > 24:
            for month in range(tenure_months - 11, tenure_months + 1):
                interest_payment = balance * monthly_rate
                principal_payment = monthly_payment - interest_payment
                balance -= principal_payment
                
                schedule.append({
                    "month": month,
                    "payment": round(monthly_payment, 2),
                    "principal": round(principal_payment, 2),
                    "interest": round(interest_payment, 2),
                    "balance": round(max(0, balance), 2),
                })
        
        return LoanSimulation(
            loan_amount=principal,
            tenure_months=tenure_months,
            interest_rate=annual_rate,
            monthly_payment=round(monthly_payment, 2),
            total_interest=round(total_interest, 2),
            total_payment=round(total_payment, 2),
            amortization_schedule=schedule,
        )
    
    def assess_risk(
        self,
        user_id: str,
        credit_score: int,
        loan_amount: float,
        monthly_income: float,
        existing_debt: float,
    ) -> RiskAssessment:
        """Assess credit risk for a potential borrower."""
        risk_factors = []
        
        # Credit score factor
        score_risk = max(0, (700 - credit_score) / 400 * 30)
        if credit_score < 600:
            risk_factors.append({
                "factor": "Low Credit Score",
                "impact": 25,
                "description": f"Score of {credit_score} indicates higher default risk",
            })
        
        # DTI factor
        dti = (existing_debt / monthly_income * 100) if monthly_income > 0 else 100
        dti_risk = min(30, max(0, (dti - 20) / 50 * 30))
        if dti > 40:
            risk_factors.append({
                "factor": "High Debt-to-Income",
                "impact": 20,
                "description": f"DTI of {dti:.1f}% may strain repayment capacity",
            })
        
        # Loan-to-income factor
        lti = loan_amount / (monthly_income * 12) if monthly_income > 0 else 10
        lti_risk = min(20, max(0, (lti - 2) / 5 * 20))
        if lti > 4:
            risk_factors.append({
                "factor": "High Loan-to-Income",
                "impact": 15,
                "description": f"Loan amount is {lti:.1f}x annual income",
            })
        
        # Calculate total risk score
        risk_score = score_risk + dti_risk + lti_risk
        
        # Probability of default (simplified model)
        pod = min(0.5, risk_score / 100 * 0.5)
        
        # Expected loss
        expected_loss = loan_amount * pod * 0.5  # Assuming 50% recovery
        
        # Determine risk category
        if risk_score < 20:
            risk_category = "low"
        elif risk_score < 40:
            risk_category = "medium"
        elif risk_score < 60:
            risk_category = "high"
        else:
            risk_category = "very_high"
        
        # Mitigating factors
        mitigating = []
        if credit_score >= 700:
            mitigating.append("Good credit history")
        if dti < 30:
            mitigating.append("Low debt burden")
        if monthly_income > 5000:
            mitigating.append("Stable income level")
        
        return RiskAssessment(
            user_id=user_id,
            risk_score=round(risk_score, 2),
            risk_category=risk_category,
            probability_of_default=round(pod, 4),
            expected_loss=round(expected_loss, 2),
            risk_factors=risk_factors,
            mitigating_factors=mitigating,
        )


# Create singleton instance
credit_engine = CreditScoringEngine()
