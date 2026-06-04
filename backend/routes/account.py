from pydantic import BaseModel, EmailStr
from fastapi import APIRouter, HTTPException, Depends
from database.mongodb import db
from middleware.auth import get_current_user
from services.auth_service import hash_password, verify_password
from services.email_service import EmailService
from bson.objectid import ObjectId
import random
from datetime import datetime, timedelta

router = APIRouter(prefix="/api", tags=["Account"])

class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

class ChangeNameRequest(BaseModel):
    new_name: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class VerifyResetCodeRequest(BaseModel):
    email: EmailStr
    code: str

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    code: str
    new_password: str

@router.post("/change-password")
def change_password(
    request: ChangePasswordRequest,
    current_user=Depends(get_current_user)
):
    user = db.users.find_one({"_id": ObjectId(current_user["_id"])})
    if not verify_password(request.current_password, user["password"]):
        raise HTTPException(status_code=401, detail="Mot de passe actuel incorrect")
    new_hashed = hash_password(request.new_password)
    db.users.update_one({"_id": user["_id"]}, {"$set": {"password": new_hashed}})
    return {"message": "Mot de passe modifié avec succès"}

@router.post("/change-name")
def change_name(
    request: ChangeNameRequest,
    current_user=Depends(get_current_user)
):
    db.users.update_one(
        {"_id": ObjectId(current_user["_id"])},
        {"$set": {"full_name": request.new_name}}
    )
    return {"message": "Nom modifié avec succès"}

@router.post("/forgot-password")
def forgot_password(request: ForgotPasswordRequest):
    user = db.users.find_one({"email": request.email})
    # Ne pas révéler l'existence de l'email (sécurité)
    if not user:
        return {"message": "Si cet email existe, un code vous a été envoyé"}
    reset_code = str(random.randint(100000, 999999))
    # Stocker ou mettre à jour le code avec expiration (10 minutes)
    db.password_resets.update_one(
        {"email": request.email},
        {
            "$set": {
                "code": reset_code,
                "expires_at": datetime.utcnow() + timedelta(minutes=10)
            }
        },
        upsert=True
    )
    subject = "Code de réinitialisation AgrIA"
    html = f"""
    <html>
    <body>
        <h2>Réinitialisation du mot de passe</h2>
        <p>Votre code à 6 chiffres : <strong>{reset_code}</strong></p>
        <p>Ce code expire dans 10 minutes.</p>
        <p>Si vous n'êtes pas à l'origine, ignorez cet email.</p>
    </body>
    </html>
    """
    EmailService._send_email(request.email, subject, html)
    return {"message": "Code envoyé"}

@router.post("/verify-reset-code")
def verify_reset_code(request: VerifyResetCodeRequest):
    reset = db.password_resets.find_one({
        "email": request.email,
        "code": request.code,
        "expires_at": {"$gt": datetime.utcnow()}
    })
    if not reset:
        raise HTTPException(status_code=400, detail="Code invalide ou expiré")
    return {"message": "Code valide"}

@router.post("/reset-password")
def reset_password(request: ResetPasswordRequest):
    reset = db.password_resets.find_one({
        "email": request.email,
        "code": request.code,
        "expires_at": {"$gt": datetime.utcnow()}
    })
    if not reset:
        raise HTTPException(status_code=400, detail="Code invalide ou expiré")
    new_hashed = hash_password(request.new_password)
    db.users.update_one(
        {"email": request.email},
        {"$set": {"password": new_hashed}}
    )
    db.password_resets.delete_one({"_id": reset["_id"]})
    return {"message": "Mot de passe réinitialisé"}