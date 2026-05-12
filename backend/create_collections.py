# create_collections.py
from pymongo import MongoClient

# Connexion à MongoDB
client = MongoClient("mongodb://localhost:27017")
db = client["agria"]

print("📁 Connexion à MongoDB établie")
print(f"Base de données: {db.name}")

# Lister les collections existantes
existing_collections = db.list_collection_names()
print(f"Collections existantes: {existing_collections}")

# Créer les collections manquantes
collections_to_create = ["historique", "notifications", "plants"]

for col_name in collections_to_create:
    if col_name not in existing_collections:
        db.create_collection(col_name)
        print(f"✅ Collection '{col_name}' créée")
    else:
        print(f"⚠️ Collection '{col_name}' existe déjà")

# Vérification finale
print("\n📋 Collections finales:", db.list_collection_names())

# Ajouter quelques index pour les performances
db.historique.create_index("user_id")
db.historique.create_index("date")
db.users.create_index("email", unique=True)
db.maladies.create_index("class_name", unique=True)
db.plants.create_index("user_id")
db.notifications.create_index("user_id")

print("\n✅ Index créés avec succès")
client.close()