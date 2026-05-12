# reset_user.py
from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017")
db = client["agria"]

# Supprimer tous les utilisateurs
result = db.users.delete_many({})
print(f"✅ {result.deleted_count} utilisateurs supprimés")

# Vérifier
print(f"Utilisateurs restants: {db.users.count_documents({})}")