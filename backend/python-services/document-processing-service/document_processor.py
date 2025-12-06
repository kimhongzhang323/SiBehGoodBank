"""
Document Processing Engine - OCR and data extraction.
"""
import re
import os
import io
import uuid
import time
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple
from PIL import Image
import numpy as np

from config import settings
from models import (
    DocumentType, ProcessingStatus, DocumentProcessingResponse,
    ExtractedField, OCRResult, BankStatementData, ReceiptData,
    InvoiceData, ICData, PayslipData
)

# Mock OCR - In production, use pytesseract
# import pytesseract
# from pdf2image import convert_from_path


class DocumentProcessor:
    """Document processing and OCR engine."""
    
    # Patterns for different document types
    PATTERNS = {
        'ic_number': r'\d{6}[-]?\d{2}[-]?\d{4}',
        'amount': r'RM\s?[\d,]+\.?\d{0,2}|[\d,]+\.?\d{0,2}\s?MYR',
        'date': r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[/-]\d{2}[/-]\d{2}',
        'account_number': r'\d{10,16}',
        'phone': r'\+?6?0\d{1,2}[-\s]?\d{3,4}[-\s]?\d{4}',
        'email': r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    }
    
    # Keywords for document classification
    DOCUMENT_KEYWORDS = {
        DocumentType.BANK_STATEMENT: ['statement', 'bank', 'account', 'balance', 'transaction', 'maybank', 'cimb', 'public bank'],
        DocumentType.RECEIPT: ['receipt', 'total', 'subtotal', 'tax', 'gst', 'sst', 'change', 'paid'],
        DocumentType.INVOICE: ['invoice', 'bill to', 'ship to', 'due date', 'payment terms', 'subtotal'],
        DocumentType.IC_FRONT: ['warganegara', 'malaysia', 'kad pengenalan'],
        DocumentType.IC_BACK: ['alamat', 'address'],
        DocumentType.PAYSLIP: ['payslip', 'salary', 'epf', 'socso', 'pcb', 'gross', 'net pay', 'deduction'],
        DocumentType.UTILITY_BILL: ['tnb', 'tenaga', 'air selangor', 'unifi', 'water', 'electric', 'bill'],
        DocumentType.CHEQUE: ['cheque', 'check', 'pay to the order', 'bearer'],
    }
    
    def __init__(self):
        # Create directories
        os.makedirs(settings.upload_dir, exist_ok=True)
        os.makedirs(settings.processed_dir, exist_ok=True)
    
    def process_document(
        self,
        file_content: bytes,
        filename: str,
        document_type: Optional[DocumentType] = None,
        enhance: bool = False,
    ) -> DocumentProcessingResponse:
        """Process a document and extract information."""
        start_time = time.time()
        document_id = str(uuid.uuid4())
        errors = []
        
        try:
            # Determine file type
            is_pdf = filename.lower().endswith('.pdf')
            
            # Extract text
            if is_pdf:
                raw_text = self._extract_text_from_pdf(file_content)
            else:
                raw_text = self._extract_text_from_image(file_content, enhance)
            
            # Classify document if not specified
            if document_type is None:
                document_type, confidence = self._classify_document(raw_text)
            else:
                confidence = 0.9  # User-specified type
            
            # Extract fields based on document type
            extracted_fields = self._extract_fields(raw_text, document_type)
            
            # Get structured data
            structured_data = self._extract_structured_data(raw_text, document_type)
            
            processing_time = int((time.time() - start_time) * 1000)
            
            return DocumentProcessingResponse(
                document_id=document_id,
                document_type=document_type,
                status=ProcessingStatus.COMPLETED,
                confidence=confidence,
                raw_text=raw_text,
                extracted_fields=extracted_fields,
                structured_data=structured_data,
                processing_time_ms=processing_time,
                errors=errors,
            )
            
        except Exception as e:
            processing_time = int((time.time() - start_time) * 1000)
            return DocumentProcessingResponse(
                document_id=document_id,
                document_type=document_type or DocumentType.UNKNOWN,
                status=ProcessingStatus.FAILED,
                confidence=0,
                processing_time_ms=processing_time,
                errors=[str(e)],
            )
    
    def _extract_text_from_image(self, image_data: bytes, enhance: bool = False) -> str:
        """Extract text from image using OCR."""
        # Mock OCR response for demo
        # In production:
        # image = Image.open(io.BytesIO(image_data))
        # if enhance:
        #     image = self._enhance_image(image)
        # text = pytesseract.image_to_string(image, lang=settings.ocr_language)
        
        return self._generate_mock_ocr_text()
    
    def _extract_text_from_pdf(self, pdf_data: bytes) -> str:
        """Extract text from PDF."""
        # Mock PDF text extraction
        # In production:
        # from PyPDF2 import PdfReader
        # reader = PdfReader(io.BytesIO(pdf_data))
        # text = ""
        # for page in reader.pages:
        #     text += page.extract_text() + "\n"
        
        return self._generate_mock_ocr_text()
    
    def _generate_mock_ocr_text(self) -> str:
        """Generate mock OCR text for demo."""
        mock_texts = [
            """
            MAYBANK BERHAD
            Statement of Account
            
            Account Number: 1234567890
            Account Holder: AHMAD BIN ABDULLAH
            Statement Period: 01/11/2024 - 30/11/2024
            
            Opening Balance: RM 5,234.50
            Closing Balance: RM 8,456.75
            
            Transactions:
            01/11/2024  Salary Credit          +RM 5,500.00
            05/11/2024  TNB Bill Payment       -RM 156.80
            10/11/2024  Groceries Tesco        -RM 234.50
            15/11/2024  Transfer to Siti       -RM 500.00
            20/11/2024  Petrol Shell           -RM 120.00
            25/11/2024  Online Shopping        -RM 267.45
            
            Total Credits: RM 5,500.00
            Total Debits: RM 1,278.75
            """,
            """
            RECEIPT
            
            TESCO STORES (MALAYSIA) SDN BHD
            Lot 1234, Jalan ABC
            47301 Petaling Jaya
            
            Date: 15/11/2024
            Time: 14:35:22
            Receipt No: TES-2024111500123
            
            Item                    Qty     Price
            Milk 1L                 2       RM 12.80
            Bread Gardenia          1       RM 3.50
            Rice 5kg                1       RM 28.90
            Eggs (10)               2       RM 15.60
            Vegetables              -       RM 23.45
            
            Subtotal:               RM 84.25
            SST (6%):               RM 5.06
            Total:                  RM 89.31
            
            Cash:                   RM 100.00
            Change:                 RM 10.69
            
            Thank you for shopping!
            """,
            """
            WARGANEGARA MALAYSIA
            IDENTITY CARD / KAD PENGENALAN
            
            Nama / Name: AHMAD BIN ABDULLAH
            No. K/P: 850115-10-5234
            Jantina / Sex: LELAKI
            Warganegara: MALAYSIA
            
            ALAMAT / ADDRESS:
            NO. 123, JALAN BUNGA RAYA 5,
            TAMAN MAJU JAYA,
            47300 PETALING JAYA,
            SELANGOR DARUL EHSAN.
            """
        ]
        
        import random
        return random.choice(mock_texts)
    
    def _classify_document(self, text: str) -> Tuple[DocumentType, float]:
        """Classify document type based on content."""
        text_lower = text.lower()
        
        scores = {}
        for doc_type, keywords in self.DOCUMENT_KEYWORDS.items():
            score = sum(1 for kw in keywords if kw in text_lower)
            scores[doc_type] = score / len(keywords) if keywords else 0
        
        if not scores or max(scores.values()) == 0:
            return DocumentType.UNKNOWN, 0.0
        
        best_type = max(scores, key=scores.get)
        confidence = min(0.95, scores[best_type] + 0.3)  # Boost confidence a bit
        
        return best_type, round(confidence, 2)
    
    def _extract_fields(self, text: str, doc_type: DocumentType) -> List[ExtractedField]:
        """Extract relevant fields based on document type."""
        fields = []
        
        # Extract common patterns
        for pattern_name, pattern in self.PATTERNS.items():
            matches = re.findall(pattern, text)
            for match in matches:
                fields.append(ExtractedField(
                    field_name=pattern_name,
                    value=match,
                    confidence=0.85,
                ))
        
        return fields
    
    def _extract_structured_data(self, text: str, doc_type: DocumentType) -> Optional[Dict[str, Any]]:
        """Extract structured data based on document type."""
        if doc_type == DocumentType.BANK_STATEMENT:
            return self._extract_bank_statement(text).model_dump()
        elif doc_type == DocumentType.RECEIPT:
            return self._extract_receipt(text).model_dump()
        elif doc_type == DocumentType.INVOICE:
            return self._extract_invoice(text).model_dump()
        elif doc_type in [DocumentType.IC_FRONT, DocumentType.IC_BACK]:
            return self._extract_ic(text).model_dump()
        elif doc_type == DocumentType.PAYSLIP:
            return self._extract_payslip(text).model_dump()
        
        return None
    
    def _extract_bank_statement(self, text: str) -> BankStatementData:
        """Extract bank statement data."""
        data = BankStatementData()
        
        # Extract bank name
        banks = ['maybank', 'cimb', 'public bank', 'rhb', 'hong leong', 'ambank']
        for bank in banks:
            if bank in text.lower():
                data.bank_name = bank.title()
                break
        
        # Extract account number
        account_match = re.search(r'Account\s*(?:Number|No\.?):\s*(\d{10,16})', text, re.IGNORECASE)
        if account_match:
            data.account_number = account_match.group(1)
        
        # Extract account holder
        holder_match = re.search(r'Account\s*Holder:\s*([A-Z\s]+)', text)
        if holder_match:
            data.account_holder = holder_match.group(1).strip()
        
        # Extract balances
        opening_match = re.search(r'Opening\s*Balance:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if opening_match:
            data.opening_balance = float(opening_match.group(1).replace(',', ''))
        
        closing_match = re.search(r'Closing\s*Balance:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if closing_match:
            data.closing_balance = float(closing_match.group(1).replace(',', ''))
        
        # Extract totals
        credits_match = re.search(r'Total\s*Credits?:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if credits_match:
            data.total_credits = float(credits_match.group(1).replace(',', ''))
        
        debits_match = re.search(r'Total\s*Debits?:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if debits_match:
            data.total_debits = float(debits_match.group(1).replace(',', ''))
        
        # Extract transactions
        transaction_pattern = r'(\d{2}/\d{2}/\d{4})\s+(.+?)\s+([+-]?RM\s*[\d,]+\.?\d*)'
        for match in re.finditer(transaction_pattern, text):
            data.transactions.append({
                "date": match.group(1),
                "description": match.group(2).strip(),
                "amount": match.group(3),
            })
        
        return data
    
    def _extract_receipt(self, text: str) -> ReceiptData:
        """Extract receipt data."""
        data = ReceiptData()
        
        # Extract total
        total_match = re.search(r'Total:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if total_match:
            data.total_amount = float(total_match.group(1).replace(',', ''))
        
        # Extract subtotal
        subtotal_match = re.search(r'Subtotal:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if subtotal_match:
            data.subtotal = float(subtotal_match.group(1).replace(',', ''))
        
        # Extract tax
        tax_match = re.search(r'(?:SST|GST|Tax).*?RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if tax_match:
            data.tax_amount = float(tax_match.group(1).replace(',', ''))
        
        # Extract date
        date_match = re.search(r'Date:\s*(\d{1,2}/\d{1,2}/\d{2,4})', text, re.IGNORECASE)
        if date_match:
            data.date = date_match.group(1)
        
        # Extract time
        time_match = re.search(r'Time:\s*(\d{1,2}:\d{2}(?::\d{2})?)', text, re.IGNORECASE)
        if time_match:
            data.time = time_match.group(1)
        
        return data
    
    def _extract_invoice(self, text: str) -> InvoiceData:
        """Extract invoice data."""
        data = InvoiceData()
        
        # Extract invoice number
        inv_match = re.search(r'Invoice\s*(?:Number|No\.?):\s*(\S+)', text, re.IGNORECASE)
        if inv_match:
            data.invoice_number = inv_match.group(1)
        
        # Extract total
        total_match = re.search(r'Total:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if total_match:
            data.total_amount = float(total_match.group(1).replace(',', ''))
        
        return data
    
    def _extract_ic(self, text: str) -> ICData:
        """Extract IC data."""
        data = ICData()
        
        # Extract IC number
        ic_match = re.search(r'(?:No\.\s*K/P|IC\s*No):\s*(\d{6}[-]?\d{2}[-]?\d{4})', text, re.IGNORECASE)
        if ic_match:
            data.ic_number = ic_match.group(1)
        
        # Extract name
        name_match = re.search(r'(?:Nama|Name):\s*([A-Z\s]+)', text)
        if name_match:
            data.name = name_match.group(1).strip()
        
        # Extract gender
        if 'lelaki' in text.lower() or 'male' in text.lower():
            data.gender = 'Male'
        elif 'perempuan' in text.lower() or 'female' in text.lower():
            data.gender = 'Female'
        
        # Extract nationality
        if 'warganegara' in text.lower() or 'malaysia' in text.lower():
            data.nationality = 'Malaysian'
        
        return data
    
    def _extract_payslip(self, text: str) -> PayslipData:
        """Extract payslip data."""
        data = PayslipData()
        
        # Extract employee name
        name_match = re.search(r'(?:Employee\s*Name|Name):\s*([A-Z\s]+)', text, re.IGNORECASE)
        if name_match:
            data.employee_name = name_match.group(1).strip()
        
        # Extract gross salary
        gross_match = re.search(r'Gross\s*(?:Salary|Pay):\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if gross_match:
            data.gross_salary = float(gross_match.group(1).replace(',', ''))
        
        # Extract net salary
        net_match = re.search(r'Net\s*(?:Salary|Pay):\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if net_match:
            data.net_salary = float(net_match.group(1).replace(',', ''))
        
        # Extract EPF
        epf_match = re.search(r'EPF:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if epf_match:
            data.epf = float(epf_match.group(1).replace(',', ''))
        
        # Extract SOCSO
        socso_match = re.search(r'SOCSO:\s*RM\s*([\d,]+\.?\d*)', text, re.IGNORECASE)
        if socso_match:
            data.socso = float(socso_match.group(1).replace(',', ''))
        
        return data
    
    def perform_ocr(self, image_data: bytes, language: str = None) -> OCRResult:
        """Perform OCR on image."""
        text = self._extract_text_from_image(image_data)
        
        lines = [l for l in text.split('\n') if l.strip()]
        words = text.split()
        
        return OCRResult(
            text=text,
            confidence=0.85,
            language=language or 'eng',
            word_count=len(words),
            line_count=len(lines),
            blocks=[],
        )


# Create singleton instance
document_processor = DocumentProcessor()
