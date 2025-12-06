"""
Configuration for Analytics Service.
"""
from pydantic_settings import BaseSettings
from typing import Optional
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings."""
    
    # Service Configuration
    service_name: str = "analytics-service"
    service_version: str = "1.0.0"
    debug: bool = False
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8085
    
    # Redis Configuration (for caching)
    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_db: int = 1
    
    # Security
    api_key: Optional[str] = None
    jwt_secret: str = "your-jwt-secret-key"
    jwt_algorithm: str = "HS256"
    
    # Service URLs
    transaction_service_url: str = "http://localhost:8081"
    account_service_url: str = "http://localhost:8082"
    
    # Analytics Configuration
    analysis_cache_ttl: int = 300  # 5 minutes
    max_transactions_for_analysis: int = 1000
    
    class Config:
        env_file = ".env"
        env_prefix = "ANALYTICS_"
        protected_namespaces = ()


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()
