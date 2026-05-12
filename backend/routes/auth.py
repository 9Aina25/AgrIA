from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from services.auth_service import hash_password, create_access_token, verify_password
from services.email_service import EmailService
from database.mongodb import db
from config.settings import settings
from datetime import datetime

router = APIRouter(prefix="/api", tags=["Authentication"])

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

@router.post("/register", status_code=201)
def register(user: UserRegister):
    if db.users.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="Cet email est déjà utilisé")
    
    hashed = hash_password(user.password)
    result = db.users.insert_one({
        "email": user.email,
        "password_hash": hashed,
        "full_name": user.full_name,
        "created_at": datetime.utcnow(),
        "email_verified": False,
        "send_notifications": True
    })
    
    # Envoi email de bienvenue (si configuré)
    if settings.SEND_EMAILS and settings.SMTP_USER:
        EmailService.send_welcome_email(user.email, user.full_name)
    
    return {"message": "Utilisateur créé avec succès", "user_id": str(result.inserted_id)}

@router.post("/login")
def login(user: UserLogin):
    db_user = db.users.find_one({"email": user.email})
    if not db_user or not verify_password(user.password, db_user["password_hash"]):
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    
    token = create_access_token({"sub": str(db_user["_id"])})
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {"email": db_user["email"], "full_name": db_user["full_name"]}
    }