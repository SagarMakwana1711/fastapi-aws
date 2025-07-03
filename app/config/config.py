from pathlib import Path
from pydantic_settings import BaseSettings
#pydantic settings class to extract env variables 
class Settings(BaseSettings):
    db_host: str
    db_name: str
    db_user: str
    db_password: str
    db_port:str
    secret_key:str
    algorithm:str

    class Config:
        case_sensitive = False

settings = Settings()