# delete_users.py
from pymongo import MongoClient

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

# 1. Afficher tous les utilisateurs
print("📋 Utilisateurs dans la base :")
users = list(db.users.find({}, {'email': 1, 'full_name': 1, '_id': 0}))
for user in users:
    print(f"  - {user['email']} ({user.get('full_name', 'Pas de nom')})")

# 2. Supprimer les utilisateurs spécifiques
emails_a_supprimer = ['9Aina25@gmail.com', 'ainanatolotra925@gmail.com']
print(f"\n🗑️ Suppression des emails : {emails_a_supprimer}")

result = db.users.delete_many({
    'email': {'$in': emails_a_supprimer}
})
print(f"✅ {result.deleted_count} utilisateur(s) supprimé(s)")

# 3. Vérifier après suppression
print("\n📋 Utilisateurs restants :")
users_restants = list(db.users.find({}, {'email': 1, '_id': 0}))
for user in users_restants:
    print(f"  - {user['email']}")

client.close()