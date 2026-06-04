# services/auth_service.py
import bcrypt
from jose import JWTError, jwt
from datetime import datetime, timedelta
from config.settings import settings

def hash_password(password: str) -> bytes:
    """Hasher un mot de passe - retourne bytes"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

def verify_password(plain_password: str, hashed_password) -> bool:
    """Vérifier un mot de passe - accepte bytes ou str"""
    # Convertir le mot de passe en bytes
    plain_bytes = plain_password.encode('utf-8')
    
    # Si hashed_password est une string, la convertir en bytes
    if isinstance(hashed_password, str):
        hashed_bytes = hashed_password.encode('utf-8')
    else:
        hashed_bytes = hashed_password
    
    return bcrypt.checkpw(plain_bytes, hashed_bytes)

def create_access_token(data: dict) -> str:
    """Créer un token JWT"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_access_token(token: str):
    """Décoder un token JWT"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None