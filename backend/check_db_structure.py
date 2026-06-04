# check_db_structure.py
from pymongo import MongoClient

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("🔍 STRUCTURE DE LA BASE DE DONNÉES")
print("=" * 50)

# Vérifier les collections
print(f"\n📚 Collections disponibles: {db.list_collection_names()}")

# Vérifier un utilisateur s'il existe
user = db.users.find_one()
if user:
    print(f"\n👤 Structure d'un utilisateur:")
    print(f"   Champs: {list(user.keys())}")
    print(f"\n   Contenu:")
    for key, value in user.items():
        if key != '_id':
            print(f"   - {key}: {type(value).__name__} = {str(value)[:50]}")
else:
    print("\n❌ Aucun utilisateur trouvé dans la base")

client.close()