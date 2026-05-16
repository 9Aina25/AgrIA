from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from services.auth_service import hash_password, create_access_token, verify_password
from services.email_service import EmailService
from database.mongodb import db
from config.settings import settings
from datetime import datetime
import secrets

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
    
    validation_token = secrets.token_urlsafe(32)
    hashed = hash_password(user.password)

    result = db.users.insert_one({
        "email": user.email,
        "password_hash": hashed,
        "full_name": user.full_name,
        "created_at": datetime.utcnow(),
        "is_active": False,
        "validation_token": validation_token,
        "email_verified": False,
        "send_notifications": True
    })

    validation_link = f"http://localhost:8000/api/verify-email?token={validation_token}"

    # Envoi email de validation
    if settings.SEND_EMAILS and settings.SMTP_USER:
        EmailService.send_validation_email(
            user.email,
            user.full_name,
            validation_link
        )
    
    return {
        "message": "Un email de validation vous a été envoyé",
        "user_id": str(result.inserted_id)
    }

@router.get("/verify-email")
def verify_email(token: str):
    user = db.users.find_one({
        "validation_token": token,
        "is_active": False
    })

    if not user:
        raise HTTPException(
            status_code=400,
            detail="Lien invalide ou déjà utilisé"
        )

    db.users.update_one(
        {"_id": user["_id"]},
        {
            "$set": {
                "is_active": True,
                "validation_token": None,
                "email_verified": True
            }
        }
    )

    return {
        "message": "Compte activé, vous pouvez maintenant vous connecter"
    }

@router.post("/login")
def login(user: UserLogin):
    db_user = db.users.find_one({"email": user.email})

    if not db_user or not verify_password(
        user.password,
        db_user["password_hash"]
    ):
        raise HTTPException(
            status_code=401,
            detail="Email ou mot de passe incorrect"
        )

    if not db_user.get("is_active", False):
        raise HTTPException(
            status_code=401,
            detail="Compte non activé. Vérifiez vos emails."
        )
    
    token = create_access_token({"sub": str(db_user["_id"])})

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "email": db_user["email"],
            "full_name": db_user["full_name"]
        }
    }