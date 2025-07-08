from pydantic_settings import BaseSettings
from pathlib import Path
from dotenv import load_dotenv
import os

# Load .env in local dev (safe to call even in production)
load_dotenv()

class Settings(BaseSettings):
    db_host: str = os.getenv("RDS_HOSTNAME", os.getenv("DB_HOST", "localhost"))
    db_name: str = os.getenv("RDS_DB_NAME", os.getenv("DB_NAME", "petadoption"))
    db_user: str = os.getenv("RDS_USERNAME", os.getenv("DB_USER", "postgres"))
    db_password: str = os.getenv("RDS_PASSWORD", os.getenv("DB_PASSWORD", "postgres"))
    db_port: str = os.getenv("RDS_PORT", os.getenv("DB_PORT", "5432"))
    secret_key: str = "test"
    algorithm: str = "HS256"

    class Config:
        case_sensitive = False

settings = Settings()

