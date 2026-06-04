# check_users.py
from pymongo import MongoClient

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("=" * 50)
print("📊 UTILISATEURS DANS MONGODB")
print("=" * 50)

users = list(db.users.find({}))

if not users:
    print("❌ Aucun utilisateur trouvé dans la base de données")
else:
    print(f"✅ {len(users)} utilisateur(s) trouvé(s):\n")
    for user in users:
        email = user.get('email', 'N/A')
        is_active = user.get('is_active', False)
        is_verified = user.get('is_email_verified', False)
        full_name = user.get('full_name', 'N/A')
        
        print(f"📧 Email: {email}")
        print(f"   Nom: {full_name}")
        print(f"   Actif: {is_active}")
        print(f"   Vérifié: {is_verified}")
        print(f"   ID: {user['_id']}")
        print("-" * 40)

client.close()