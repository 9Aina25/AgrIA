import json
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

# Connexion MongoDB
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "agria")

client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]
maladies_col = db["maladies"]

# Charger les données du fichier JSON
with open('tomato_diseases_full.json', 'r', encoding='utf-8') as f:
    diseases_data = json.load(f)

print(f"📊 {len(diseases_data)} maladies trouvées dans le fichier")

# Compter avant import
before_count = maladies_col.count_documents({})
print(f"📊 Avant import: {before_count} documents")

# Mettre à jour ou insérer chaque maladie
for class_name, disease_info in diseases_data.items():
    # Ajouter le class_name dans le document
    disease_info["class_name"] = class_name
    
    result = maladies_col.update_one(
        {"class_name": class_name},
        {"$set": disease_info},
        upsert=True
    )
    if result.upserted_id:
        print(f"   ✅ {class_name} - ajouté")
    else:
        print(f"   ✅ {class_name} - mis à jour")

# Compter après import
after_count = maladies_col.count_documents({})
print(f"\n📊 Après import: {after_count} documents")
print(f"✅ Import terminé !")