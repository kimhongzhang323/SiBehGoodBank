"""
Configuration settings for Notification Service
"""
from pydantic_settings import BaseSettings
from typing import Optional
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings"""
    
    # Service Configuration
    SERVICE_NAME: str = "notification-service"
    SERVICE_PORT: int = 8089
    DEBUG: bool = False
    
    # SMTP Configuration (Email)
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USERNAME: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    SMTP_USE_TLS: bool = True
    EMAIL_FROM_NAME: str = "Sibeh Good Bank"
    EMAIL_FROM_ADDRESS: str = "noreply@sibehgoodbank.com"
    
    # SendGrid Configuration (Alternative Email)
    SENDGRID_API_KEY: Optional[str] = None
    USE_SENDGRID: bool = False
    
    # Twilio Configuration (SMS)
    TWILIO_ACCOUNT_SID: Optional[str] = None
    TWILIO_AUTH_TOKEN: Optional[str] = None
    TWILIO_PHONE_NUMBER: Optional[str] = None
    
    # Firebase Configuration (Push Notifications)
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None
    
    # Redis Configuration (for queuing)
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    
    # Rate Limiting
    MAX_EMAILS_PER_HOUR: int = 100
    MAX_SMS_PER_HOUR: int = 50
    MAX_PUSH_PER_HOUR: int = 500
    
    # Retry Configuration
    MAX_RETRIES: int = 3
    RETRY_DELAY_SECONDS: int = 60
    
    # Template paths
    TEMPLATE_DIR: str = "templates"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    return Settings()
