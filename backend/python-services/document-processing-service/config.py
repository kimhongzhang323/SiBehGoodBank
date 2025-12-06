"""
Configuration for Document Processing Service.
"""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""
    
    # Service Configuration
    service_name: str = "document-processing-service"
    service_version: str = "1.0.0"
    debug: bool = False
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8088
    
    # Storage Configuration
    upload_dir: str = "./uploads"
    processed_dir: str = "./processed"
    max_file_size_mb: int = 10
    
    # OCR Configuration
    tesseract_path: str = ""  # Will use system default if empty
    ocr_language: str = "eng+msa"  # English + Malay
    
    # Supported formats
    supported_image_formats: str = "jpg,jpeg,png,bmp,tiff,webp"
    supported_doc_formats: str = "pdf"
    
    class Config:
        env_file = ".env"
        env_prefix = "DOCPROC_"
        protected_namespaces = ()


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()
