from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt
from config.settings import settings
from database.mongodb import db
from bson.objectid import ObjectId

security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(401, "Token invalide")
        user = db.users.find_one({"_id": ObjectId(user_id)})
        if not user:
            raise HTTPException(401, "Utilisateur introuvable")
        user["_id"] = str(user["_id"])
        return user
    except Exception:
        raise HTTPException(401, "Token invalide ou expiré")