"""
Mock data for Analytics Service.
In production, this would be replaced with API calls to other services.
"""
import random
from datetime import datetime, timedelta
from typing import List, Dict, Any
import uuid


class MockTransactionData:
    """Mock transaction data generator."""
    
    def __init__(self):
        self.user_budgets: Dict[str, Dict[str, float]] = {}
        self._transactions_cache: Dict[str, List[Dict[str, Any]]] = {}
    
    def get_transactions(self, user_id: str, months: int = 6) -> List[Dict[str, Any]]:
        """Generate mock transactions for a user."""
        if user_id in self._transactions_cache:
            return self._transactions_cache[user_id]
        
        transactions = []
        base_date = datetime.now()
        
        # Transaction templates
        templates = [
            # Income
            {"type": "credit", "desc": "Salary Credit", "range": (4500, 6500), "freq": 1},
            
            # Regular expenses
            {"type": "debit", "desc": "Groceries - Tesco", "range": (80, 250), "freq": 8},
            {"type": "debit", "desc": "Groceries - Aeon", "range": (100, 300), "freq": 4},
            {"type": "debit", "desc": "Petrol - Shell", "range": (80, 150), "freq": 8},
            {"type": "debit", "desc": "Petrol - Petronas", "range": (70, 140), "freq": 6},
            {"type": "debit", "desc": "Restaurant - Nando's", "range": (40, 100), "freq": 4},
            {"type": "debit", "desc": "Restaurant - McDonald's", "range": (15, 45), "freq": 10},
            {"type": "debit", "desc": "Coffee - Starbucks", "range": (15, 35), "freq": 12},
            {"type": "debit", "desc": "Grab - Ride", "range": (8, 35), "freq": 15},
            {"type": "debit", "desc": "Online Shopping - Lazada", "range": (30, 200), "freq": 5},
            {"type": "debit", "desc": "Online Shopping - Shopee", "range": (20, 150), "freq": 8},
            
            # Bills
            {"type": "bill_payment", "desc": "TNB Bill Payment", "range": (120, 200), "freq": 1},
            {"type": "bill_payment", "desc": "Unifi Bill Payment", "range": (150, 180), "freq": 1},
            {"type": "bill_payment", "desc": "Air Selangor", "range": (30, 60), "freq": 1},
            {"type": "bill_payment", "desc": "Astro Bill", "range": (80, 120), "freq": 1},
            {"type": "bill_payment", "desc": "Maxis Mobile", "range": (80, 150), "freq": 1},
            
            # Entertainment
            {"type": "debit", "desc": "Netflix Subscription", "range": (45, 55), "freq": 1},
            {"type": "debit", "desc": "Spotify Premium", "range": (15, 20), "freq": 1},
            {"type": "debit", "desc": "Cinema - GSC", "range": (30, 60), "freq": 2},
            
            # Occasional
            {"type": "debit", "desc": "Medical - Guardian Pharmacy", "range": (20, 80), "freq": 2},
            {"type": "debit", "desc": "Clinic Visit", "range": (50, 150), "freq": 1},
            {"type": "transfer", "desc": "Transfer to Ahmad", "range": (50, 300), "freq": 3},
            {"type": "withdrawal", "desc": "ATM Withdrawal", "range": (100, 500), "freq": 4},
        ]
        
        # Generate transactions for past months
        for month in range(months):
            month_start = base_date - timedelta(days=30 * month)
            
            for template in templates:
                for _ in range(template["freq"]):
                    amount = round(random.uniform(*template["range"]), 2)
                    day_offset = random.randint(0, 29)
                    
                    transactions.append({
                        "transaction_id": f"TXN{uuid.uuid4().hex[:12].upper()}",
                        "account_id": "acc-001",
                        "type": template["type"],
                        "amount": amount,
                        "currency": "MYR",
                        "description": template["desc"],
                        "status": "completed",
                        "reference": f"REF{random.randint(100000, 999999)}",
                        "date": (month_start - timedelta(days=day_offset)).isoformat(),
                    })
        
        # Sort by date descending
        transactions.sort(key=lambda x: x["date"], reverse=True)
        self._transactions_cache[user_id] = transactions
        
        return transactions
    
    def get_user_budgets(self, user_id: str) -> Dict[str, float]:
        """Get user's monthly budgets."""
        if user_id in self.user_budgets:
            return self.user_budgets[user_id]
        
        # Default budgets
        return {
            "food_dining": 600.0,
            "groceries": 500.0,
            "transportation": 400.0,
            "utilities": 300.0,
            "entertainment": 200.0,
            "shopping": 300.0,
            "healthcare": 100.0,
            "bills": 500.0,
            "other": 200.0,
        }
    
    def set_user_budgets(self, user_id: str, budgets: Dict[str, float]):
        """Set user's monthly budgets."""
        self.user_budgets[user_id] = budgets
