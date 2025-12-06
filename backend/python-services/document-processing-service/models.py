"""
Data models for Document Processing Service.
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime, date
from enum import Enum


class DocumentType(str, Enum):
    """Document type classification."""
    BANK_STATEMENT = "bank_statement"
    RECEIPT = "receipt"
    INVOICE = "invoice"
    IC_FRONT = "ic_front"
    IC_BACK = "ic_back"
    PASSPORT = "passport"
    UTILITY_BILL = "utility_bill"
    PAYSLIP = "payslip"
    TAX_FORM = "tax_form"
    CHEQUE = "cheque"
    UNKNOWN = "unknown"


class ProcessingStatus(str, Enum):
    """Processing status."""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class ExtractedField(BaseModel):
    """Extracted field from document."""
    field_name: str
    value: str
    confidence: float
    bounding_box: Optional[Dict[str, int]] = None  # x, y, width, height


class BankStatementData(BaseModel):
    """Extracted bank statement data."""
    bank_name: Optional[str] = None
    account_number: Optional[str] = None
    account_holder: Optional[str] = None
    statement_period: Optional[str] = None
    opening_balance: Optional[float] = None
    closing_balance: Optional[float] = None
    total_credits: Optional[float] = None
    total_debits: Optional[float] = None
    transactions: List[Dict[str, Any]] = []


class ReceiptData(BaseModel):
    """Extracted receipt data."""
    merchant_name: Optional[str] = None
    merchant_address: Optional[str] = None
    date: Optional[str] = None
    time: Optional[str] = None
    total_amount: Optional[float] = None
    subtotal: Optional[float] = None
    tax_amount: Optional[float] = None
    payment_method: Optional[str] = None
    items: List[Dict[str, Any]] = []


class InvoiceData(BaseModel):
    """Extracted invoice data."""
    invoice_number: Optional[str] = None
    invoice_date: Optional[str] = None
    due_date: Optional[str] = None
    vendor_name: Optional[str] = None
    vendor_address: Optional[str] = None
    customer_name: Optional[str] = None
    total_amount: Optional[float] = None
    tax_amount: Optional[float] = None
    line_items: List[Dict[str, Any]] = []


class ICData(BaseModel):
    """Extracted IC (Identity Card) data."""
    name: Optional[str] = None
    ic_number: Optional[str] = None
    date_of_birth: Optional[str] = None
    gender: Optional[str] = None
    address: Optional[str] = None
    nationality: Optional[str] = None
    religion: Optional[str] = None


class PayslipData(BaseModel):
    """Extracted payslip data."""
    employee_name: Optional[str] = None
    employee_id: Optional[str] = None
    employer_name: Optional[str] = None
    pay_period: Optional[str] = None
    gross_salary: Optional[float] = None
    net_salary: Optional[float] = None
    deductions: Dict[str, float] = {}
    allowances: Dict[str, float] = {}
    epf: Optional[float] = None
    socso: Optional[float] = None
    tax: Optional[float] = None


class DocumentProcessingRequest(BaseModel):
    """Request for document processing."""
    document_type: Optional[DocumentType] = None
    extract_text: bool = True
    extract_structured: bool = True
    enhance_image: bool = False


class DocumentProcessingResponse(BaseModel):
    """Response from document processing."""
    document_id: str
    document_type: DocumentType
    status: ProcessingStatus
    confidence: float
    raw_text: Optional[str] = None
    extracted_fields: List[ExtractedField] = []
    structured_data: Optional[Dict[str, Any]] = None
    processing_time_ms: int
    processed_at: datetime = Field(default_factory=datetime.now)
    errors: List[str] = []


class OCRResult(BaseModel):
    """OCR extraction result."""
    text: str
    confidence: float
    language: str
    word_count: int
    line_count: int
    blocks: List[Dict[str, Any]] = []


class ImageEnhancementResult(BaseModel):
    """Image enhancement result."""
    original_quality: str
    enhanced_quality: str
    adjustments_made: List[str]
    enhanced_image_path: str


class DocumentValidation(BaseModel):
    """Document validation result."""
    is_valid: bool
    document_type: DocumentType
    confidence: float
    issues: List[str]
    suggestions: List[str]


class BatchProcessingRequest(BaseModel):
    """Batch processing request."""
    document_ids: List[str]
    document_type: Optional[DocumentType] = None


class BatchProcessingResponse(BaseModel):
    """Batch processing response."""
    batch_id: str
    total_documents: int
    processed: int
    failed: int
    results: List[DocumentProcessingResponse]
