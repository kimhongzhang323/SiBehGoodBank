"""
Configuration for Fraud Detection Service.
"""
from pydantic_settings import BaseSettings
from typing import Optional
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""
    
    # Service Configuration
    service_name: str = "fraud-detection-service"
    service_version: str = "1.0.0"
    debug: bool = False
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8086
    
    # Redis Configuration
    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_db: int = 2
    
    # Security
    api_key: Optional[str] = None
    
    # Service URLs
    transaction_service_url: str = "http://localhost:8081"
    notification_service_url: str = "http://localhost:8088"
    
    # Fraud Detection Configuration
    anomaly_threshold: float = 0.7
    velocity_window_minutes: int = 60
    max_transactions_per_hour: int = 20
    high_risk_amount_threshold: float = 5000.0
    model_path: str = "./models"
    
    class Config:
        env_file = ".env"
        env_prefix = "FRAUD_"
        protected_namespaces = ()


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()
