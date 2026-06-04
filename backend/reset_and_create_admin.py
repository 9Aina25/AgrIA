# reset_and_create_admin.py
from pymongo import MongoClient
from datetime import datetime
from services.auth_service import hash_password

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("🔄 RÉINITIALISATION COMPLÈTE")
print("=" * 50)

# 1. Supprimer tous les utilisateurs
users_count = db.users.count_documents({})
db.users.delete_many({})
print(f"✅ {users_count} utilisateur(s) supprimé(s)")

# 2. Créer l'admin avec le nouveau hash
print("\n👑 Création de l'administrateur...")

hashed_password = hash_password("Admin123!")

admin_data = {
    "email": "admin@agria.com",
    "full_name": "Administrateur AgrIA",
    "password": hashed_password,  # String
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

# 3. Vérifier
admin = db.users.find_one({"email": "admin@agria.com"})
if admin:
    print(f"\n📋 Vérification admin:")
    print(f"   Email: {admin['email']}")
    print(f"   is_admin: {admin.get('is_admin', False)}")
    print(f"   is_active: {admin.get('is_active', False)}")
    print(f"   Type du password: {type(admin.get('password'))}")

client.close()
print("\n✅ Configuration terminée !")