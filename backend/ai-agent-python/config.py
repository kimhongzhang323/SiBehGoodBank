"""
Configuration module for the AI Agent Service.
"""
import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=False,
        protected_namespaces=('settings_',)  # Remove 'model_' from protected namespaces
    )
    
    # Anthropic Configuration
    anthropic_api_key: str = ""
    anthropic_model: str = "claude-sonnet-4-20250514"
    max_tokens: int = 4096
    temperature: float = 0.7
    
    # Server Configuration
    server_host: str = "0.0.0.0"
    server_port: int = 8084
    debug: bool = True
    
    # Database
    database_url: str = "postgresql://postgres:postgres@localhost:5432/ai_agent_db"
    
    # Redis
    redis_url: str = "redis://localhost:6379/0"
    
    # JWT
    jwt_secret: str = "your-jwt-secret-key-here"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Bank Configuration
    bank_name: str = "SiBeh Good Bank"
    currency: str = "MYR"


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


# Export settings instance for easy import
settings = get_settings()
