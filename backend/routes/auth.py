from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from services.auth_service import hash_password, create_access_token, verify_password
from services.email_service import EmailService
from database.mongodb import db
from config.settings import settings
from datetime import datetime, timedelta
import secrets
import socket
import random
from bson.objectid import ObjectId
from middleware.auth import get_current_user
router = APIRouter(prefix="/api", tags=["Authentication"])

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

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

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "localhost"

@router.post("/register", status_code=201)
def register(user: UserRegister):
    print("=" * 50)
    print(f"📝 REQUETE REGISTRE RECUE")
    print(f"   Email: '{user.email}'")
    print(f"   Password: '{user.password}'")
    print(f"   Full name: '{user.full_name}'")
    print("=" * 50)

    if db.users.find_one({"email": user.email}):
        print("❌ Email déjà utilisé")
        raise HTTPException(status_code=400, detail="Cet email est déjà utilisé")

    hashed = hash_password(user.password)
    validation_token = secrets.token_urlsafe(32)
    is_admin = user.email == "admin@agria.com"

    user_data = {
        "email": user.email,
        "full_name": user.full_name,
        "password": hashed,
        "created_at": datetime.utcnow(),
        "last_login": None,
        "is_active": is_admin,
        "is_email_verified": is_admin,
        "is_admin": is_admin,
        "role": "super_admin" if is_admin else "user",
        "validation_token": None if is_admin else validation_token,
        "send_notifications": True
    }

    result = db.users.insert_one(user_data)
    print(f"✅ Utilisateur inséré avec _id: {result.inserted_id}")

    if not is_admin and settings.SEND_EMAILS:
        local_ip = get_local_ip()
        validation_link = f"http://{local_ip}:{settings.PORT}/api/verify-email?token={validation_token}"
        email_sent = EmailService.send_validation_email(
            user_email=user.email,
            user_name=user.full_name,
            validation_link=validation_link
        )
        message = "✅ Un email de validation vous a été envoyé" if email_sent else "⚠️ Compte créé mais email non envoyé."
    else:
        message = "✅ Compte administrateur créé avec succès"

    return {
        "message": message,
        "user_id": str(result.inserted_id),
        "is_admin": is_admin
    }

@router.get("/verify-email")
def verify_email(token: str):
    print(f"🔍 Tentative d'activation avec token: {token}")
    user = db.users.find_one({"validation_token": token})
    if not user:
        print("❌ Aucun utilisateur trouvé avec ce token")
        raise HTTPException(status_code=400, detail="Lien invalide ou déjà utilisé")
    print(f"👤 Utilisateur trouvé: {user['email']}, actif: {user.get('is_active')}")
    if user.get("is_active"):
        return {"message": "Compte déjà activé. Vous pouvez vous connecter."}
    db.users.update_one(
        {"_id": user["_id"]},
        {"$set": {
            "is_active": True,
            "is_email_verified": True,
            "validation_token": None
        }}
    )
    print("✅ Compte activé avec succès")
    return {"message": "✅ Compte activé ! Vous pouvez maintenant vous connecter."}

@router.post("/login")
def login(user: UserLogin):
    db_user = db.users.find_one({"email": user.email})
    if not db_user:
        print(f"❌ Login échoué: email {user.email} non trouvé")
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    stored_password = db_user.get("password")
    if not stored_password:
        raise HTTPException(status_code=401, detail="Erreur de configuration du compte")
    if not verify_password(user.password, stored_password):
        print(f"❌ Mot de passe incorrect pour {user.email}")
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    if not db_user.get("is_active", False):
        print(f"❌ Compte non activé pour {user.email}")
        raise HTTPException(status_code=401, detail="Compte non activé. Vérifiez vos emails.")
    db.users.update_one(
        {"_id": db_user["_id"]},
        {"$set": {"last_login": datetime.utcnow()}}
    )
    token = create_access_token({"sub": str(db_user["_id"])})
    print(f"✅ Connexion réussie pour {user.email}")
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "email": db_user["email"],
            "full_name": db_user["full_name"],
            "is_admin": db_user.get("is_admin", False)
        }
    }

# ================== NOUVELLES FONCTIONNALITÉS SÉCURITÉ ==================

@router.post("/change-password")
def change_password(
    request: ChangePasswordRequest,
    current_user=Depends(get_current_user)  # tu dois avoir ce middleware
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
    if not user:
        raise HTTPException(status_code=404, detail="Cet email n'existe pas dans notre système")
    
    reset_code = str(random.randint(100000, 999999))
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
        <p>Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.</p>
    </body>
    </html>
    """
    success = EmailService._send_email(request.email, subject, html)
    if not success:
        raise HTTPException(status_code=500, detail="Erreur lors de l'envoi de l'email. Veuillez réessayer.")
        
    return {"message": "Code envoyé avec succès"}

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