# create_user.py
import bcrypt
from pymongo import MongoClient
from datetime import datetime

client = MongoClient("mongodb://localhost:27017")
db = client["agria"]

email = "test@example.com"
password = "123456"
full_name = "Utilisateur Test"

hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

result = db.users.insert_one({
    "email": email,
    "password_hash": hashed,
    "full_name": full_name,
    "created_at": datetime.utcnow()
})

print(f"✅ Utilisateur créé avec ID: {result.inserted_id}")
print(f"📧 Email: {email}")
print(f"🔑 Mot de passe: {password}")