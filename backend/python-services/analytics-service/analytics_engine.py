"""
Analytics Engine - Core analytics and ML processing.
"""
import pandas as pd
import numpy as np
from datetime import datetime, timedelta, date
from typing import List, Dict, Any, Optional, Tuple
from collections import defaultdict
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
import warnings

from models import (
    Transaction, SpendingByCategory, SpendingTrend, SpendingAnalyticsResponse,
    BudgetCategory, BudgetSummary, CashFlowForecast, FinancialHealthScore,
    AnomalyDetection, SpendingInsight, TimeRange, SpendingCategory
)

warnings.filterwarnings('ignore')


class AnalyticsEngine:
    """Core analytics processing engine."""
    
    # Category mapping based on keywords
    CATEGORY_KEYWORDS = {
        SpendingCategory.FOOD_DINING: ["restaurant", "cafe", "coffee", "food", "dining", "nando", "mcd", "kfc", "pizza", "sushi"],
        SpendingCategory.GROCERIES: ["grocery", "tesco", "aeon", "mydin", "jaya grocer", "cold storage", "giant", "lotus"],
        SpendingCategory.TRANSPORTATION: ["grab", "petrol", "shell", "petronas", "parking", "toll", "mrt", "lrt", "bus", "fuel"],
        SpendingCategory.UTILITIES: ["tnb", "tenaga", "air selangor", "water", "iwk", "syabas", "electric"],
        SpendingCategory.ENTERTAINMENT: ["netflix", "spotify", "astro", "disney", "cinema", "gsc", "tgv", "game"],
        SpendingCategory.SHOPPING: ["lazada", "shopee", "zalora", "amazon", "ikea", "uniqlo", "h&m", "zara"],
        SpendingCategory.HEALTHCARE: ["pharmacy", "clinic", "hospital", "guardian", "watson", "doctor", "medical"],
        SpendingCategory.EDUCATION: ["tuition", "school", "university", "course", "book", "education"],
        SpendingCategory.TRAVEL: ["hotel", "airasia", "mas", "booking", "agoda", "airbnb", "flight"],
        SpendingCategory.BILLS: ["bill", "unifi", "maxis", "celcom", "digi", "insurance", "ptptn"],
        SpendingCategory.TRANSFERS: ["transfer", "payment to"],
        SpendingCategory.INVESTMENTS: ["investment", "stock", "crypto", "gold", "asb", "unit trust"],
    }
    
    def __init__(self):
        self.scaler = StandardScaler()
        self.anomaly_detector = IsolationForest(contamination=0.05, random_state=42)
    
    def categorize_transaction(self, description: str) -> str:
        """Categorize a transaction based on description."""
        description_lower = description.lower()
        
        for category, keywords in self.CATEGORY_KEYWORDS.items():
            if any(keyword in description_lower for keyword in keywords):
                return category.value
        
        return SpendingCategory.OTHER.value
    
    def analyze_spending(
        self,
        transactions: List[Dict[str, Any]],
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
    ) -> SpendingAnalyticsResponse:
        """Perform comprehensive spending analysis."""
        if not transactions:
            return self._empty_analytics_response()
        
        # Convert to DataFrame
        df = pd.DataFrame(transactions)
        df['date'] = pd.to_datetime(df['date'])
        df['amount'] = df['amount'].astype(float)
        
        # Apply date filter
        if start_date:
            df = df[df['date'].dt.date >= start_date]
        if end_date:
            df = df[df['date'].dt.date <= end_date]
        
        if df.empty:
            return self._empty_analytics_response()
        
        # Categorize transactions
        df['category'] = df['description'].apply(self.categorize_transaction)
        
        # Separate income and expenses
        df['is_income'] = df['type'].isin(['credit', 'salary'])
        
        income_df = df[df['is_income']]
        expense_df = df[~df['is_income']]
        
        total_income = income_df['amount'].sum()
        total_expenses = expense_df['amount'].sum()
        net_savings = total_income - total_expenses
        savings_rate = (net_savings / total_income * 100) if total_income > 0 else 0
        
        # Category breakdown
        by_category = self._calculate_category_breakdown(expense_df)
        
        # Top merchants
        top_merchants = self._get_top_merchants(expense_df)
        
        # Trends
        trends = self._calculate_trends(df)
        
        # Generate insights
        insights = self._generate_insights(df, by_category, savings_rate)
        
        return SpendingAnalyticsResponse(
            period_start=df['date'].min().date(),
            period_end=df['date'].max().date(),
            total_income=round(total_income, 2),
            total_expenses=round(total_expenses, 2),
            net_savings=round(net_savings, 2),
            savings_rate=round(savings_rate, 2),
            by_category=by_category,
            top_merchants=top_merchants,
            trends=trends,
            insights=insights,
        )
    
    def _calculate_category_breakdown(self, expense_df: pd.DataFrame) -> List[SpendingByCategory]:
        """Calculate spending breakdown by category."""
        if expense_df.empty:
            return []
        
        category_stats = expense_df.groupby('category').agg({
            'amount': ['sum', 'count', 'mean']
        }).reset_index()
        category_stats.columns = ['category', 'total', 'count', 'average']
        
        total_spending = category_stats['total'].sum()
        
        result = []
        for _, row in category_stats.iterrows():
            result.append(SpendingByCategory(
                category=row['category'],
                amount=round(row['total'], 2),
                percentage=round((row['total'] / total_spending * 100) if total_spending > 0 else 0, 2),
                transaction_count=int(row['count']),
                average_transaction=round(row['average'], 2),
            ))
        
        return sorted(result, key=lambda x: x.amount, reverse=True)
    
    def _get_top_merchants(self, expense_df: pd.DataFrame, limit: int = 10) -> List[Dict[str, Any]]:
        """Get top merchants by spending."""
        if expense_df.empty:
            return []
        
        merchant_stats = expense_df.groupby('description').agg({
            'amount': ['sum', 'count']
        }).reset_index()
        merchant_stats.columns = ['merchant', 'total', 'count']
        merchant_stats = merchant_stats.sort_values('total', ascending=False).head(limit)
        
        return [
            {
                "merchant": row['merchant'],
                "total_spent": round(row['total'], 2),
                "transaction_count": int(row['count']),
            }
            for _, row in merchant_stats.iterrows()
        ]
    
    def _calculate_trends(self, df: pd.DataFrame) -> List[SpendingTrend]:
        """Calculate spending trends over time."""
        if df.empty:
            return []
        
        df['period'] = df['date'].dt.to_period('M').astype(str)
        
        trends = []
        for period in df['period'].unique():
            period_df = df[df['period'] == period]
            
            income = period_df[period_df['is_income']]['amount'].sum()
            expenses = period_df[~period_df['is_income']]['amount'].sum()
            
            category_spending = period_df[~period_df['is_income']].groupby('category')['amount'].sum().to_dict()
            
            trends.append(SpendingTrend(
                period=period,
                total_spending=round(expenses, 2),
                total_income=round(income, 2),
                net_flow=round(income - expenses, 2),
                categories=category_spending,
            ))
        
        return sorted(trends, key=lambda x: x.period)
    
    def _generate_insights(
        self,
        df: pd.DataFrame,
        by_category: List[SpendingByCategory],
        savings_rate: float,
    ) -> List[str]:
        """Generate AI-powered spending insights."""
        insights = []
        
        # Savings rate insight
        if savings_rate >= 20:
            insights.append(f"🌟 Excellent! You're saving {savings_rate:.1f}% of your income. Keep it up!")
        elif savings_rate >= 10:
            insights.append(f"👍 Good job saving {savings_rate:.1f}% of your income. Aim for 20% to build wealth faster.")
        elif savings_rate > 0:
            insights.append(f"⚠️ You're only saving {savings_rate:.1f}% of your income. Consider reducing expenses.")
        else:
            insights.append("🚨 You're spending more than you earn! Review your expenses urgently.")
        
        # Category insights
        if by_category:
            top_category = by_category[0]
            insights.append(
                f"📊 Your highest spending category is {top_category.category.replace('_', ' ').title()} "
                f"at RM {top_category.amount:.2f} ({top_category.percentage:.1f}% of expenses)."
            )
            
            # Food spending check
            food_spending = next(
                (c for c in by_category if c.category in ['food_dining', 'groceries']), 
                None
            )
            if food_spending and food_spending.percentage > 30:
                insights.append(
                    f"🍽️ Food & groceries make up {food_spending.percentage:.1f}% of your spending. "
                    "Consider meal planning to reduce costs."
                )
        
        # Trend insights
        if len(df) > 0:
            expense_df = df[~df['is_income']]
            if len(expense_df) > 10:
                avg_transaction = expense_df['amount'].mean()
                max_transaction = expense_df['amount'].max()
                
                if max_transaction > avg_transaction * 5:
                    insights.append(
                        f"📈 You have some large transactions (up to RM {max_transaction:.2f}). "
                        "Consider spreading large purchases over time."
                    )
        
        return insights
    
    def _empty_analytics_response(self) -> SpendingAnalyticsResponse:
        """Return empty analytics response."""
        today = date.today()
        return SpendingAnalyticsResponse(
            period_start=today,
            period_end=today,
            total_income=0,
            total_expenses=0,
            net_savings=0,
            savings_rate=0,
            by_category=[],
            top_merchants=[],
            trends=[],
            insights=["No transactions found for the selected period."],
        )
    
    def analyze_budget(
        self,
        transactions: List[Dict[str, Any]],
        budgets: Dict[str, float],
        month: str,  # Format: YYYY-MM
    ) -> BudgetSummary:
        """Analyze spending against budget."""
        df = pd.DataFrame(transactions) if transactions else pd.DataFrame()
        
        if not df.empty:
            df['date'] = pd.to_datetime(df['date'])
            df['month'] = df['date'].dt.to_period('M').astype(str)
            df = df[df['month'] == month]
            df['category'] = df['description'].apply(self.categorize_transaction)
            df = df[~df['type'].isin(['credit', 'salary'])]  # Only expenses
        
        categories = []
        total_budget = sum(budgets.values())
        total_spent = 0
        
        for category, budget_amount in budgets.items():
            spent = df[df['category'] == category]['amount'].sum() if not df.empty else 0
            total_spent += spent
            remaining = budget_amount - spent
            percentage_used = (spent / budget_amount * 100) if budget_amount > 0 else 0
            
            categories.append(BudgetCategory(
                category=category,
                budget_amount=round(budget_amount, 2),
                spent_amount=round(spent, 2),
                remaining=round(remaining, 2),
                percentage_used=round(percentage_used, 2),
                is_over_budget=spent > budget_amount,
            ))
        
        # Sort by percentage used (descending)
        categories.sort(key=lambda x: x.percentage_used, reverse=True)
        
        # Generate recommendations
        recommendations = self._generate_budget_recommendations(categories)
        
        return BudgetSummary(
            month=month,
            total_budget=round(total_budget, 2),
            total_spent=round(total_spent, 2),
            remaining=round(total_budget - total_spent, 2),
            categories=categories,
            recommendations=recommendations,
        )
    
    def _generate_budget_recommendations(self, categories: List[BudgetCategory]) -> List[str]:
        """Generate budget recommendations."""
        recommendations = []
        
        over_budget = [c for c in categories if c.is_over_budget]
        near_budget = [c for c in categories if 80 <= c.percentage_used < 100]
        under_budget = [c for c in categories if c.percentage_used < 50]
        
        if over_budget:
            for c in over_budget:
                recommendations.append(
                    f"🚨 You've exceeded your {c.category} budget by RM {abs(c.remaining):.2f}. "
                    "Consider reducing spending in this category."
                )
        
        if near_budget:
            for c in near_budget:
                recommendations.append(
                    f"⚠️ You've used {c.percentage_used:.1f}% of your {c.category} budget. "
                    "Be careful with remaining spending."
                )
        
        if under_budget:
            recommendations.append(
                f"💡 You're under budget in {len(under_budget)} categories. "
                "Consider moving unused funds to savings."
            )
        
        return recommendations
    
    def forecast_cash_flow(
        self,
        transactions: List[Dict[str, Any]],
        months_ahead: int = 3,
    ) -> List[CashFlowForecast]:
        """Forecast future cash flow using linear regression."""
        if not transactions:
            return []
        
        df = pd.DataFrame(transactions)
        df['date'] = pd.to_datetime(df['date'])
        df['is_income'] = df['type'].isin(['credit', 'salary'])
        
        # Group by month
        df['month'] = df['date'].dt.to_period('M')
        monthly = df.groupby(['month', 'is_income'])['amount'].sum().unstack(fill_value=0)
        monthly.columns = ['expenses', 'income']
        monthly = monthly.reset_index()
        monthly['month_num'] = range(len(monthly))
        
        if len(monthly) < 3:
            return []  # Not enough data for forecasting
        
        # Train models
        X = monthly['month_num'].values.reshape(-1, 1)
        
        income_model = LinearRegression()
        income_model.fit(X, monthly['income'].values)
        
        expense_model = LinearRegression()
        expense_model.fit(X, monthly['expenses'].values)
        
        # Forecast
        forecasts = []
        last_month = monthly['month'].iloc[-1]
        current_balance = monthly['income'].sum() - monthly['expenses'].sum()
        
        for i in range(1, months_ahead + 1):
            future_month_num = len(monthly) + i - 1
            forecast_date = (last_month + i).to_timestamp().date()
            
            predicted_income = max(0, income_model.predict([[future_month_num]])[0])
            predicted_expenses = max(0, expense_model.predict([[future_month_num]])[0])
            
            current_balance += predicted_income - predicted_expenses
            
            # Calculate confidence (simple approach based on data points)
            confidence = min(0.9, 0.5 + (len(monthly) * 0.05))
            
            forecasts.append(CashFlowForecast(
                forecast_date=forecast_date,
                predicted_balance=round(current_balance, 2),
                predicted_income=round(predicted_income, 2),
                predicted_expenses=round(predicted_expenses, 2),
                confidence_level=round(confidence, 2),
                assumptions=[
                    "Based on historical spending patterns",
                    "Assumes consistent income",
                    "Does not account for unexpected expenses",
                ],
            ))
        
        return forecasts
    
    def calculate_financial_health(
        self,
        transactions: List[Dict[str, Any]],
        account_balance: float,
    ) -> FinancialHealthScore:
        """Calculate comprehensive financial health score."""
        if not transactions:
            return self._default_financial_health()
        
        df = pd.DataFrame(transactions)
        df['date'] = pd.to_datetime(df['date'])
        df['is_income'] = df['type'].isin(['credit', 'salary'])
        
        # Calculate metrics
        monthly_income = df[df['is_income']]['amount'].sum() / max(1, len(df['date'].dt.to_period('M').unique()))
        monthly_expenses = df[~df['is_income']]['amount'].sum() / max(1, len(df['date'].dt.to_period('M').unique()))
        
        savings_rate = ((monthly_income - monthly_expenses) / monthly_income * 100) if monthly_income > 0 else 0
        emergency_fund_months = account_balance / monthly_expenses if monthly_expenses > 0 else 0
        
        # Component scores
        components = {
            "savings_rate": self._score_savings_rate(savings_rate),
            "emergency_fund": self._score_emergency_fund(emergency_fund_months),
            "spending_consistency": self._score_spending_consistency(df[~df['is_income']]),
            "income_stability": self._score_income_stability(df[df['is_income']]),
        }
        
        # Overall score (weighted average)
        overall_score = int(
            components["savings_rate"] * 0.30 +
            components["emergency_fund"] * 0.30 +
            components["spending_consistency"] * 0.20 +
            components["income_stability"] * 0.20
        )
        
        # Determine grade
        grade = self._score_to_grade(overall_score)
        
        # Generate feedback
        strengths, improvements, recommendations = self._generate_health_feedback(
            components, savings_rate, emergency_fund_months
        )
        
        return FinancialHealthScore(
            overall_score=overall_score,
            grade=grade,
            components=components,
            strengths=strengths,
            areas_for_improvement=improvements,
            recommendations=recommendations,
        )
    
    def _score_savings_rate(self, rate: float) -> int:
        """Score based on savings rate."""
        if rate >= 30:
            return 100
        elif rate >= 20:
            return 85
        elif rate >= 10:
            return 70
        elif rate >= 5:
            return 55
        elif rate > 0:
            return 40
        else:
            return 20
    
    def _score_emergency_fund(self, months: float) -> int:
        """Score based on emergency fund months."""
        if months >= 6:
            return 100
        elif months >= 3:
            return 80
        elif months >= 1:
            return 60
        else:
            return 30
    
    def _score_spending_consistency(self, expense_df: pd.DataFrame) -> int:
        """Score based on spending consistency."""
        if expense_df.empty:
            return 50
        
        expense_df = expense_df.copy()
        expense_df['month'] = expense_df['date'].dt.to_period('M')
        monthly_spending = expense_df.groupby('month')['amount'].sum()
        
        if len(monthly_spending) < 2:
            return 70
        
        cv = monthly_spending.std() / monthly_spending.mean() if monthly_spending.mean() > 0 else 0
        
        if cv < 0.1:
            return 100
        elif cv < 0.2:
            return 85
        elif cv < 0.3:
            return 70
        elif cv < 0.5:
            return 50
        else:
            return 30
    
    def _score_income_stability(self, income_df: pd.DataFrame) -> int:
        """Score based on income stability."""
        if income_df.empty:
            return 50
        
        income_df = income_df.copy()
        income_df['month'] = income_df['date'].dt.to_period('M')
        monthly_income = income_df.groupby('month')['amount'].sum()
        
        if len(monthly_income) < 2:
            return 70
        
        cv = monthly_income.std() / monthly_income.mean() if monthly_income.mean() > 0 else 0
        
        if cv < 0.1:
            return 100
        elif cv < 0.2:
            return 85
        elif cv < 0.3:
            return 70
        else:
            return 50
    
    def _score_to_grade(self, score: int) -> str:
        """Convert score to letter grade."""
        if score >= 90:
            return "A"
        elif score >= 80:
            return "B"
        elif score >= 70:
            return "C"
        elif score >= 60:
            return "D"
        else:
            return "F"
    
    def _generate_health_feedback(
        self,
        components: Dict[str, int],
        savings_rate: float,
        emergency_months: float,
    ) -> Tuple[List[str], List[str], List[str]]:
        """Generate health feedback."""
        strengths = []
        improvements = []
        recommendations = []
        
        # Savings rate feedback
        if components["savings_rate"] >= 80:
            strengths.append("Strong savings habit")
        else:
            improvements.append("Savings rate needs improvement")
            recommendations.append(
                f"Try to save at least 20% of your income. Currently saving {savings_rate:.1f}%."
            )
        
        # Emergency fund feedback
        if components["emergency_fund"] >= 80:
            strengths.append(f"Good emergency fund ({emergency_months:.1f} months)")
        else:
            improvements.append("Emergency fund is below recommended level")
            recommendations.append(
                f"Build an emergency fund covering 6 months of expenses. "
                f"Currently at {emergency_months:.1f} months."
            )
        
        # Consistency feedback
        if components["spending_consistency"] >= 70:
            strengths.append("Consistent spending patterns")
        else:
            improvements.append("Irregular spending patterns")
            recommendations.append("Create a monthly budget and stick to it.")
        
        # Income feedback
        if components["income_stability"] >= 70:
            strengths.append("Stable income")
        else:
            improvements.append("Income variability is high")
            recommendations.append("Consider building multiple income streams.")
        
        return strengths, improvements, recommendations
    
    def _default_financial_health(self) -> FinancialHealthScore:
        """Return default financial health score."""
        return FinancialHealthScore(
            overall_score=50,
            grade="C",
            components={
                "savings_rate": 50,
                "emergency_fund": 50,
                "spending_consistency": 50,
                "income_stability": 50,
            },
            strengths=[],
            areas_for_improvement=["Insufficient data for analysis"],
            recommendations=["Use the app more to get better financial insights"],
        )
    
    def detect_anomalies(
        self,
        transactions: List[Dict[str, Any]],
    ) -> List[AnomalyDetection]:
        """Detect anomalous transactions."""
        if len(transactions) < 10:
            return []
        
        df = pd.DataFrame(transactions)
        df['date'] = pd.to_datetime(df['date'])
        df['category'] = df['description'].apply(self.categorize_transaction)
        
        anomalies = []
        
        # Category-based anomaly detection
        for category in df['category'].unique():
            category_df = df[df['category'] == category]
            if len(category_df) < 5:
                continue
            
            amounts = category_df['amount'].values.reshape(-1, 1)
            scaled = self.scaler.fit_transform(amounts)
            
            self.anomaly_detector.fit(scaled)
            predictions = self.anomaly_detector.predict(scaled)
            
            anomaly_indices = np.where(predictions == -1)[0]
            
            for idx in anomaly_indices:
                row = category_df.iloc[idx]
                expected = category_df['amount'].median()
                
                anomalies.append(AnomalyDetection(
                    transaction_id=row['transaction_id'],
                    anomaly_type="unusual_amount",
                    severity="medium" if row['amount'] > expected * 2 else "low",
                    description=f"Unusual {category} transaction amount",
                    expected_value=round(expected, 2),
                    actual_value=round(row['amount'], 2),
                ))
        
        return anomalies


# Create singleton instance
analytics_engine = AnalyticsEngine()
