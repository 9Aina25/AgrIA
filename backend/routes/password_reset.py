from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database.mongodb import db
from services.auth_service import hash_password
from services.email_service import EmailService
from bson.objectid import ObjectId
import jwt
import secrets
from datetime import datetime, timedelta
import os

router = APIRouter(prefix="/api", tags=["PasswordReset"])

RESET_SECRET = os.getenv("RESET_SECRET", "reset_secret_key")

class ForgotPasswordRequest(BaseModel):
    email: str

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

@router.post("/forgot-password")
def forgot_password(req: ForgotPasswordRequest):
    user = db.users.find_one({"email": req.email})
    if not user:
        raise HTTPException(status_code=404, detail="Email non trouvé")

    token = jwt.encode(
        {"user_id": str(user["_id"]), "exp": datetime.utcnow() + timedelta(hours=1)},
        RESET_SECRET,
        algorithm="HS256"
    )

    reset_link = f"http://localhost:8080/reset-password?token={token}"
    EmailService.send_reset_email(req.email, user["full_name"], reset_link)

    return {"message": "Email de réinitialisation envoyé"}

@router.post("/reset-password")
def reset_password(req: ResetPasswordRequest):
    try:
        payload = jwt.decode(req.token, RESET_SECRET, algorithms=["HS256"])
        user_id = payload["user_id"]
        hashed = hash_password(req.new_password)
        db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {"password_hash": hashed}}
        )
        return {"message": "Mot de passe mis à jour avec succès"}
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail="Lien expiré")
    except Exception:
        raise HTTPException(status_code=400, detail="Lien invalide")