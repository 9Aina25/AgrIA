import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # MongoDB
    MONGO_URI: str = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    DATABASE_NAME: str = os.getenv("DATABASE_NAME", "agria")
    
    # JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "agria_super_secret_key_2025")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "10080"))
    
    # Model
    MODEL_PATH: str = os.getenv("MODEL_PATH", "Plant_38_model.keras")
    
    # Server
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    
    # Email
    SMTP_HOST: str = os.getenv("SMTP_HOST", "smtp.gmail.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    SMTP_USER: str = os.getenv("SMTP_USER", "")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")
    SEND_EMAILS: bool = os.getenv("SEND_EMAILS", "True").lower() == "true"

settings = Settings()