# recreate_admin.py
from pymongo import MongoClient
from datetime import datetime
import bcrypt

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("👑 RECRÉATION DE L'ADMIN")
print("=" * 50)

# Supprimer l'ancien admin
result = db.users.delete_many({"email": "admin@agria.com"})
print(f"🗑️ Ancien admin supprimé: {result.deleted_count}")

# Hasher le mot de passe
password = "Admin123!"
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
print(f"🔐 Nouveau hash créé")

# Créer le nouvel admin
admin_data = {
    "email": "admin@agria.com",
    "full_name": "Administrateur AgrIA",
    "password": hashed,
    "created_at": datetime.utcnow(),
    "last_login": None,
    "is_active": True,
    "is_email_verified": True,
    "is_admin": True,
    "role": "super_admin",
    "validation_token": None,
    "send_notifications": True
}

result = db.users.insert_one(admin_data)
print(f"✅ Admin créé avec ID: {result.inserted_id}")

# Tester la connexion
admin = db.users.find_one({"email": "admin@agria.com"})
test = bcrypt.checkpw("Admin123!".encode('utf-8'), admin['password'])
print(f"🔐 Test mot de passe: {'✅ OK' if test else '❌ ÉCHEC'}")

print("\n🎯 IDENTIFIANTS:")
print("   Email: admin@agria.com")
print("   Mot de passe: Admin123!")

client.close()