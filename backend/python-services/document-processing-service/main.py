"""
Document Processing Service - Main FastAPI application.
OCR and document data extraction service.
"""
from fastapi import FastAPI, HTTPException, UploadFile, File, Query, Form
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import structlog
from typing import Optional, List
import uuid

from config import settings
from models import (
    DocumentType, ProcessingStatus, DocumentProcessingResponse,
    OCRResult, DocumentValidation, BatchProcessingResponse
)
from document_processor import document_processor

# Configure logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.stdlib.add_log_level,
        structlog.processors.JSONRenderer()
    ]
)
logger = structlog.get_logger()

# Document storage
processed_documents = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    logger.info("Starting Document Processing Service", version=settings.service_version)
    yield
    logger.info("Shutting down Document Processing Service")


app = FastAPI(
    title="SiBeh Good Bank - Document Processing Service",
    description="OCR and document data extraction service",
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


# ===== DOCUMENT PROCESSING =====

@app.post("/api/documents/process", response_model=DocumentProcessingResponse)
async def process_document(
    file: UploadFile = File(...),
    document_type: Optional[DocumentType] = Form(None),
    enhance_image: bool = Form(False),
):
    """
    Process a document and extract information.
    
    Supports images (JPG, PNG) and PDF files.
    """
    try:
        # Validate file size
        content = await file.read()
        file_size_mb = len(content) / (1024 * 1024)
        
        if file_size_mb > settings.max_file_size_mb:
            raise HTTPException(
                status_code=400,
                detail=f"File too large. Max size: {settings.max_file_size_mb}MB"
            )
        
        # Validate file type
        filename = file.filename.lower()
        valid_extensions = settings.supported_image_formats.split(',') + settings.supported_doc_formats.split(',')
        
        if not any(filename.endswith(ext) for ext in valid_extensions):
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported file type. Supported: {', '.join(valid_extensions)}"
            )
        
        # Process document
        result = document_processor.process_document(
            content,
            file.filename,
            document_type,
            enhance_image,
        )
        
        # Store result
        processed_documents[result.document_id] = result
        
        logger.info(
            "Document processed",
            document_id=result.document_id,
            document_type=result.document_type.value,
            status=result.status.value,
            processing_time_ms=result.processing_time_ms,
        )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error processing document", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/documents/{document_id}", response_model=DocumentProcessingResponse)
async def get_processed_document(document_id: str):
    """
    Get a previously processed document by ID.
    """
    if document_id not in processed_documents:
        raise HTTPException(status_code=404, detail="Document not found")
    
    return processed_documents[document_id]


@app.post("/api/documents/batch")
async def batch_process_documents(
    files: List[UploadFile] = File(...),
    document_type: Optional[DocumentType] = Form(None),
):
    """
    Process multiple documents in batch.
    """
    try:
        batch_id = str(uuid.uuid4())
        results = []
        failed = 0
        
        for file in files:
            try:
                content = await file.read()
                result = document_processor.process_document(
                    content,
                    file.filename,
                    document_type,
                    False,
                )
                results.append(result)
                processed_documents[result.document_id] = result
                
                if result.status == ProcessingStatus.FAILED:
                    failed += 1
            except Exception as e:
                failed += 1
                logger.error(f"Error processing {file.filename}", error=str(e))
        
        logger.info(
            "Batch processing completed",
            batch_id=batch_id,
            total=len(files),
            processed=len(results),
            failed=failed,
        )
        
        return BatchProcessingResponse(
            batch_id=batch_id,
            total_documents=len(files),
            processed=len(results) - failed,
            failed=failed,
            results=results,
        )
        
    except Exception as e:
        logger.error("Error in batch processing", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== OCR =====

@app.post("/api/documents/ocr", response_model=OCRResult)
async def perform_ocr(
    file: UploadFile = File(...),
    language: str = Query("eng", description="OCR language (eng, msa, chi_sim)"),
):
    """
    Perform OCR on an image and return raw text.
    """
    try:
        content = await file.read()
        result = document_processor.perform_ocr(content, language)
        
        logger.info(
            "OCR performed",
            filename=file.filename,
            word_count=result.word_count,
            confidence=result.confidence,
        )
        
        return result
        
    except Exception as e:
        logger.error("Error performing OCR", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== DOCUMENT CLASSIFICATION =====

@app.post("/api/documents/classify")
async def classify_document(file: UploadFile = File(...)):
    """
    Classify a document without full processing.
    """
    try:
        content = await file.read()
        
        # Get raw text
        is_pdf = file.filename.lower().endswith('.pdf')
        if is_pdf:
            text = document_processor._extract_text_from_pdf(content)
        else:
            text = document_processor._extract_text_from_image(content)
        
        # Classify
        doc_type, confidence = document_processor._classify_document(text)
        
        return {
            "document_type": doc_type.value,
            "confidence": confidence,
            "suggestions": _get_type_suggestions(doc_type),
        }
        
    except Exception as e:
        logger.error("Error classifying document", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== VALIDATION =====

@app.post("/api/documents/validate", response_model=DocumentValidation)
async def validate_document(
    file: UploadFile = File(...),
    expected_type: DocumentType = Query(..., description="Expected document type"),
):
    """
    Validate a document against expected type.
    """
    try:
        content = await file.read()
        result = document_processor.process_document(content, file.filename, None, False)
        
        is_valid = result.document_type == expected_type and result.confidence >= 0.7
        
        issues = []
        suggestions = []
        
        if result.document_type != expected_type:
            issues.append(f"Document appears to be {result.document_type.value}, not {expected_type.value}")
            suggestions.append("Please upload the correct document type")
        
        if result.confidence < 0.7:
            issues.append(f"Low confidence ({result.confidence:.0%}) in document classification")
            suggestions.append("Ensure document is clear and properly scanned")
        
        if result.status == ProcessingStatus.FAILED:
            issues.extend(result.errors)
            suggestions.append("Try re-scanning with better lighting")
        
        return DocumentValidation(
            is_valid=is_valid,
            document_type=result.document_type,
            confidence=result.confidence,
            issues=issues,
            suggestions=suggestions,
        )
        
    except Exception as e:
        logger.error("Error validating document", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== SPECIFIC DOCUMENT TYPES =====

@app.post("/api/documents/bank-statement")
async def process_bank_statement(file: UploadFile = File(...)):
    """
    Process a bank statement and extract transactions.
    """
    try:
        content = await file.read()
        result = document_processor.process_document(
            content, file.filename, DocumentType.BANK_STATEMENT, False
        )
        
        if result.document_type != DocumentType.BANK_STATEMENT:
            raise HTTPException(
                status_code=400,
                detail="Document does not appear to be a bank statement"
            )
        
        return {
            "document_id": result.document_id,
            "bank_statement": result.structured_data,
            "confidence": result.confidence,
            "processing_time_ms": result.processing_time_ms,
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error processing bank statement", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/documents/receipt")
async def process_receipt(file: UploadFile = File(...)):
    """
    Process a receipt and extract items and totals.
    """
    try:
        content = await file.read()
        result = document_processor.process_document(
            content, file.filename, DocumentType.RECEIPT, False
        )
        
        return {
            "document_id": result.document_id,
            "receipt": result.structured_data,
            "confidence": result.confidence,
            "processing_time_ms": result.processing_time_ms,
        }
        
    except Exception as e:
        logger.error("Error processing receipt", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/documents/ic")
async def process_ic(file: UploadFile = File(...)):
    """
    Process Malaysian IC (MyKad) and extract information.
    """
    try:
        content = await file.read()
        result = document_processor.process_document(
            content, file.filename, DocumentType.IC_FRONT, False
        )
        
        return {
            "document_id": result.document_id,
            "ic_data": result.structured_data,
            "confidence": result.confidence,
            "processing_time_ms": result.processing_time_ms,
        }
        
    except Exception as e:
        logger.error("Error processing IC", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/documents/payslip")
async def process_payslip(file: UploadFile = File(...)):
    """
    Process a payslip and extract salary information.
    """
    try:
        content = await file.read()
        result = document_processor.process_document(
            content, file.filename, DocumentType.PAYSLIP, False
        )
        
        return {
            "document_id": result.document_id,
            "payslip": result.structured_data,
            "confidence": result.confidence,
            "processing_time_ms": result.processing_time_ms,
        }
        
    except Exception as e:
        logger.error("Error processing payslip", error=str(e))
        raise HTTPException(status_code=500, detail=str(e))


# ===== HELPERS =====

def _get_type_suggestions(doc_type: DocumentType) -> List[str]:
    """Get suggestions for document type."""
    suggestions = {
        DocumentType.BANK_STATEMENT: ["Can extract transactions, balances, and account info"],
        DocumentType.RECEIPT: ["Can extract items, totals, merchant info"],
        DocumentType.INVOICE: ["Can extract invoice details and line items"],
        DocumentType.IC_FRONT: ["Can extract name, IC number, and personal info"],
        DocumentType.PAYSLIP: ["Can extract salary, deductions, and employer info"],
        DocumentType.UTILITY_BILL: ["Can extract bill amount and account details"],
        DocumentType.UNKNOWN: ["Document type could not be determined. Try specifying the type."],
    }
    return suggestions.get(doc_type, [])


# ===== INFO ENDPOINTS =====

@app.get("/api/documents/supported-types")
async def get_supported_types():
    """Get list of supported document types."""
    return {
        "document_types": [
            {
                "type": dt.value,
                "description": _get_type_description(dt),
            }
            for dt in DocumentType
        ],
        "supported_formats": {
            "images": settings.supported_image_formats.split(','),
            "documents": settings.supported_doc_formats.split(','),
        },
        "max_file_size_mb": settings.max_file_size_mb,
    }


def _get_type_description(doc_type: DocumentType) -> str:
    """Get description for document type."""
    descriptions = {
        DocumentType.BANK_STATEMENT: "Bank account statements with transactions",
        DocumentType.RECEIPT: "Purchase receipts from merchants",
        DocumentType.INVOICE: "Bills and invoices for services",
        DocumentType.IC_FRONT: "Malaysian IC (MyKad) front",
        DocumentType.IC_BACK: "Malaysian IC (MyKad) back with address",
        DocumentType.PASSPORT: "International passport",
        DocumentType.UTILITY_BILL: "Utility bills (TNB, water, internet)",
        DocumentType.PAYSLIP: "Salary payslips",
        DocumentType.TAX_FORM: "Tax forms and documents",
        DocumentType.CHEQUE: "Bank cheques",
        DocumentType.UNKNOWN: "Unclassified document",
    }
    return descriptions.get(doc_type, "Document type")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
