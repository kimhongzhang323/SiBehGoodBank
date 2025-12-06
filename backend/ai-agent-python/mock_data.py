"""
Mock data service for the AI Agent.
Simulates bank accounts, transactions, and other banking data.
"""
import random
import string
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field
from enum import Enum
import uuid


class AccountType(str, Enum):
    SAVINGS = "savings"
    CURRENT = "current"
    FIXED_DEPOSIT = "fixed_deposit"


class TransactionType(str, Enum):
    CREDIT = "credit"
    DEBIT = "debit"
    TRANSFER = "transfer"
    BILL_PAYMENT = "bill_payment"
    WITHDRAWAL = "withdrawal"


class TransactionStatus(str, Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"


@dataclass
class Account:
    account_id: str
    account_number: str
    account_type: AccountType
    balance: float
    currency: str = "MYR"
    account_name: str = ""
    is_primary: bool = False
    created_at: datetime = field(default_factory=datetime.now)


@dataclass
class Transaction:
    transaction_id: str
    account_id: str
    type: TransactionType
    amount: float
    currency: str
    description: str
    status: TransactionStatus
    reference: str
    created_at: datetime
    recipient_name: Optional[str] = None
    recipient_account: Optional[str] = None
    recipient_bank: Optional[str] = None


@dataclass
class Contact:
    contact_id: str
    name: str
    account_number: str
    bank_name: str
    bank_code: str
    is_favorite: bool = False


@dataclass
class Bill:
    bill_id: str
    bill_type: str
    provider: str
    account_number: str
    amount: float
    due_date: datetime
    is_paid: bool = False


@dataclass
class User:
    user_id: str
    name: str
    email: str
    phone: str
    accounts: List[Account] = field(default_factory=list)
    contacts: List[Contact] = field(default_factory=list)
    pending_bills: List[Bill] = field(default_factory=list)


class MockDataService:
    """Service providing mock banking data for the AI agent."""
    
    # Malaysian Banks
    MALAYSIAN_BANKS = [
        {"code": "MBBEMYKL", "name": "Maybank"},
        {"code": "CIBBMYKL", "name": "CIMB Bank"},
        {"code": "PABORLMY", "name": "Public Bank"},
        {"code": "RHBBMYKL", "name": "RHB Bank"},
        {"code": "HLBBMYKL", "name": "Hong Leong Bank"},
        {"code": "AMBBMYKL", "name": "AmBank"},
        {"code": "BIMBMYKL", "name": "Bank Islam"},
        {"code": "BSNAMYK1", "name": "BSN"},
        {"code": "AIBBMYKL", "name": "Affin Bank"},
        {"code": "AABORLMY", "name": "Alliance Bank"},
        {"code": "OCBCMYKL", "name": "OCBC Bank"},
        {"code": "ULOYMYK1", "name": "UOB Bank"},
        {"code": "SCBLMYKX", "name": "Standard Chartered"},
        {"code": "HABORLMY", "name": "HSBC Bank"},
        {"code": "TABORLMY", "name": "Touch 'n Go eWallet"},
        {"code": "GRABMYKL", "name": "GrabPay"},
        {"code": "BOOSTMYK", "name": "Boost"},
    ]
    
    # Bill Categories and Providers
    BILL_PROVIDERS = {
        "Utilities": [
            {"name": "TNB (Tenaga Nasional)", "type": "electricity"},
            {"name": "Air Selangor", "type": "water"},
            {"name": "SYABAS", "type": "water"},
            {"name": "SAJ (Johor)", "type": "water"},
            {"name": "IWK", "type": "sewerage"},
            {"name": "Indah Water", "type": "sewerage"},
        ],
        "Telecommunications": [
            {"name": "TM (Unifi)", "type": "internet"},
            {"name": "Maxis", "type": "mobile"},
            {"name": "Celcom", "type": "mobile"},
            {"name": "Digi", "type": "mobile"},
            {"name": "U Mobile", "type": "mobile"},
            {"name": "Yes 4G", "type": "mobile"},
            {"name": "Time Internet", "type": "internet"},
        ],
        "Entertainment": [
            {"name": "Astro", "type": "tv"},
            {"name": "Netflix", "type": "streaming"},
            {"name": "Disney+ Hotstar", "type": "streaming"},
            {"name": "Spotify", "type": "music"},
            {"name": "YouTube Premium", "type": "streaming"},
        ],
        "Insurance": [
            {"name": "Prudential", "type": "life"},
            {"name": "AIA", "type": "life"},
            {"name": "Great Eastern", "type": "life"},
            {"name": "Allianz", "type": "general"},
            {"name": "Zurich", "type": "general"},
        ],
        "Credit Card": [
            {"name": "Maybank Credit Card", "type": "card"},
            {"name": "CIMB Credit Card", "type": "card"},
            {"name": "Public Bank Credit Card", "type": "card"},
            {"name": "RHB Credit Card", "type": "card"},
            {"name": "Hong Leong Credit Card", "type": "card"},
        ],
        "Government": [
            {"name": "PTPTN", "type": "education_loan"},
            {"name": "LHDN (Income Tax)", "type": "tax"},
            {"name": "JPJ (Road Tax)", "type": "road_tax"},
            {"name": "Zakat", "type": "religious"},
        ],
    }
    
    # Exchange Rates (against MYR)
    EXCHANGE_RATES = {
        "USD": {"buy": 4.45, "sell": 4.48, "name": "US Dollar"},
        "EUR": {"buy": 4.85, "sell": 4.89, "name": "Euro"},
        "GBP": {"buy": 5.65, "sell": 5.70, "name": "British Pound"},
        "SGD": {"buy": 3.32, "sell": 3.35, "name": "Singapore Dollar"},
        "AUD": {"buy": 2.92, "sell": 2.95, "name": "Australian Dollar"},
        "JPY": {"buy": 0.030, "sell": 0.031, "name": "Japanese Yen"},
        "CNY": {"buy": 0.62, "sell": 0.63, "name": "Chinese Yuan"},
        "THB": {"buy": 0.13, "sell": 0.132, "name": "Thai Baht"},
        "IDR": {"buy": 0.00028, "sell": 0.00029, "name": "Indonesian Rupiah"},
        "INR": {"buy": 0.053, "sell": 0.054, "name": "Indian Rupee"},
    }
    
    def __init__(self):
        self.users: Dict[str, User] = {}
        self.transactions: Dict[str, List[Transaction]] = {}
        self._initialize_mock_data()
    
    def _generate_account_number(self) -> str:
        """Generate a realistic Malaysian bank account number."""
        return ''.join(random.choices(string.digits, k=12))
    
    def _generate_transaction_id(self) -> str:
        """Generate a transaction ID."""
        return f"TXN{datetime.now().strftime('%Y%m%d')}{uuid.uuid4().hex[:8].upper()}"
    
    def _initialize_mock_data(self):
        """Initialize mock user data."""
        # Create default user
        default_user_id = "user-001"
        
        accounts = [
            Account(
                account_id="acc-001",
                account_number="1234567890",
                account_type=AccountType.SAVINGS,
                balance=15680.50,
                account_name="Everyday Savings",
                is_primary=True,
            ),
            Account(
                account_id="acc-002",
                account_number="1234567891",
                account_type=AccountType.CURRENT,
                balance=8420.75,
                account_name="Current Account",
            ),
            Account(
                account_id="acc-003",
                account_number="1234567892",
                account_type=AccountType.FIXED_DEPOSIT,
                balance=50000.00,
                account_name="12-Month FD",
            ),
        ]
        
        contacts = [
            Contact("c1", "Ahmad bin Abdullah", "9876543210", "Maybank", "MBBEMYKL", True),
            Contact("c2", "Siti Nurhaliza", "8765432109", "CIMB Bank", "CIBBMYKL", True),
            Contact("c3", "Lee Wei Ming", "7654321098", "Public Bank", "PABORLMY"),
            Contact("c4", "Raj Kumar", "6543210987", "RHB Bank", "RHBBMYKL"),
            Contact("c5", "Fatimah binti Hassan", "5432109876", "Hong Leong Bank", "HLBBMYKL"),
            Contact("c6", "Tan Ah Kow", "4321098765", "Touch 'n Go", "TABORLMY", True),
        ]
        
        # Generate pending bills
        pending_bills = [
            Bill(
                bill_id="bill-001",
                bill_type="Utilities",
                provider="TNB (Tenaga Nasional)",
                account_number="220012345678",
                amount=156.80,
                due_date=datetime.now() + timedelta(days=12),
            ),
            Bill(
                bill_id="bill-002",
                bill_type="Telecommunications",
                provider="TM (Unifi)",
                account_number="UN123456789",
                amount=189.00,
                due_date=datetime.now() + timedelta(days=8),
            ),
            Bill(
                bill_id="bill-003",
                bill_type="Entertainment",
                provider="Astro",
                account_number="AS987654321",
                amount=99.90,
                due_date=datetime.now() + timedelta(days=15),
            ),
        ]
        
        user = User(
            user_id=default_user_id,
            name="John Doe",
            email="john.doe@email.com",
            phone="+60123456789",
            accounts=accounts,
            contacts=contacts,
            pending_bills=pending_bills,
        )
        
        self.users[default_user_id] = user
        
        # Generate transaction history
        self._generate_transaction_history(default_user_id, accounts[0].account_id)
    
    def _generate_transaction_history(self, user_id: str, account_id: str):
        """Generate mock transaction history."""
        transactions = []
        base_date = datetime.now()
        
        transaction_templates = [
            {"type": TransactionType.CREDIT, "desc": "Salary Credit", "range": (3000, 8000)},
            {"type": TransactionType.DEBIT, "desc": "Groceries - Tesco", "range": (50, 300)},
            {"type": TransactionType.TRANSFER, "desc": "Transfer to Ahmad", "range": (100, 1000)},
            {"type": TransactionType.BILL_PAYMENT, "desc": "TNB Bill Payment", "range": (100, 300)},
            {"type": TransactionType.DEBIT, "desc": "Petrol - Shell", "range": (50, 200)},
            {"type": TransactionType.DEBIT, "desc": "Restaurant - Nando's", "range": (30, 150)},
            {"type": TransactionType.TRANSFER, "desc": "Transfer from Siti", "range": (50, 500)},
            {"type": TransactionType.WITHDRAWAL, "desc": "ATM Withdrawal", "range": (100, 500)},
            {"type": TransactionType.DEBIT, "desc": "Online Shopping - Lazada", "range": (50, 500)},
            {"type": TransactionType.BILL_PAYMENT, "desc": "Unifi Bill Payment", "range": (150, 200)},
        ]
        
        for i in range(30):
            template = random.choice(transaction_templates)
            amount = round(random.uniform(*template["range"]), 2)
            
            transaction = Transaction(
                transaction_id=self._generate_transaction_id(),
                account_id=account_id,
                type=template["type"],
                amount=amount,
                currency="MYR",
                description=template["desc"],
                status=TransactionStatus.COMPLETED,
                reference=f"REF{random.randint(100000, 999999)}",
                created_at=base_date - timedelta(days=i, hours=random.randint(0, 23)),
            )
            transactions.append(transaction)
        
        # Sort by date descending
        transactions.sort(key=lambda x: x.created_at, reverse=True)
        self.transactions[account_id] = transactions
    
    # Public API Methods
    
    def get_user(self, user_id: str) -> Optional[User]:
        """Get user by ID."""
        return self.users.get(user_id)
    
    def get_accounts(self, user_id: str) -> List[Account]:
        """Get all accounts for a user."""
        user = self.get_user(user_id)
        return user.accounts if user else []
    
    def get_account(self, user_id: str, account_id: str) -> Optional[Account]:
        """Get specific account."""
        accounts = self.get_accounts(user_id)
        return next((a for a in accounts if a.account_id == account_id), None)
    
    def get_primary_account(self, user_id: str) -> Optional[Account]:
        """Get primary account for user."""
        accounts = self.get_accounts(user_id)
        return next((a for a in accounts if a.is_primary), accounts[0] if accounts else None)
    
    def get_balance(self, user_id: str, account_id: Optional[str] = None) -> Dict[str, Any]:
        """Get account balance."""
        if account_id:
            account = self.get_account(user_id, account_id)
        else:
            account = self.get_primary_account(user_id)
        
        if not account:
            return {"error": "Account not found"}
        
        return {
            "account_id": account.account_id,
            "account_number": account.account_number,
            "account_name": account.account_name,
            "account_type": account.account_type.value,
            "balance": account.balance,
            "currency": account.currency,
            "available_balance": account.balance,  # Simplified
        }
    
    def get_all_balances(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all account balances."""
        accounts = self.get_accounts(user_id)
        return [
            {
                "account_id": acc.account_id,
                "account_number": acc.account_number,
                "account_name": acc.account_name,
                "account_type": acc.account_type.value,
                "balance": acc.balance,
                "currency": acc.currency,
            }
            for acc in accounts
        ]
    
    def get_transactions(
        self, 
        user_id: str, 
        account_id: Optional[str] = None,
        limit: int = 10,
        transaction_type: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Get transaction history."""
        if not account_id:
            account = self.get_primary_account(user_id)
            account_id = account.account_id if account else None
        
        if not account_id or account_id not in self.transactions:
            return []
        
        transactions = self.transactions[account_id]
        
        if transaction_type:
            transactions = [t for t in transactions if t.type.value == transaction_type]
        
        return [
            {
                "transaction_id": t.transaction_id,
                "type": t.type.value,
                "amount": t.amount,
                "currency": t.currency,
                "description": t.description,
                "status": t.status.value,
                "reference": t.reference,
                "date": t.created_at.isoformat(),
                "recipient_name": t.recipient_name,
                "recipient_account": t.recipient_account,
                "recipient_bank": t.recipient_bank,
            }
            for t in transactions[:limit]
        ]
    
    def transfer_funds(
        self,
        user_id: str,
        from_account_id: str,
        to_account_number: str,
        to_bank_code: str,
        amount: float,
        description: str = "",
        recipient_name: str = "",
    ) -> Dict[str, Any]:
        """Execute a fund transfer."""
        account = self.get_account(user_id, from_account_id)
        
        if not account:
            return {"success": False, "error": "Source account not found"}
        
        if account.balance < amount:
            return {"success": False, "error": "Insufficient balance"}
        
        # Deduct balance
        account.balance -= amount
        
        # Create transaction record
        transaction = Transaction(
            transaction_id=self._generate_transaction_id(),
            account_id=from_account_id,
            type=TransactionType.TRANSFER,
            amount=amount,
            currency="MYR",
            description=description or f"Transfer to {recipient_name}",
            status=TransactionStatus.COMPLETED,
            reference=f"FT{datetime.now().strftime('%Y%m%d%H%M%S')}",
            created_at=datetime.now(),
            recipient_name=recipient_name,
            recipient_account=to_account_number,
            recipient_bank=self._get_bank_name(to_bank_code),
        )
        
        if from_account_id not in self.transactions:
            self.transactions[from_account_id] = []
        self.transactions[from_account_id].insert(0, transaction)
        
        return {
            "success": True,
            "transaction_id": transaction.transaction_id,
            "reference": transaction.reference,
            "amount": amount,
            "currency": "MYR",
            "recipient_name": recipient_name,
            "recipient_account": to_account_number,
            "recipient_bank": transaction.recipient_bank,
            "status": "completed",
            "timestamp": transaction.created_at.isoformat(),
            "new_balance": account.balance,
        }
    
    def pay_bill(
        self,
        user_id: str,
        from_account_id: str,
        bill_provider: str,
        bill_account_number: str,
        amount: float,
    ) -> Dict[str, Any]:
        """Pay a bill."""
        account = self.get_account(user_id, from_account_id)
        
        if not account:
            return {"success": False, "error": "Source account not found"}
        
        if account.balance < amount:
            return {"success": False, "error": "Insufficient balance"}
        
        # Deduct balance
        account.balance -= amount
        
        # Create transaction record
        transaction = Transaction(
            transaction_id=self._generate_transaction_id(),
            account_id=from_account_id,
            type=TransactionType.BILL_PAYMENT,
            amount=amount,
            currency="MYR",
            description=f"Bill Payment - {bill_provider}",
            status=TransactionStatus.COMPLETED,
            reference=f"BP{datetime.now().strftime('%Y%m%d%H%M%S')}",
            created_at=datetime.now(),
        )
        
        if from_account_id not in self.transactions:
            self.transactions[from_account_id] = []
        self.transactions[from_account_id].insert(0, transaction)
        
        return {
            "success": True,
            "transaction_id": transaction.transaction_id,
            "reference": transaction.reference,
            "amount": amount,
            "currency": "MYR",
            "provider": bill_provider,
            "bill_account": bill_account_number,
            "status": "completed",
            "timestamp": transaction.created_at.isoformat(),
            "new_balance": account.balance,
        }
    
    def get_contacts(self, user_id: str) -> List[Dict[str, Any]]:
        """Get user's saved contacts."""
        user = self.get_user(user_id)
        if not user:
            return []
        
        return [
            {
                "contact_id": c.contact_id,
                "name": c.name,
                "account_number": c.account_number,
                "bank_name": c.bank_name,
                "bank_code": c.bank_code,
                "is_favorite": c.is_favorite,
            }
            for c in user.contacts
        ]
    
    def get_pending_bills(self, user_id: str) -> List[Dict[str, Any]]:
        """Get user's pending bills."""
        user = self.get_user(user_id)
        if not user:
            return []
        
        return [
            {
                "bill_id": b.bill_id,
                "bill_type": b.bill_type,
                "provider": b.provider,
                "account_number": b.account_number,
                "amount": b.amount,
                "due_date": b.due_date.isoformat(),
                "days_until_due": (b.due_date - datetime.now()).days,
                "is_paid": b.is_paid,
            }
            for b in user.pending_bills
            if not b.is_paid
        ]
    
    def get_exchange_rate(self, from_currency: str, to_currency: str = "MYR") -> Dict[str, Any]:
        """Get exchange rate."""
        from_currency = from_currency.upper()
        to_currency = to_currency.upper()
        
        if to_currency == "MYR":
            if from_currency == "MYR":
                return {"from": "MYR", "to": "MYR", "rate": 1.0, "inverse": 1.0}
            
            rate_info = self.EXCHANGE_RATES.get(from_currency)
            if rate_info:
                return {
                    "from": from_currency,
                    "to": "MYR",
                    "currency_name": rate_info["name"],
                    "buy_rate": rate_info["buy"],
                    "sell_rate": rate_info["sell"],
                    "mid_rate": (rate_info["buy"] + rate_info["sell"]) / 2,
                    "last_updated": datetime.now().isoformat(),
                }
        
        return {"error": f"Exchange rate for {from_currency}/{to_currency} not available"}
    
    def get_all_exchange_rates(self) -> List[Dict[str, Any]]:
        """Get all available exchange rates."""
        return [
            {
                "currency_code": code,
                "currency_name": info["name"],
                "buy_rate": info["buy"],
                "sell_rate": info["sell"],
                "mid_rate": (info["buy"] + info["sell"]) / 2,
            }
            for code, info in self.EXCHANGE_RATES.items()
        ]
    
    def calculate_loan(
        self,
        principal: float,
        annual_rate: float,
        tenure_months: int,
    ) -> Dict[str, Any]:
        """Calculate loan repayment details."""
        monthly_rate = annual_rate / 100 / 12
        
        if monthly_rate > 0:
            monthly_payment = principal * (monthly_rate * (1 + monthly_rate) ** tenure_months) / ((1 + monthly_rate) ** tenure_months - 1)
        else:
            monthly_payment = principal / tenure_months
        
        total_payment = monthly_payment * tenure_months
        total_interest = total_payment - principal
        
        return {
            "principal": principal,
            "annual_rate": annual_rate,
            "tenure_months": tenure_months,
            "tenure_years": tenure_months / 12,
            "monthly_payment": round(monthly_payment, 2),
            "total_payment": round(total_payment, 2),
            "total_interest": round(total_interest, 2),
            "currency": "MYR",
        }
    
    def get_bill_categories(self) -> Dict[str, List[Dict[str, str]]]:
        """Get all bill payment categories and providers."""
        return self.BILL_PROVIDERS
    
    def get_banks(self) -> List[Dict[str, str]]:
        """Get list of supported banks."""
        return self.MALAYSIAN_BANKS
    
    def _get_bank_name(self, bank_code: str) -> str:
        """Get bank name from code."""
        bank = next((b for b in self.MALAYSIAN_BANKS if b["code"] == bank_code), None)
        return bank["name"] if bank else bank_code


# Global instance
mock_data_service = MockDataService()
