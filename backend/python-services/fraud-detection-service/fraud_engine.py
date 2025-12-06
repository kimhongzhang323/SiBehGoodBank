"""
Fraud Detection Engine - Core ML-based fraud detection.
"""
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional, Tuple
from collections import defaultdict
from sklearn.ensemble import IsolationForest, RandomForestClassifier
from sklearn.preprocessing import StandardScaler
import joblib
import os

from config import settings
from models import (
    TransactionRequest, FraudAssessment, FraudIndicator,
    RiskLevel, FraudType, UserBehaviorProfile, VelocityCheck
)


class FraudDetectionEngine:
    """ML-based fraud detection engine."""
    
    def __init__(self):
        self.scaler = StandardScaler()
        self.isolation_forest = IsolationForest(
            contamination=0.05,
            random_state=42,
            n_estimators=100,
        )
        self.user_profiles: Dict[str, UserBehaviorProfile] = {}
        self.velocity_tracker: Dict[str, List[Dict]] = defaultdict(list)
        self._is_fitted = False
    
    def assess_transaction(
        self,
        transaction: TransactionRequest,
        historical_transactions: List[Dict[str, Any]] = None,
    ) -> FraudAssessment:
        """Perform comprehensive fraud assessment on a transaction."""
        indicators = []
        risk_scores = []
        
        # 1. Amount anomaly check
        amount_result = self._check_amount_anomaly(
            transaction, historical_transactions or []
        )
        if amount_result:
            indicators.append(amount_result)
            risk_scores.append(amount_result.score)
        
        # 2. Velocity check
        velocity_result = self._check_velocity(transaction)
        if velocity_result:
            indicators.append(velocity_result)
            risk_scores.append(velocity_result.score)
        
        # 3. Time anomaly check
        time_result = self._check_time_anomaly(transaction, historical_transactions or [])
        if time_result:
            indicators.append(time_result)
            risk_scores.append(time_result.score)
        
        # 4. Location anomaly check
        location_result = self._check_location_anomaly(transaction, historical_transactions or [])
        if location_result:
            indicators.append(location_result)
            risk_scores.append(location_result.score)
        
        # 5. Merchant anomaly check
        merchant_result = self._check_merchant_anomaly(transaction, historical_transactions or [])
        if merchant_result:
            indicators.append(merchant_result)
            risk_scores.append(merchant_result.score)
        
        # 6. Pattern anomaly (ML-based)
        if historical_transactions and len(historical_transactions) >= 10:
            pattern_result = self._check_pattern_anomaly(transaction, historical_transactions)
            if pattern_result:
                indicators.append(pattern_result)
                risk_scores.append(pattern_result.score)
        
        # Calculate overall risk score (weighted average)
        if risk_scores:
            # Apply weights based on indicator type
            overall_score = self._calculate_weighted_score(indicators)
        else:
            overall_score = 0.0
        
        # Determine risk level
        risk_level = self._score_to_risk_level(overall_score)
        
        # Determine action
        action, recommendation = self._determine_action(overall_score, risk_level, indicators)
        
        # Update velocity tracker
        self._update_velocity_tracker(transaction)
        
        return FraudAssessment(
            transaction_id=transaction.transaction_id,
            risk_score=round(overall_score, 3),
            risk_level=risk_level,
            is_fraudulent=overall_score >= 0.8,
            requires_review=0.5 <= overall_score < 0.8,
            indicators=indicators,
            recommendation=recommendation,
            action=action,
        )
    
    def _check_amount_anomaly(
        self,
        transaction: TransactionRequest,
        history: List[Dict[str, Any]],
    ) -> Optional[FraudIndicator]:
        """Check if transaction amount is anomalous."""
        amount = transaction.amount
        
        # High amount threshold check
        if amount >= settings.high_risk_amount_threshold:
            return FraudIndicator(
                indicator_type=FraudType.UNUSUAL_AMOUNT,
                score=min(0.9, 0.5 + (amount / settings.high_risk_amount_threshold - 1) * 0.2),
                description=f"High value transaction: RM {amount:.2f}",
                evidence={
                    "amount": amount,
                    "threshold": settings.high_risk_amount_threshold,
                },
            )
        
        if not history:
            return None
        
        # Statistical anomaly check
        amounts = [t.get('amount', 0) for t in history]
        if not amounts:
            return None
        
        mean_amount = np.mean(amounts)
        std_amount = np.std(amounts)
        
        if std_amount > 0:
            z_score = (amount - mean_amount) / std_amount
            
            if z_score > 3:
                return FraudIndicator(
                    indicator_type=FraudType.UNUSUAL_AMOUNT,
                    score=min(0.95, 0.5 + (z_score - 3) * 0.1),
                    description=f"Transaction amount significantly higher than usual (Z-score: {z_score:.2f})",
                    evidence={
                        "amount": amount,
                        "mean": round(mean_amount, 2),
                        "std": round(std_amount, 2),
                        "z_score": round(z_score, 2),
                    },
                )
        
        return None
    
    def _check_velocity(self, transaction: TransactionRequest) -> Optional[FraudIndicator]:
        """Check transaction velocity (frequency)."""
        user_id = transaction.user_id
        current_time = transaction.timestamp
        window_start = current_time - timedelta(minutes=settings.velocity_window_minutes)
        
        # Get recent transactions
        recent = [
            t for t in self.velocity_tracker.get(user_id, [])
            if t['timestamp'] > window_start
        ]
        
        transaction_count = len(recent) + 1  # Include current
        total_amount = sum(t['amount'] for t in recent) + transaction.amount
        
        if transaction_count > settings.max_transactions_per_hour:
            return FraudIndicator(
                indicator_type=FraudType.VELOCITY_ABUSE,
                score=min(0.95, 0.6 + (transaction_count - settings.max_transactions_per_hour) * 0.05),
                description=f"High transaction velocity: {transaction_count} transactions in {settings.velocity_window_minutes} minutes",
                evidence={
                    "count": transaction_count,
                    "limit": settings.max_transactions_per_hour,
                    "window_minutes": settings.velocity_window_minutes,
                    "total_amount": round(total_amount, 2),
                },
            )
        
        return None
    
    def _check_time_anomaly(
        self,
        transaction: TransactionRequest,
        history: List[Dict[str, Any]],
    ) -> Optional[FraudIndicator]:
        """Check if transaction time is unusual for this user."""
        current_hour = transaction.timestamp.hour
        
        # Suspicious hours (late night/early morning)
        suspicious_hours = list(range(0, 6)) + list(range(23, 24))
        
        if current_hour in suspicious_hours:
            if not history:
                return FraudIndicator(
                    indicator_type=FraudType.UNUSUAL_TIME,
                    score=0.4,
                    description=f"Transaction at unusual hour: {current_hour}:00",
                    evidence={"hour": current_hour},
                )
            
            # Check if user typically transacts at this hour
            hours = [datetime.fromisoformat(t.get('date', t.get('timestamp', ''))).hour 
                     for t in history if t.get('date') or t.get('timestamp')]
            
            if hours:
                hour_counts = pd.Series(hours).value_counts()
                if current_hour not in hour_counts or hour_counts.get(current_hour, 0) < 2:
                    return FraudIndicator(
                        indicator_type=FraudType.UNUSUAL_TIME,
                        score=0.5,
                        description=f"Transaction at hour {current_hour}:00 - unusual for this user",
                        evidence={
                            "hour": current_hour,
                            "typical_hours": hour_counts.head(5).to_dict(),
                        },
                    )
        
        return None
    
    def _check_location_anomaly(
        self,
        transaction: TransactionRequest,
        history: List[Dict[str, Any]],
    ) -> Optional[FraudIndicator]:
        """Check if transaction location is unusual."""
        if not transaction.location:
            return None
        
        current_lat = transaction.location.get('lat')
        current_lng = transaction.location.get('lng')
        
        if current_lat is None or current_lng is None:
            return None
        
        # Check for international transactions
        if transaction.merchant_country != "MY":
            return FraudIndicator(
                indicator_type=FraudType.UNUSUAL_LOCATION,
                score=0.6,
                description=f"International transaction in {transaction.merchant_country}",
                evidence={
                    "country": transaction.merchant_country,
                    "expected": "MY",
                },
            )
        
        # Check distance from typical locations
        if history:
            locations = [
                t.get('location') for t in history 
                if t.get('location') and t['location'].get('lat') and t['location'].get('lng')
            ]
            
            if locations:
                # Calculate centroid of historical locations
                avg_lat = np.mean([loc['lat'] for loc in locations])
                avg_lng = np.mean([loc['lng'] for loc in locations])
                
                # Calculate distance (simplified)
                distance = np.sqrt(
                    (current_lat - avg_lat) ** 2 + 
                    (current_lng - avg_lng) ** 2
                ) * 111  # Rough km conversion
                
                if distance > 100:  # More than 100km from typical area
                    return FraudIndicator(
                        indicator_type=FraudType.UNUSUAL_LOCATION,
                        score=min(0.8, 0.4 + distance / 500),
                        description=f"Transaction {distance:.0f}km from usual location",
                        evidence={
                            "distance_km": round(distance, 2),
                            "current_location": {"lat": current_lat, "lng": current_lng},
                            "typical_location": {"lat": avg_lat, "lng": avg_lng},
                        },
                    )
        
        return None
    
    def _check_merchant_anomaly(
        self,
        transaction: TransactionRequest,
        history: List[Dict[str, Any]],
    ) -> Optional[FraudIndicator]:
        """Check if merchant is unusual for this user."""
        if not history or not transaction.merchant_category:
            return None
        
        # Get historical merchant categories
        categories = [t.get('merchant_category') or t.get('category') for t in history if t.get('merchant_category') or t.get('category')]
        
        if not categories:
            return None
        
        category_counts = pd.Series(categories).value_counts()
        
        # Check if this is a new category
        if transaction.merchant_category not in category_counts:
            # High-risk categories
            high_risk_categories = ['gambling', 'crypto', 'adult', 'money_transfer', 'jewelry']
            
            if any(risk in transaction.merchant_category.lower() for risk in high_risk_categories):
                return FraudIndicator(
                    indicator_type=FraudType.MERCHANT_FRAUD,
                    score=0.7,
                    description=f"First transaction in high-risk category: {transaction.merchant_category}",
                    evidence={
                        "category": transaction.merchant_category,
                        "is_first_time": True,
                        "typical_categories": category_counts.head(5).to_dict(),
                    },
                )
        
        return None
    
    def _check_pattern_anomaly(
        self,
        transaction: TransactionRequest,
        history: List[Dict[str, Any]],
    ) -> Optional[FraudIndicator]:
        """ML-based pattern anomaly detection using Isolation Forest."""
        try:
            # Prepare features
            features = self._extract_features(transaction, history)
            
            # Train if not fitted
            if not self._is_fitted and len(history) >= 20:
                historical_features = [
                    self._extract_features_from_dict(t) for t in history
                ]
                historical_features = [f for f in historical_features if f is not None]
                
                if len(historical_features) >= 10:
                    X_train = np.array(historical_features)
                    self.scaler.fit(X_train)
                    self.isolation_forest.fit(self.scaler.transform(X_train))
                    self._is_fitted = True
            
            if self._is_fitted:
                features_scaled = self.scaler.transform([features])
                score = self.isolation_forest.decision_function(features_scaled)[0]
                prediction = self.isolation_forest.predict(features_scaled)[0]
                
                # Convert to anomaly score (0-1)
                anomaly_score = max(0, min(1, -score + 0.5))
                
                if prediction == -1:  # Anomaly detected
                    return FraudIndicator(
                        indicator_type=FraudType.PATTERN_ANOMALY,
                        score=anomaly_score,
                        description="Transaction pattern deviates from normal behavior",
                        evidence={
                            "ml_score": round(float(score), 4),
                            "is_anomaly": True,
                        },
                    )
        except Exception as e:
            pass  # Silently fail for ML check
        
        return None
    
    def _extract_features(self, transaction: TransactionRequest, history: List[Dict]) -> List[float]:
        """Extract numerical features from transaction."""
        hour = transaction.timestamp.hour
        day_of_week = transaction.timestamp.weekday()
        
        return [
            transaction.amount,
            hour,
            day_of_week,
            1 if transaction.channel == 'online' else 0,
            1 if transaction.merchant_country != 'MY' else 0,
        ]
    
    def _extract_features_from_dict(self, transaction: Dict) -> Optional[List[float]]:
        """Extract features from transaction dict."""
        try:
            date_str = transaction.get('date') or transaction.get('timestamp')
            if date_str:
                dt = datetime.fromisoformat(date_str.replace('Z', '+00:00')) if isinstance(date_str, str) else date_str
                hour = dt.hour
                day_of_week = dt.weekday()
            else:
                hour = 12
                day_of_week = 0
            
            return [
                float(transaction.get('amount', 0)),
                hour,
                day_of_week,
                1 if transaction.get('channel') == 'online' else 0,
                0,  # Assuming domestic
            ]
        except:
            return None
    
    def _calculate_weighted_score(self, indicators: List[FraudIndicator]) -> float:
        """Calculate weighted risk score from indicators."""
        if not indicators:
            return 0.0
        
        # Weights by indicator type
        weights = {
            FraudType.VELOCITY_ABUSE: 1.5,
            FraudType.ACCOUNT_TAKEOVER: 2.0,
            FraudType.UNUSUAL_AMOUNT: 1.2,
            FraudType.UNUSUAL_LOCATION: 1.3,
            FraudType.UNUSUAL_TIME: 0.8,
            FraudType.PATTERN_ANOMALY: 1.4,
            FraudType.MERCHANT_FRAUD: 1.3,
            FraudType.DEVICE_ANOMALY: 1.5,
            FraudType.MONEY_LAUNDERING: 2.0,
        }
        
        weighted_sum = sum(
            i.score * weights.get(i.indicator_type, 1.0) 
            for i in indicators
        )
        total_weight = sum(weights.get(i.indicator_type, 1.0) for i in indicators)
        
        # Boost score if multiple indicators
        base_score = weighted_sum / total_weight if total_weight > 0 else 0
        multiplier = 1 + (len(indicators) - 1) * 0.1
        
        return min(1.0, base_score * multiplier)
    
    def _score_to_risk_level(self, score: float) -> RiskLevel:
        """Convert numerical score to risk level."""
        if score >= 0.8:
            return RiskLevel.CRITICAL
        elif score >= 0.6:
            return RiskLevel.HIGH
        elif score >= 0.4:
            return RiskLevel.MEDIUM
        else:
            return RiskLevel.LOW
    
    def _determine_action(
        self,
        score: float,
        risk_level: RiskLevel,
        indicators: List[FraudIndicator],
    ) -> Tuple[str, str]:
        """Determine action and recommendation based on assessment."""
        if risk_level == RiskLevel.CRITICAL:
            return "decline", "Transaction declined due to high fraud risk. Please contact customer support."
        elif risk_level == RiskLevel.HIGH:
            return "challenge", "Additional verification required. Please verify your identity."
        elif risk_level == RiskLevel.MEDIUM:
            return "review", "Transaction flagged for review. May require additional verification."
        else:
            return "approve", "Transaction approved."
    
    def _update_velocity_tracker(self, transaction: TransactionRequest):
        """Update velocity tracking for user."""
        user_id = transaction.user_id
        
        # Clean old entries
        window_start = datetime.now() - timedelta(minutes=settings.velocity_window_minutes * 2)
        self.velocity_tracker[user_id] = [
            t for t in self.velocity_tracker[user_id]
            if t['timestamp'] > window_start
        ]
        
        # Add current transaction
        self.velocity_tracker[user_id].append({
            'transaction_id': transaction.transaction_id,
            'amount': transaction.amount,
            'timestamp': transaction.timestamp,
        })
    
    def get_velocity_check(self, user_id: str) -> VelocityCheck:
        """Get velocity check for a user."""
        current_time = datetime.now()
        window_start = current_time - timedelta(minutes=settings.velocity_window_minutes)
        
        recent = [
            t for t in self.velocity_tracker.get(user_id, [])
            if t['timestamp'] > window_start
        ]
        
        return VelocityCheck(
            user_id=user_id,
            window_minutes=settings.velocity_window_minutes,
            transaction_count=len(recent),
            total_amount=sum(t['amount'] for t in recent),
            is_exceeded=len(recent) >= settings.max_transactions_per_hour,
            limit=settings.max_transactions_per_hour,
        )
    
    def update_user_profile(self, user_id: str, transactions: List[Dict[str, Any]]):
        """Update user behavior profile based on transaction history."""
        if not transactions:
            return
        
        amounts = [t.get('amount', 0) for t in transactions]
        
        hours = []
        for t in transactions:
            date_str = t.get('date') or t.get('timestamp')
            if date_str:
                try:
                    dt = datetime.fromisoformat(date_str.replace('Z', '+00:00')) if isinstance(date_str, str) else date_str
                    hours.append(dt.hour)
                except:
                    pass
        
        merchants = [t.get('merchant_name') or t.get('description', '') for t in transactions]
        
        # Calculate frequency
        if len(transactions) >= 2:
            dates = []
            for t in transactions:
                date_str = t.get('date') or t.get('timestamp')
                if date_str:
                    try:
                        dt = datetime.fromisoformat(date_str.replace('Z', '+00:00')) if isinstance(date_str, str) else date_str
                        dates.append(dt)
                    except:
                        pass
            
            if len(dates) >= 2:
                days = (max(dates) - min(dates)).days or 1
                frequency = len(transactions) / days
            else:
                frequency = 1.0
        else:
            frequency = 1.0
        
        self.user_profiles[user_id] = UserBehaviorProfile(
            user_id=user_id,
            average_transaction_amount=np.mean(amounts) if amounts else 0,
            max_transaction_amount=max(amounts) if amounts else 0,
            typical_transaction_hours=list(set(hours))[:10] if hours else list(range(9, 18)),
            typical_merchants=list(set(merchants))[:20],
            typical_locations=[],  # Would need location data
            transaction_frequency=frequency,
            last_updated=datetime.now(),
        )


# Create singleton instance
fraud_engine = FraudDetectionEngine()
