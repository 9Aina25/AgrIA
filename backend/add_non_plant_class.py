import os
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

client = MongoClient(os.getenv("MONGO_URI", "mongodb://localhost:27017"))
db = client[os.getenv("DATABASE_NAME", "agria")]
maladies_col = db["maladies"]

# Ajouter la classe "Non plante"
non_plant_data = {
    "class_name": "Non_plant",
    "nom": "Ce n'est pas une plante",
    "nom_fr": "Ce n'est pas une plante",
    "description": "L'image que vous avez envoyée ne semble pas être une plante. Veuillez prendre une photo d'une feuille de plante.",
    "description_fr": "L'image que vous avez envoyée ne semble pas être une plante. Veuillez prendre une photo d'une feuille de plante.",
    "symptomes": [],
    "symptomes_fr": [],
    "traitements": [],
    "traitements_fr": [],
    "conseils_arrosage": "",
    "conseils_arrosage_fr": "",
    "conseils_fertilisation": "",
    "conseils_fertilisation_fr": "",
    "prevention": [],
    "prevention_fr": [],
    "categorie": "Non plante",
    "gravite": "aucune",
    "gravite_fr": "aucune"
}

# Vérifier si la classe existe déjà
existing = maladies_col.find_one({"class_name": "Non_plant"})
if existing:
    maladies_col.update_one({"class_name": "Non_plant"}, {"$set": non_plant_data})
    print("✅ Classe 'Non_plant' mise à jour")
else:
    maladies_col.insert_one(non_plant_data)
    print("✅ Classe 'Non_plant' ajoutée")

print("Terminé !")