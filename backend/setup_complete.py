# setup_complete.py - Tout en un
from pymongo import MongoClient
from datetime import datetime
import bcrypt

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("🚀 CONFIGURATION COMPLETE D'AGRIA")
print("=" * 60)

# 1. Supprimer tous les utilisateurs
print("\n1. Suppression des utilisateurs existants...")
count = db.users.count_documents({})
db.users.delete_many({})
print(f"   ✅ {count} utilisateur(s) supprimé(s)")

# 2. Créer l'admin
print("\n2. Création de l'administrateur...")
admin_data = {
    'email': 'admin@agria.com',
    'full_name': 'Administrateur AgrIA',
    'password': bcrypt.hashpw('Admin123!'.encode('utf-8'), bcrypt.gensalt()),
    'is_active': True,
    'is_email_verified': True,
    'is_admin': True,
    'role': 'super_admin',
    'created_at': datetime.utcnow()
}
db.users.insert_one(admin_data)
print(f"   ✅ Admin créé: admin@agria.com / Admin123!")

# 3. Créer la FAQ
print("\n3. Création de la section Aide...")
if 'aide' in db.list_collection_names():
    db.aide.drop()
faq_data = [
    {'question': 'Comment utiliser l\'assistant IA ?', 'reponse': 'Prenez une photo de votre plante...', 'category': 'utilisation', 'order': 1},
    {'question': 'Quelles plantes sont supportées ?', 'reponse': 'Tomates, pommes de terre, poivrons...', 'category': 'plantes', 'order': 2},
]
db.aide.insert_many(faq_data)
print(f"   ✅ {len(faq_data)} questions/réponses ajoutées")

# 4. Créer les messages
print("\n4. Création des messages système...")
if 'messages' in db.list_collection_names():
    db.messages.drop()
msg_data = [
    {'type': 'welcome', 'title': 'Bienvenue', 'content': 'Bienvenue sur AgrIA', 'active': True},
]
db.messages.insert_many(msg_data)
print(f"   ✅ {len(msg_data)} messages ajoutés")

# 5. Résumé
print("\n" + "=" * 60)
print("✅ CONFIGURATION TERMINÉE !")
print("=" * 60)
print("\n📊 RÉSUMÉ:")
print(f"   👥 Utilisateurs: {db.users.count_documents({})}")
print(f"   📚 FAQ: {db.aide.count_documents({})}")
print(f"   💬 Messages: {db.messages.count_documents({})}")
print("\n👑 ACCÈS ADMIN:")
print("   📧 Email: admin@agria.com")
print("   🔑 Mot de passe: Admin123!")
print("\n⚠️  Gardez ces identifiants en sécurité !")

client.close()