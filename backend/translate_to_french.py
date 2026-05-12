import json
import time
from deep_translator import GoogleTranslator
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

# Connexion MongoDB
client = MongoClient(os.getenv("MONGO_URI", "mongodb://localhost:27017"))
db = client[os.getenv("DATABASE_NAME", "agria")]
maladies_col = db["maladies"]

# Traducteur
translator = GoogleTranslator(source='en', target='fr')

# Liste des 38 classes
CLASS_NAMES = [
    'Pepper__bell___Bacterial_spot', 'Pepper__bell___healthy',
    'Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy',
    'Tomato___Bacterial_spot', 'Tomato___Early_blight', 'Tomato___Late_blight',
    'Tomato___Leaf_Mold', 'Tomato___Septoria_leaf_spot', 'Tomato___Spider_mites_Two-spotted_spider_mite',
    'Tomato___Target_Spot', 'Tomato___Tomato_mosaic_virus', 'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
    'Tomato___healthy', 'Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust',
    'Apple___healthy', 'Blueberry___healthy', 'Cherry___healthy', 'Cherry___Powdery_mildew',
    'Corn___Cercospora_leaf_spot Gray_leaf_spot', 'Corn___Common_rust', 'Corn___healthy',
    'Corn___Northern_Leaf_Blight', 'Grape___Black_rot', 'Grape___Esca_(Black_Measles)',
    'Grape___healthy', 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)', 'Orange___Haunglongbing_(Citrus_greening)',
    'Peach___Bacterial_spot', 'Peach___healthy', 'Raspberry___healthy', 'Soybean___healthy',
    'Squash___Powdery_mildew', 'Strawberry___healthy', 'Strawberry___Leaf_scorch'
]

# Fonction pour rendre les noms plus lisibles avant traduction
def format_name(class_name):
    parts = class_name.split('___')
    plant = parts[0].replace('_', ' ')
    disease = parts[1].replace('_', ' ') if len(parts) > 1 else "sain"
    if disease == "healthy":
        disease = "sain"
    return f"{disease} de {plant}"

# Fonction pour traduire avec gestion des erreurs
def translate_text(text):
    if not text or text == "":
        return text
    try:
        translated = translator.translate(text)
        time.sleep(0.5)  # Pause pour éviter la limitation
        return translated
    except Exception as e:
        print(f"Erreur traduction: {e}")
        return text

print("🌍 Démarrage de la traduction en français...\n")

# Mettre à jour chaque maladie
for class_name in CLASS_NAMES:
    print(f"📝 Traitement de: {class_name}")
    
    # Récupérer le document existant
    doc = maladies_col.find_one({"class_name": class_name})
    
    if doc:
        # Traduire le nom
        readable_name = format_name(class_name)
        nom_fr = translate_text(readable_name)
        
        # Traduire la description si elle existe
        old_description = doc.get("description", "")
        if old_description and old_description != "Information à compléter":
            description_fr = translate_text(old_description)
        else:
            description_fr = "Information à compléter"
        
        # Traduire les symptômes
        symptomes_fr = []
        if doc.get("symptomes"):
            for s in doc["symptomes"]:
                if s:
                    symptomes_fr.append(translate_text(s))
        
        # Traduire les traitements
        traitements_fr = []
        if doc.get("traitements"):
            for t in doc["traitements"]:
                titre_fr = translate_text(t.get("titre", ""))
                desc_fr = translate_text(t.get("description", ""))
                traitements_fr.append({
                    "type": t.get("type", ""),
                    "titre": titre_fr,
                    "description": desc_fr,
                    "icone": t.get("icone", "💊")
                })
        
        # Traduire les conseils
        conseils_arrosage_fr = translate_text(doc.get("conseils_arrosage", ""))
        conseils_fertilisation_fr = translate_text(doc.get("conseils_fertilisation", ""))
        
        # Traduire la prévention
        prevention_fr = []
        if doc.get("prevention"):
            for p in doc["prevention"]:
                if p:
                    prevention_fr.append(translate_text(p))
        
        # Mettre à jour MongoDB
        maladies_col.update_one(
            {"class_name": class_name},
            {"$set": {
                "nom_fr": nom_fr,
                "description_fr": description_fr,
                "symptomes_fr": symptomes_fr,
                "traitements_fr": traitements_fr,
                "conseils_arrosage_fr": conseils_arrosage_fr,
                "conseils_fertilisation_fr": conseils_fertilisation_fr,
                "prevention_fr": prevention_fr
            }}
        )
        
        print(f"   ✅ {class_name} → {nom_fr}")
    else:
        print(f"   ⚠️ Document non trouvé pour {class_name}")

print("\n🎉 Traduction terminée !")