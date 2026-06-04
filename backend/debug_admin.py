# debug_admin.py
from pymongo import MongoClient
import bcrypt

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("🔍 DIAGNOSTIC ADMIN")
print("=" * 50)

# 1. Vérifier si l'admin existe
admin = db.users.find_one({"email": "admin@agria.com"})

if not admin:
    print("❌ Admin non trouvé dans la base !")
    print("\n📝 Création de l'admin...")
    
    password = "Admin123!"
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    
    admin_data = {
        "email": "admin@agria.com",
        "full_name": "Administrateur AgrIA",
        "password": hashed,
        "is_active": True,
        "is_email_verified": True,
        "is_admin": True,
        "role": "super_admin"
    }
    
    result = db.users.insert_one(admin_data)
    print(f"✅ Admin créé avec ID: {result.inserted_id}")
    admin = db.users.find_one({"email": "admin@agria.com"})

# 2. Afficher les infos de l'admin
if admin:
    print(f"\n📋 Admin trouvé:")
    print(f"   Email: {admin['email']}")
    print(f"   is_admin: {admin.get('is_admin', False)}")
    print(f"   is_active: {admin.get('is_active', False)}")
    print(f"   Type du password: {type(admin['password'])}")
    print(f"   Longueur du password: {len(admin['password']) if admin['password'] else 0}")
    
    # 3. Tester le mot de passe
    password_test = "Admin123!"
    
    try:
        if isinstance(admin['password'], str):
            pwd_bytes = admin['password'].encode('utf-8')
        else:
            pwd_bytes = admin['password']
        
        is_valid = bcrypt.checkpw(password_test.encode('utf-8'), pwd_bytes)
        print(f"\n🔐 Test du mot de passe 'Admin123!': {'✅ VALIDE' if is_valid else '❌ INVALIDE'}")
        
        if not is_valid:
            print("\n⚠️ Mot de passe invalide ! Mise à jour...")
            new_hashed = bcrypt.hashpw(password_test.encode('utf-8'), bcrypt.gensalt())
            db.users.update_one(
                {"email": "admin@agria.com"},
                {"$set": {"password": new_hashed}}
            )
            print("✅ Mot de passe réinitialisé à 'Admin123!'")
            
            # Retester
            admin = db.users.find_one({"email": "admin@agria.com"})
            pwd_bytes = admin['password'] if isinstance(admin['password'], bytes) else admin['password'].encode('utf-8')
            is_valid = bcrypt.checkpw(password_test.encode('utf-8'), pwd_bytes)
            print(f"   Nouveau test: {'✅ VALIDE' if is_valid else '❌ INVALIDE'}")
            
    except Exception as e:
        print(f"❌ Erreur lors du test: {e}")

# 4. Afficher tous les utilisateurs
print(f"\n📊 Tous les utilisateurs dans la base:")
users = db.users.find({}, {"email": 1, "is_admin": 1})
for u in users:
    print(f"   - {u['email']} (admin: {u.get('is_admin', False)})")

client.close()