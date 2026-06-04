# clear_all_users.py
from pymongo import MongoClient

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("=" * 50)
print("🗑️ SUPPRESSION DE TOUS LES UTILISATEURS")
print("=" * 50)

# Compter avant
count_before = db.users.count_documents({})
print(f"📊 Utilisateurs avant suppression: {count_before}")

# Supprimer tous
result = db.users.delete_many({})
print(f"✅ {result.deleted_count} utilisateur(s) supprimé(s)")

# Vérifier après
count_after = db.users.count_documents({})
print(f"📊 Utilisateurs après suppression: {count_after}")

# Supprimer aussi la collection admins si elle existe
if 'admins' in db.list_collection_names():
    db.admins.drop()
    print("✅ Collection 'admins' supprimée")

if 'messages' in db.list_collection_names():
    db.messages.drop()
    print("✅ Collection 'messages' supprimée")

if 'aide' in db.list_collection_names():
    db.aide.drop()
    print("✅ Collection 'aide' supprimée")

client.close()
print("\n✅ Nettoyage complet terminé !")