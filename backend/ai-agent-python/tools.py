"""
Banking Tools for the AI Agent.
Defines all available tools that Claude can use to interact with banking services.
"""
import io
import base64
from typing import Any, Dict, List, Optional
from datetime import datetime, timedelta
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
import numpy as np
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
    # Graph Generation Tools
    {
        "name": "generate_spending_chart",
        "description": "Generate a visual chart showing spending patterns by category over time. Use this when the user asks to see their spending analysis, spending breakdown, where their money goes, or wants to visualize their expenses.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Account ID to analyze. If not provided, uses primary account."
                },
                "days": {
                    "type": "integer",
                    "description": "Number of days to analyze. Default is 30."
                },
                "chart_type": {
                    "type": "string",
                    "enum": ["pie", "bar", "horizontal_bar"],
                    "description": "Type of chart to generate. Default is 'pie'."
                }
            },
            "required": []
        }
    },
    {
        "name": "generate_balance_trend_chart",
        "description": "Generate a line chart showing balance trends over time. Use this when the user asks about their balance history, balance trend, how their balance changed, or wants to see balance over time.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Account ID to analyze. If not provided, uses primary account."
                },
                "days": {
                    "type": "integer",
                    "description": "Number of days to show. Default is 30."
                }
            },
            "required": []
        }
    },
    {
        "name": "generate_income_expense_chart",
        "description": "Generate a chart comparing income vs expenses. Use this when the user asks about their income vs spending, cash flow, money in vs out, or financial summary.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Account ID to analyze. If not provided, uses primary account."
                },
                "days": {
                    "type": "integer",
                    "description": "Number of days to analyze. Default is 30."
                },
                "chart_type": {
                    "type": "string",
                    "enum": ["bar", "stacked", "comparison"],
                    "description": "Type of chart to generate. Default is 'bar'."
                }
            },
            "required": []
        }
    },
    {
        "name": "generate_transaction_timeline_chart",
        "description": "Generate a timeline chart showing transactions over time. Use this when the user wants to see their transaction patterns, daily spending, or activity timeline.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Account ID to analyze. If not provided, uses primary account."
                },
                "days": {
                    "type": "integer",
                    "description": "Number of days to show. Default is 14."
                }
            },
            "required": []
        }
    },
    {
        "name": "generate_monthly_summary_chart",
        "description": "Generate a comprehensive monthly financial summary chart. Use this when the user asks for a monthly report, financial overview, or summary of the month.",
        "input_schema": {
            "type": "object",
            "properties": {
                "account_id": {
                    "type": "string",
                    "description": "Account ID to analyze. If not provided, uses primary account."
                },
                "months": {
                    "type": "integer",
                    "description": "Number of months to show. Default is 6."
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
            # Graph generation tools
            "generate_spending_chart": self._generate_spending_chart,
            "generate_balance_trend_chart": self._generate_balance_trend_chart,
            "generate_income_expense_chart": self._generate_income_expense_chart,
            "generate_transaction_timeline_chart": self._generate_transaction_timeline_chart,
            "generate_monthly_summary_chart": self._generate_monthly_summary_chart,
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

    # Graph Generation Methods
    
    def _get_transactions_for_analysis(self, account_id: Optional[str], days: int) -> List[Dict[str, Any]]:
        """Helper method to get transactions for analysis."""
        if not account_id:
            primary = self.data_service.get_primary_account(self.user_id)
            account_id = primary.account_id if primary else None
        
        if not account_id:
            return []
        
        # Get more transactions for analysis
        transactions = self.data_service.get_transactions(
            self.user_id, account_id, limit=100
        )
        
        # Filter by days
        cutoff_date = datetime.now() - timedelta(days=days)
        filtered = []
        for t in transactions:
            t_date = datetime.fromisoformat(t["date"])
            if t_date >= cutoff_date:
                filtered.append(t)
        
        return filtered

    def _fig_to_base64(self, fig) -> str:
        """Convert matplotlib figure to base64 string."""
        buf = io.BytesIO()
        fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                   facecolor='white', edgecolor='none')
        buf.seek(0)
        img_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
        plt.close(fig)
        return img_base64

    def _categorize_transaction(self, description: str) -> str:
        """Categorize a transaction based on description."""
        desc_lower = description.lower()
        
        if any(word in desc_lower for word in ['salary', 'credit', 'transfer from']):
            return 'Income'
        elif any(word in desc_lower for word in ['groceries', 'tesco', 'aeon', 'giant', 'cold storage']):
            return 'Groceries'
        elif any(word in desc_lower for word in ['petrol', 'shell', 'petronas', 'caltex', 'bp']):
            return 'Transport'
        elif any(word in desc_lower for word in ['restaurant', 'nando', 'mcdonald', 'kfc', 'starbucks', 'food']):
            return 'Food & Dining'
        elif any(word in desc_lower for word in ['bill', 'tnb', 'unifi', 'astro', 'water', 'utility']):
            return 'Bills & Utilities'
        elif any(word in desc_lower for word in ['lazada', 'shopee', 'amazon', 'online', 'shopping']):
            return 'Shopping'
        elif any(word in desc_lower for word in ['transfer to', 'transfer']):
            return 'Transfers'
        elif any(word in desc_lower for word in ['atm', 'withdrawal', 'cash']):
            return 'Cash Withdrawal'
        else:
            return 'Other'

    def _generate_spending_chart(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate a spending breakdown chart."""
        account_id = params.get("account_id")
        days = params.get("days", 30)
        chart_type = params.get("chart_type", "pie")
        
        transactions = self._get_transactions_for_analysis(account_id, days)
        
        if not transactions:
            return {"error": "No transactions found for the specified period"}
        
        # Categorize spending (exclude income)
        spending_by_category = defaultdict(float)
        for t in transactions:
            if t["type"] in ["debit", "bill_payment", "withdrawal", "transfer"]:
                category = self._categorize_transaction(t["description"])
                if category != 'Income':
                    spending_by_category[category] += t["amount"]
        
        if not spending_by_category:
            return {"error": "No spending transactions found"}
        
        # Sort by amount
        sorted_categories = sorted(spending_by_category.items(), key=lambda x: x[1], reverse=True)
        categories = [c[0] for c in sorted_categories]
        amounts = [c[1] for c in sorted_categories]
        total_spending = sum(amounts)
        
        # Create chart
        sns.set_style("whitegrid")
        colors = sns.color_palette("husl", len(categories))
        
        fig, ax = plt.subplots(figsize=(10, 8))
        
        if chart_type == "pie":
            # Pie chart
            wedges, texts, autotexts = ax.pie(
                amounts, 
                labels=categories,
                colors=colors,
                autopct=lambda pct: f'RM {pct/100*total_spending:.0f}\n({pct:.1f}%)',
                startangle=90,
                explode=[0.02] * len(categories)
            )
            ax.set_title(f'Spending Breakdown - Last {days} Days', fontsize=14, fontweight='bold')
            
        elif chart_type == "bar":
            # Vertical bar chart
            bars = ax.bar(categories, amounts, color=colors, edgecolor='white', linewidth=1.5)
            ax.set_xlabel('Category', fontsize=12)
            ax.set_ylabel('Amount (RM)', fontsize=12)
            ax.set_title(f'Spending by Category - Last {days} Days', fontsize=14, fontweight='bold')
            plt.xticks(rotation=45, ha='right')
            
            # Add value labels on bars
            for bar, amount in zip(bars, amounts):
                ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + total_spending*0.01,
                       f'RM {amount:.0f}', ha='center', va='bottom', fontsize=9)
                
        else:  # horizontal_bar
            # Horizontal bar chart
            y_pos = np.arange(len(categories))
            bars = ax.barh(y_pos, amounts, color=colors, edgecolor='white', linewidth=1.5)
            ax.set_yticks(y_pos)
            ax.set_yticklabels(categories)
            ax.set_xlabel('Amount (RM)', fontsize=12)
            ax.set_title(f'Spending by Category - Last {days} Days', fontsize=14, fontweight='bold')
            
            # Add value labels
            for bar, amount in zip(bars, amounts):
                ax.text(bar.get_width() + total_spending*0.01, bar.get_y() + bar.get_height()/2,
                       f'RM {amount:.0f}', ha='left', va='center', fontsize=9)
        
        plt.tight_layout()
        
        # Convert to base64
        chart_base64 = self._fig_to_base64(fig)
        
        return {
            "success": True,
            "chart_type": "spending_breakdown",
            "chart_format": chart_type,
            "period_days": days,
            "total_spending": round(total_spending, 2),
            "currency": "MYR",
            "categories": [{"name": c, "amount": round(a, 2), "percentage": round(a/total_spending*100, 1)} 
                          for c, a in sorted_categories],
            "chart_image_base64": chart_base64,
            "message": f"Here's your spending breakdown for the last {days} days. Your total spending was RM {total_spending:,.2f}."
        }

    def _generate_balance_trend_chart(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate a balance trend line chart."""
        account_id = params.get("account_id")
        days = params.get("days", 30)
        
        transactions = self._get_transactions_for_analysis(account_id, days)
        
        if not account_id:
            primary = self.data_service.get_primary_account(self.user_id)
            account_id = primary.account_id if primary else None
        
        if not account_id:
            return {"error": "No account found"}
        
        account = self.data_service.get_account(self.user_id, account_id)
        current_balance = account.balance
        
        # Calculate historical balances
        dates = []
        balances = []
        
        # Work backwards from current balance
        running_balance = current_balance
        date_balance = defaultdict(float)
        
        for t in transactions:
            t_date = datetime.fromisoformat(t["date"]).date()
            if t["type"] == "credit":
                date_balance[t_date] -= t["amount"]  # Reverse the credit
            else:
                date_balance[t_date] += t["amount"]  # Reverse the debit
        
        # Generate date range
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days)
        
        current_date = end_date
        running_balance = current_balance
        
        while current_date >= start_date:
            dates.append(current_date)
            balances.append(running_balance)
            running_balance += date_balance.get(current_date, 0)
            current_date -= timedelta(days=1)
        
        # Reverse to chronological order
        dates = dates[::-1]
        balances = balances[::-1]
        
        # Create chart
        sns.set_style("whitegrid")
        fig, ax = plt.subplots(figsize=(12, 6))
        
        # Plot line with gradient fill
        ax.plot(dates, balances, color='#2E86AB', linewidth=2.5, marker='o', markersize=4)
        ax.fill_between(dates, balances, alpha=0.3, color='#2E86AB')
        
        # Formatting
        ax.set_xlabel('Date', fontsize=12)
        ax.set_ylabel('Balance (RM)', fontsize=12)
        ax.set_title(f'Account Balance Trend - Last {days} Days', fontsize=14, fontweight='bold')
        
        # Format x-axis dates
        ax.xaxis.set_major_formatter(mdates.DateFormatter('%d %b'))
        ax.xaxis.set_major_locator(mdates.DayLocator(interval=max(1, days//10)))
        plt.xticks(rotation=45, ha='right')
        
        # Format y-axis with RM
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'RM {x:,.0f}'))
        
        # Add min/max annotations
        min_bal = min(balances)
        max_bal = max(balances)
        min_idx = balances.index(min_bal)
        max_idx = balances.index(max_bal)
        
        ax.annotate(f'Min: RM {min_bal:,.2f}', xy=(dates[min_idx], min_bal),
                   xytext=(10, -20), textcoords='offset points',
                   fontsize=9, color='red',
                   arrowprops=dict(arrowstyle='->', color='red'))
        
        ax.annotate(f'Max: RM {max_bal:,.2f}', xy=(dates[max_idx], max_bal),
                   xytext=(10, 20), textcoords='offset points',
                   fontsize=9, color='green',
                   arrowprops=dict(arrowstyle='->', color='green'))
        
        plt.tight_layout()
        
        # Convert to base64
        chart_base64 = self._fig_to_base64(fig)
        
        return {
            "success": True,
            "chart_type": "balance_trend",
            "period_days": days,
            "current_balance": round(current_balance, 2),
            "min_balance": round(min_bal, 2),
            "max_balance": round(max_bal, 2),
            "average_balance": round(sum(balances)/len(balances), 2),
            "balance_change": round(balances[-1] - balances[0], 2),
            "currency": "MYR",
            "chart_image_base64": chart_base64,
            "message": f"Here's your balance trend for the last {days} days. Your balance changed by RM {balances[-1] - balances[0]:,.2f}."
        }

    def _generate_income_expense_chart(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate an income vs expenses comparison chart."""
        account_id = params.get("account_id")
        days = params.get("days", 30)
        chart_type = params.get("chart_type", "bar")
        
        transactions = self._get_transactions_for_analysis(account_id, days)
        
        if not transactions:
            return {"error": "No transactions found for the specified period"}
        
        # Calculate daily income and expenses
        daily_income = defaultdict(float)
        daily_expenses = defaultdict(float)
        
        for t in transactions:
            t_date = datetime.fromisoformat(t["date"]).date()
            if t["type"] == "credit":
                daily_income[t_date] += t["amount"]
            else:
                daily_expenses[t_date] += t["amount"]
        
        # Generate date range
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days)
        
        dates = []
        incomes = []
        expenses = []
        
        current_date = start_date
        while current_date <= end_date:
            dates.append(current_date)
            incomes.append(daily_income.get(current_date, 0))
            expenses.append(daily_expenses.get(current_date, 0))
            current_date += timedelta(days=1)
        
        total_income = sum(incomes)
        total_expenses = sum(expenses)
        net_flow = total_income - total_expenses
        
        # Create chart
        sns.set_style("whitegrid")
        
        if chart_type == "comparison":
            # Summary comparison chart
            fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
            
            # Pie chart for proportion
            sizes = [total_income, total_expenses]
            labels = ['Income', 'Expenses']
            colors_pie = ['#2ECC71', '#E74C3C']
            explode = (0.02, 0.02)
            
            ax1.pie(sizes, explode=explode, labels=labels, colors=colors_pie,
                   autopct=lambda pct: f'RM {pct/100*sum(sizes):,.0f}\n({pct:.1f}%)',
                   startangle=90)
            ax1.set_title('Income vs Expenses Distribution', fontsize=12, fontweight='bold')
            
            # Bar comparison
            categories = ['Total Income', 'Total Expenses', 'Net Cash Flow']
            values = [total_income, total_expenses, net_flow]
            colors_bar = ['#2ECC71', '#E74C3C', '#3498DB' if net_flow >= 0 else '#E67E22']
            
            bars = ax2.bar(categories, values, color=colors_bar, edgecolor='white', linewidth=2)
            ax2.axhline(y=0, color='gray', linestyle='--', linewidth=1)
            ax2.set_ylabel('Amount (RM)', fontsize=12)
            ax2.set_title(f'Financial Summary - Last {days} Days', fontsize=12, fontweight='bold')
            
            for bar, val in zip(bars, values):
                ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + (max(values)*0.02),
                        f'RM {val:,.0f}', ha='center', va='bottom', fontsize=10, fontweight='bold')
            
        elif chart_type == "stacked":
            # Stacked area chart
            fig, ax = plt.subplots(figsize=(12, 6))
            
            ax.fill_between(dates, incomes, alpha=0.7, color='#2ECC71', label='Income')
            ax.fill_between(dates, [-e for e in expenses], alpha=0.7, color='#E74C3C', label='Expenses')
            ax.axhline(y=0, color='gray', linestyle='-', linewidth=1)
            
            ax.set_xlabel('Date', fontsize=12)
            ax.set_ylabel('Amount (RM)', fontsize=12)
            ax.set_title(f'Daily Income vs Expenses - Last {days} Days', fontsize=14, fontweight='bold')
            ax.legend(loc='upper right')
            
            ax.xaxis.set_major_formatter(mdates.DateFormatter('%d %b'))
            plt.xticks(rotation=45, ha='right')
            
        else:  # bar
            # Grouped bar chart
            fig, ax = plt.subplots(figsize=(14, 6))
            
            x = np.arange(len(dates))
            width = 0.35
            
            # Only show every nth bar if too many dates
            step = max(1, len(dates) // 15)
            x_display = x[::step]
            dates_display = [dates[i] for i in range(0, len(dates), step)]
            incomes_display = [incomes[i] for i in range(0, len(incomes), step)]
            expenses_display = [expenses[i] for i in range(0, len(expenses), step)]
            
            bars1 = ax.bar(np.arange(len(x_display)) - width/2, incomes_display, width, 
                          label='Income', color='#2ECC71', edgecolor='white')
            bars2 = ax.bar(np.arange(len(x_display)) + width/2, expenses_display, width, 
                          label='Expenses', color='#E74C3C', edgecolor='white')
            
            ax.set_xlabel('Date', fontsize=12)
            ax.set_ylabel('Amount (RM)', fontsize=12)
            ax.set_title(f'Daily Income vs Expenses - Last {days} Days', fontsize=14, fontweight='bold')
            ax.set_xticks(np.arange(len(x_display)))
            ax.set_xticklabels([d.strftime('%d %b') for d in dates_display], rotation=45, ha='right')
            ax.legend()
        
        plt.tight_layout()
        
        # Convert to base64
        chart_base64 = self._fig_to_base64(fig)
        
        return {
            "success": True,
            "chart_type": "income_expense",
            "chart_format": chart_type,
            "period_days": days,
            "total_income": round(total_income, 2),
            "total_expenses": round(total_expenses, 2),
            "net_cash_flow": round(net_flow, 2),
            "savings_rate": round((net_flow / total_income * 100) if total_income > 0 else 0, 1),
            "currency": "MYR",
            "chart_image_base64": chart_base64,
            "message": f"Here's your income vs expenses for the last {days} days. You {'saved' if net_flow >= 0 else 'spent'} RM {abs(net_flow):,.2f} {'more than you earned' if net_flow < 0 else 'net'}."
        }

    def _generate_transaction_timeline_chart(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate a transaction timeline chart."""
        account_id = params.get("account_id")
        days = params.get("days", 14)
        
        transactions = self._get_transactions_for_analysis(account_id, days)
        
        if not transactions:
            return {"error": "No transactions found for the specified period"}
        
        # Group transactions by date
        daily_transactions = defaultdict(list)
        for t in transactions:
            t_date = datetime.fromisoformat(t["date"]).date()
            daily_transactions[t_date].append(t)
        
        # Create chart
        sns.set_style("whitegrid")
        fig, ax = plt.subplots(figsize=(14, 8))
        
        # Generate date range
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days)
        
        y_position = 0
        colors = {'credit': '#2ECC71', 'debit': '#E74C3C', 'transfer': '#3498DB', 
                 'bill_payment': '#9B59B6', 'withdrawal': '#E67E22'}
        
        date_positions = {}
        current_date = start_date
        while current_date <= end_date:
            date_positions[current_date] = y_position
            y_position += 1
            current_date += timedelta(days=1)
        
        # Plot transactions
        for date, txns in daily_transactions.items():
            if date in date_positions:
                y = date_positions[date]
                x_offset = 0
                for txn in txns:
                    color = colors.get(txn["type"], '#95A5A6')
                    size = min(500, max(100, txn["amount"] / 10))
                    
                    ax.scatter(x_offset, y, s=size, c=color, alpha=0.7, edgecolors='white', linewidths=1)
                    
                    # Add amount label for larger transactions
                    if txn["amount"] > 100:
                        ax.annotate(f'RM{txn["amount"]:.0f}', (x_offset, y), 
                                   xytext=(5, 5), textcoords='offset points',
                                   fontsize=7, alpha=0.8)
                    x_offset += 1
        
        # Format axes
        ax.set_yticks(list(date_positions.values()))
        ax.set_yticklabels([d.strftime('%a, %d %b') for d in date_positions.keys()])
        ax.set_xlabel('Transaction Number', fontsize=12)
        ax.set_title(f'Transaction Timeline - Last {days} Days', fontsize=14, fontweight='bold')
        
        # Add legend
        legend_elements = [plt.scatter([], [], c=c, s=100, label=t.replace('_', ' ').title()) 
                         for t, c in colors.items()]
        ax.legend(handles=legend_elements, loc='upper right', title='Transaction Type')
        
        ax.set_xlim(-1, max(len(txns) for txns in daily_transactions.values()) + 1 if daily_transactions else 5)
        
        plt.tight_layout()
        
        # Convert to base64
        chart_base64 = self._fig_to_base64(fig)
        
        # Calculate stats
        total_txns = len(transactions)
        avg_per_day = total_txns / days if days > 0 else 0
        
        return {
            "success": True,
            "chart_type": "transaction_timeline",
            "period_days": days,
            "total_transactions": total_txns,
            "average_per_day": round(avg_per_day, 1),
            "busiest_day": max(daily_transactions.items(), key=lambda x: len(x[1]))[0].strftime('%A, %d %b') if daily_transactions else None,
            "chart_image_base64": chart_base64,
            "message": f"Here's your transaction timeline for the last {days} days. You made {total_txns} transactions, averaging {avg_per_day:.1f} per day."
        }

    def _generate_monthly_summary_chart(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate a comprehensive monthly financial summary chart."""
        account_id = params.get("account_id")
        months = params.get("months", 6)
        
        # Get extended transactions (up to 6 months)
        transactions = self._get_transactions_for_analysis(account_id, months * 31)
        
        if not transactions:
            return {"error": "No transactions found"}
        
        # Group by month
        monthly_data = defaultdict(lambda: {"income": 0, "expenses": 0, "transactions": 0})
        
        for t in transactions:
            t_date = datetime.fromisoformat(t["date"])
            month_key = t_date.strftime('%Y-%m')
            
            monthly_data[month_key]["transactions"] += 1
            if t["type"] == "credit":
                monthly_data[month_key]["income"] += t["amount"]
            else:
                monthly_data[month_key]["expenses"] += t["amount"]
        
        # Sort months
        sorted_months = sorted(monthly_data.keys())[-months:]
        
        months_labels = [datetime.strptime(m, '%Y-%m').strftime('%b %Y') for m in sorted_months]
        incomes = [monthly_data[m]["income"] for m in sorted_months]
        expenses = [monthly_data[m]["expenses"] for m in sorted_months]
        net_flows = [monthly_data[m]["income"] - monthly_data[m]["expenses"] for m in sorted_months]
        
        # Create comprehensive chart
        sns.set_style("whitegrid")
        fig = plt.figure(figsize=(16, 10))
        
        # Create grid layout
        gs = fig.add_gridspec(2, 2, hspace=0.3, wspace=0.3)
        
        # Chart 1: Monthly Income vs Expenses (Bar)
        ax1 = fig.add_subplot(gs[0, 0])
        x = np.arange(len(months_labels))
        width = 0.35
        
        bars1 = ax1.bar(x - width/2, incomes, width, label='Income', color='#2ECC71')
        bars2 = ax1.bar(x + width/2, expenses, width, label='Expenses', color='#E74C3C')
        
        ax1.set_xlabel('Month')
        ax1.set_ylabel('Amount (RM)')
        ax1.set_title('Monthly Income vs Expenses', fontweight='bold')
        ax1.set_xticks(x)
        ax1.set_xticklabels(months_labels, rotation=45, ha='right')
        ax1.legend()
        
        # Chart 2: Net Cash Flow Trend (Line)
        ax2 = fig.add_subplot(gs[0, 1])
        colors_line = ['#2ECC71' if nf >= 0 else '#E74C3C' for nf in net_flows]
        ax2.bar(months_labels, net_flows, color=colors_line, edgecolor='white', linewidth=2)
        ax2.axhline(y=0, color='gray', linestyle='--', linewidth=1)
        ax2.set_xlabel('Month')
        ax2.set_ylabel('Net Cash Flow (RM)')
        ax2.set_title('Monthly Net Cash Flow', fontweight='bold')
        plt.setp(ax2.xaxis.get_majorticklabels(), rotation=45, ha='right')
        
        # Chart 3: Cumulative Savings
        ax3 = fig.add_subplot(gs[1, 0])
        cumulative = np.cumsum(net_flows)
        ax3.fill_between(months_labels, cumulative, alpha=0.3, color='#3498DB')
        ax3.plot(months_labels, cumulative, marker='o', color='#3498DB', linewidth=2)
        ax3.set_xlabel('Month')
        ax3.set_ylabel('Cumulative Savings (RM)')
        ax3.set_title('Cumulative Savings Trend', fontweight='bold')
        plt.setp(ax3.xaxis.get_majorticklabels(), rotation=45, ha='right')
        ax3.axhline(y=0, color='gray', linestyle='--', linewidth=1)
        
        # Chart 4: Summary Stats
        ax4 = fig.add_subplot(gs[1, 1])
        ax4.axis('off')
        
        total_income = sum(incomes)
        total_expenses = sum(expenses)
        total_net = sum(net_flows)
        avg_monthly_income = total_income / len(sorted_months) if sorted_months else 0
        avg_monthly_expenses = total_expenses / len(sorted_months) if sorted_months else 0
        savings_rate = (total_net / total_income * 100) if total_income > 0 else 0
        
        summary_text = f"""
        📊 FINANCIAL SUMMARY ({months} Months)
        ══════════════════════════════════════
        
        💰 Total Income:          RM {total_income:,.2f}
        💸 Total Expenses:        RM {total_expenses:,.2f}
        💵 Net Cash Flow:         RM {total_net:,.2f}
        
        📈 Avg Monthly Income:    RM {avg_monthly_income:,.2f}
        📉 Avg Monthly Expenses:  RM {avg_monthly_expenses:,.2f}
        
        🎯 Savings Rate:          {savings_rate:.1f}%
        
        {'✅ Great job! You are saving money!' if total_net > 0 else '⚠️ Consider reducing expenses'}
        """
        
        ax4.text(0.1, 0.5, summary_text, transform=ax4.transAxes, fontsize=11,
                verticalalignment='center', fontfamily='monospace',
                bbox=dict(boxstyle='round', facecolor='#F8F9FA', edgecolor='#DEE2E6'))
        
        fig.suptitle(f'Monthly Financial Summary - Last {months} Months', fontsize=16, fontweight='bold', y=0.98)
        
        plt.tight_layout()
        
        # Convert to base64
        chart_base64 = self._fig_to_base64(fig)
        
        return {
            "success": True,
            "chart_type": "monthly_summary",
            "period_months": months,
            "total_income": round(total_income, 2),
            "total_expenses": round(total_expenses, 2),
            "net_cash_flow": round(total_net, 2),
            "average_monthly_income": round(avg_monthly_income, 2),
            "average_monthly_expenses": round(avg_monthly_expenses, 2),
            "savings_rate": round(savings_rate, 1),
            "monthly_breakdown": [
                {
                    "month": m,
                    "income": round(monthly_data[sorted_months[i]]["income"], 2),
                    "expenses": round(monthly_data[sorted_months[i]]["expenses"], 2),
                    "net": round(net_flows[i], 2)
                }
                for i, m in enumerate(months_labels)
            ],
            "currency": "MYR",
            "chart_image_base64": chart_base64,
            "message": f"Here's your {months}-month financial summary. Your savings rate is {savings_rate:.1f}% with a net cash flow of RM {total_net:,.2f}."
        }
