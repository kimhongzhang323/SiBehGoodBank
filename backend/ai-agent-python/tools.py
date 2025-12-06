"""
Banking Tools for the AI Agent.
Defines all available tools that Claude can use to interact with banking services.
"""
from typing import Any, Dict, List, Optional
from datetime import datetime
from mock_data import mock_data_service


# Tool Definitions for Anthropic Claude
BANKING_TOOLS = [
    {
        "name": "check_balance",
        "description": "Check the balance of a user's bank account. Can check a specific account or all accounts. Use this when the user asks about their balance, how much money they have, or account details.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Optional specific account ID. If not provided, returns primary account balance."
                },
                "show_all": {
                    "type": "boolean",
                    "description": "If true, returns balances for all accounts."
                }
            },
            "required": []
        }
    },
    {
        "name": "get_transactions",
        "description": "Retrieve transaction history for a user's account. Use this when the user asks about recent transactions, spending history, payment history, or wants to see their statement.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Optional account ID. If not provided, uses primary account."
                },
                "limit": {
                    "type": "integer",
                    "description": "Number of transactions to retrieve. Default is 10, maximum is 50."
                },
                "transaction_type": {
                    "type": "string",
                    "enum": ["credit", "debit", "transfer", "bill_payment", "withdrawal"],
                    "description": "Filter by transaction type."
                }
            },
            "required": []
        }
    },
    {
        "name": "transfer_funds",
        "description": "Transfer money from the user's account to another account. Use this when the user wants to send money, make a transfer, or pay someone. ALWAYS confirm the details with the user before executing.",
        "input_schema": {
            "type": "object",
            "properties": {
                "from_account_id": {
                    "type": "string",
                    "description": "Source account ID. If not provided, uses primary account."
                },
                "to_account_number": {
                    "type": "string",
                    "description": "Recipient's bank account number."
                },
                "to_bank_code": {
                    "type": "string",
                    "description": "Recipient's bank SWIFT/BIC code (e.g., MBBEMYKL for Maybank)."
                },
                "amount": {
                    "type": "number",
                    "description": "Amount to transfer in MYR."
                },
                "recipient_name": {
                    "type": "string",
                    "description": "Name of the recipient."
                },
                "description": {
                    "type": "string",
                    "description": "Transfer description or reference."
                }
            },
            "required": ["to_account_number", "to_bank_code", "amount", "recipient_name"]
        }
    },
    {
        "name": "pay_bill",
        "description": "Pay a bill such as utilities, telecommunications, or other services. Use this when the user wants to pay bills like electricity (TNB), water, internet (Unifi), Astro, etc.",
        "input_schema": {
            "type": "object",
            "properties": {
                "from_account_id": {
                    "type": "string",
                    "description": "Source account ID. If not provided, uses primary account."
                },
                "bill_provider": {
                    "type": "string",
                    "description": "Name of the bill provider (e.g., 'TNB (Tenaga Nasional)', 'TM (Unifi)', 'Astro')."
                },
                "bill_account_number": {
                    "type": "string",
                    "description": "The bill account number or reference."
                },
                "amount": {
                    "type": "number",
                    "description": "Amount to pay in MYR."
                }
            },
            "required": ["bill_provider", "bill_account_number", "amount"]
        }
    },
    {
        "name": "get_contacts",
        "description": "Get the user's saved transfer recipients/contacts. Use this when the user wants to transfer to a saved contact, or asks who they can transfer to.",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_pending_bills",
        "description": "Get the user's pending bills that need to be paid. Use this when the user asks about their bills, upcoming payments, or due dates.",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_exchange_rate",
        "description": "Get currency exchange rates against Malaysian Ringgit (MYR). Use this when the user asks about forex rates, currency conversion, or exchange rates.",
        "input_schema": {
            "type": "object",
            "properties": {
                "currency": {
                    "type": "string",
                    "description": "Currency code (e.g., USD, EUR, SGD, GBP, JPY, CNY)."
                },
                "show_all": {
                    "type": "boolean",
                    "description": "If true, returns all available exchange rates."
                }
            },
            "required": []
        }
    },
    {
        "name": "calculate_loan",
        "description": "Calculate loan repayment details including monthly payment, total interest, and total repayment amount. Use this when the user asks about loan calculations, monthly payments, or financing.",
        "input_schema": {
            "type": "object",
            "properties": {
                "principal": {
                    "type": "number",
                    "description": "Loan amount in MYR."
                },
                "annual_rate": {
                    "type": "number",
                    "description": "Annual interest rate as a percentage (e.g., 5.5 for 5.5%)."
                },
                "tenure_months": {
                    "type": "integer",
                    "description": "Loan tenure in months."
                }
            },
            "required": ["principal", "annual_rate", "tenure_months"]
        }
    },
    {
        "name": "get_bill_categories",
        "description": "Get all available bill payment categories and providers. Use this when the user asks what bills they can pay, or needs help finding a bill provider.",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_banks",
        "description": "Get list of supported banks for transfers. Use this when the user needs to know which banks are available for transfers or asks about bank codes.",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_account_details",
        "description": "Get detailed information about a specific account including account number, type, and other details.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Account ID to get details for. If not provided, uses primary account."
                }
            },
            "required": []
        }
    },
    {
        "name": "initiate_withdrawal",
        "description": "Initiate a cardless ATM cash withdrawal. Generates a withdrawal code that can be used at ATMs. Use this when the user wants to withdraw cash without their card.",
        "input_schema": {
            "type": "object",
            "properties": {
                "from_account_id": {
                    "type": "string",
                    "description": "Source account ID. If not provided, uses primary account."
                },
                "amount": {
                    "type": "number",
                    "description": "Amount to withdraw in MYR. Must be in multiples of 10 or 50."
                }
            },
            "required": ["amount"]
        }
    },
    {
        "name": "get_nearby_atms",
        "description": "Find nearby ATM locations. Use this when the user asks where to withdraw money or find ATMs.",
        "input_schema": {
            "type": "object",
            "properties": {
                "latitude": {
                    "type": "number",
                    "description": "User's latitude coordinate."
                },
                "longitude": {
                    "type": "number",
                    "description": "User's longitude coordinate."
                },
                "limit": {
                    "type": "integer",
                    "description": "Number of ATMs to return. Default is 5."
                }
            },
            "required": []
        }
    },
]


class BankingToolExecutor:
    """Executes banking tools and returns results."""
    
    def __init__(self, user_id: str = "user-001"):
        self.user_id = user_id
        self.data_service = mock_data_service
    
    def execute_tool(self, tool_name: str, tool_input: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a tool and return the result."""
        tool_handlers = {
            "check_balance": self._check_balance,
            "get_transactions": self._get_transactions,
            "transfer_funds": self._transfer_funds,
            "pay_bill": self._pay_bill,
            "get_contacts": self._get_contacts,
            "get_pending_bills": self._get_pending_bills,
            "get_exchange_rate": self._get_exchange_rate,
            "calculate_loan": self._calculate_loan,
            "get_bill_categories": self._get_bill_categories,
            "get_banks": self._get_banks,
            "get_account_details": self._get_account_details,
            "initiate_withdrawal": self._initiate_withdrawal,
            "get_nearby_atms": self._get_nearby_atms,
        }
        
        handler = tool_handlers.get(tool_name)
        if not handler:
            return {"error": f"Unknown tool: {tool_name}"}
        
        try:
            return handler(tool_input)
        except Exception as e:
            return {"error": str(e)}
    
    def _check_balance(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle check_balance tool."""
        if params.get("show_all"):
            balances = self.data_service.get_all_balances(self.user_id)
            total = sum(b["balance"] for b in balances)
            return {
                "accounts": balances,
                "total_balance": total,
                "currency": "MYR"
            }
        
        account_id = params.get("account_id")
        return self.data_service.get_balance(self.user_id, account_id)
    
    def _get_transactions(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_transactions tool."""
        account_id = params.get("account_id")
        limit = min(params.get("limit", 10), 50)
        transaction_type = params.get("transaction_type")
        
        transactions = self.data_service.get_transactions(
            self.user_id, account_id, limit, transaction_type
        )
        
        return {
            "transactions": transactions,
            "count": len(transactions),
            "showing": f"Last {len(transactions)} transactions"
        }
    
    def _transfer_funds(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle transfer_funds tool."""
        from_account_id = params.get("from_account_id")
        if not from_account_id:
            primary = self.data_service.get_primary_account(self.user_id)
            from_account_id = primary.account_id if primary else None
        
        if not from_account_id:
            return {"error": "No account found"}
        
        return self.data_service.transfer_funds(
            user_id=self.user_id,
            from_account_id=from_account_id,
            to_account_number=params["to_account_number"],
            to_bank_code=params["to_bank_code"],
            amount=params["amount"],
            description=params.get("description", ""),
            recipient_name=params["recipient_name"],
        )
    
    def _pay_bill(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle pay_bill tool."""
        from_account_id = params.get("from_account_id")
        if not from_account_id:
            primary = self.data_service.get_primary_account(self.user_id)
            from_account_id = primary.account_id if primary else None
        
        if not from_account_id:
            return {"error": "No account found"}
        
        return self.data_service.pay_bill(
            user_id=self.user_id,
            from_account_id=from_account_id,
            bill_provider=params["bill_provider"],
            bill_account_number=params["bill_account_number"],
            amount=params["amount"],
        )
    
    def _get_contacts(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_contacts tool."""
        contacts = self.data_service.get_contacts(self.user_id)
        favorites = [c for c in contacts if c["is_favorite"]]
        
        return {
            "contacts": contacts,
            "favorites": favorites,
            "total": len(contacts)
        }
    
    def _get_pending_bills(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_pending_bills tool."""
        bills = self.data_service.get_pending_bills(self.user_id)
        total_due = sum(b["amount"] for b in bills)
        
        return {
            "bills": bills,
            "total_due": total_due,
            "currency": "MYR",
            "count": len(bills)
        }
    
    def _get_exchange_rate(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_exchange_rate tool."""
        if params.get("show_all"):
            rates = self.data_service.get_all_exchange_rates()
            return {
                "base_currency": "MYR",
                "rates": rates,
                "last_updated": datetime.now().isoformat()
            }
        
        currency = params.get("currency", "USD")
        return self.data_service.get_exchange_rate(currency)
    
    def _calculate_loan(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle calculate_loan tool."""
        return self.data_service.calculate_loan(
            principal=params["principal"],
            annual_rate=params["annual_rate"],
            tenure_months=params["tenure_months"],
        )
    
    def _get_bill_categories(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_bill_categories tool."""
        categories = self.data_service.get_bill_categories()
        return {
            "categories": list(categories.keys()),
            "providers": categories
        }
    
    def _get_banks(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_banks tool."""
        banks = self.data_service.get_banks()
        return {
            "banks": banks,
            "count": len(banks)
        }
    
    def _get_account_details(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_account_details tool."""
        account_id = params.get("account_id")
        if account_id:
            account = self.data_service.get_account(self.user_id, account_id)
        else:
            account = self.data_service.get_primary_account(self.user_id)
        
        if not account:
            return {"error": "Account not found"}
        
        return {
            "account_id": account.account_id,
            "account_number": account.account_number,
            "account_name": account.account_name,
            "account_type": account.account_type.value,
            "balance": account.balance,
            "currency": account.currency,
            "is_primary": account.is_primary,
            "created_at": account.created_at.isoformat(),
        }
    
    def _initiate_withdrawal(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle initiate_withdrawal tool."""
        from_account_id = params.get("from_account_id")
        if not from_account_id:
            primary = self.data_service.get_primary_account(self.user_id)
            from_account_id = primary.account_id if primary else None
        
        if not from_account_id:
            return {"error": "No account found"}
        
        account = self.data_service.get_account(self.user_id, from_account_id)
        amount = params["amount"]
        
        if amount % 10 != 0:
            return {"error": "Amount must be in multiples of RM10"}
        
        if amount > 1500:
            return {"error": "Maximum withdrawal is RM1,500 per transaction"}
        
        if account.balance < amount:
            return {"error": "Insufficient balance"}
        
        # Generate withdrawal code
        import random
        withdrawal_code = ''.join(random.choices('0123456789', k=6))
        
        return {
            "success": True,
            "withdrawal_code": withdrawal_code,
            "amount": amount,
            "currency": "MYR",
            "expires_at": (datetime.now().replace(minute=datetime.now().minute + 30)).isoformat(),
            "instructions": [
                "1. Go to any SiBeh Good Bank ATM",
                "2. Select 'Cardless Withdrawal'",
                "3. Enter the 6-digit code shown above",
                "4. Verify with your fingerprint or face",
                "5. Collect your cash"
            ],
            "note": "This code expires in 30 minutes"
        }
    
    def _get_nearby_atms(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle get_nearby_atms tool."""
        # Mock ATM locations in Kuala Lumpur
        atms = [
            {
                "id": "atm-001",
                "name": "SiBeh Good Bank ATM - KLCC",
                "address": "Suria KLCC, Level G, Kuala Lumpur",
                "distance": "0.5 km",
                "available": True,
                "services": ["withdrawal", "deposit", "transfer"]
            },
            {
                "id": "atm-002",
                "name": "SiBeh Good Bank ATM - Pavilion",
                "address": "Pavilion KL, Level 1, Bukit Bintang",
                "distance": "1.2 km",
                "available": True,
                "services": ["withdrawal", "deposit"]
            },
            {
                "id": "atm-003",
                "name": "SiBeh Good Bank ATM - Mid Valley",
                "address": "Mid Valley Megamall, Ground Floor",
                "distance": "3.5 km",
                "available": True,
                "services": ["withdrawal", "deposit", "transfer"]
            },
            {
                "id": "atm-004",
                "name": "SiBeh Good Bank ATM - Bangsar",
                "address": "Bangsar Village II, Level G",
                "distance": "4.2 km",
                "available": False,
                "services": ["withdrawal", "deposit"]
            },
            {
                "id": "atm-005",
                "name": "SiBeh Good Bank ATM - 1 Utama",
                "address": "1 Utama Shopping Centre, LG Floor",
                "distance": "12.8 km",
                "available": True,
                "services": ["withdrawal", "deposit", "transfer"]
            },
        ]
        
        limit = params.get("limit", 5)
        return {
            "atms": atms[:limit],
            "count": len(atms[:limit]),
            "note": "Distances are approximate from city center"
        }
