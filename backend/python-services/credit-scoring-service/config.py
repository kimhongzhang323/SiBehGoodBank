"""
Configuration for Credit Scoring Service.
"""
from pydantic_settings import BaseSettings
from typing import Optional
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""
    
    # Service Configuration
    service_name: str = "credit-scoring-service"
    service_version: str = "1.0.0"
    debug: bool = False
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8087
    
    # Service URLs
    transaction_service_url: str = "http://localhost:8081"
    account_service_url: str = "http://localhost:8082"
    
    # Credit Scoring Configuration
    min_credit_score: int = 300
    max_credit_score: int = 850
    excellent_threshold: int = 750
    good_threshold: int = 700
    fair_threshold: int = 650
    poor_threshold: int = 550
    
    class Config:
        env_file = ".env"
        env_prefix = "CREDIT_"
        protected_namespaces = ()


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()
