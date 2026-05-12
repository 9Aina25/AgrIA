import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database.mongodb import db

# Liste complète des 38 classes (ordre exact du modèle)
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

# Données enrichies pour certaines maladies
ENRICHED_DISEASES = {
    "Tomato___Early_blight": {
        "nom": "Mildiou précoce de la tomate",
        "nom_scientifique": "Alternaria solani",
        "description": "Maladie fongique qui attaque les feuilles, tiges et fruits. Se développe en conditions chaudes et humides.",
        "symptomes": ["Taches brunes concentriques", "Jaunissement", "Chute des feuilles"],
        "traitements": [
            {"type": "chimique", "titre": "Chlorothalonil", "description": "Pulvériser tous les 7 jours", "icone": "🧴"},
            {"type": "biologique", "titre": "Purins de prêle", "description": "Application hebdomadaire", "icone": "🌿"}
        ],
        "conseils_arrosage": "Arroser au pied le matin",
        "conseils_fertilisation": "Éviter excès d'azote",
        "prevention": ["Rotation des cultures", "Variétés résistantes"],
        "gravite": "élevée"
    },
    "Tomato___healthy": {
        "nom": "Tomate saine",
        "description": "Aucune maladie détectée. Plante en bonne santé.",
        "symptomes": [],
        "traitements": [],
        "conseils_arrosage": "Arrosage régulier modéré",
        "conseils_fertilisation": "Compost mensuel",
        "prevention": ["Surveillance régulière"],
        "gravite": "aucune"
    }
}

def import_maladies():
    # Supprimer les anciennes données
    db.maladies.delete_many({})
    
    maladies_data = []
    for class_name in CLASS_NAMES:
        if class_name in ENRICHED_DISEASES:
            data = ENRICHED_DISEASES[class_name].copy()
            data["class_name"] = class_name
        else:
            data = {
                "class_name": class_name,
                "nom": class_name.replace("_", " "),
                "nom_scientifique": "",
                "description": "Information à compléter",
                "symptomes": [],
                "traitements": [],
                "conseils_arrosage": "",
                "conseils_fertilisation": "",
                "prevention": [],
                "categorie": "Non classée",
                "gravite": "modérée"
            }
        maladies_data.append(data)
    
    result = db.maladies.insert_many(maladies_data)
    print(f"✅ {len(result.inserted_ids)} maladies importées")
    
    # Créer l'index
    db.maladies.create_index("class_name", unique=True)

if __name__ == "__main__":
    import_maladies()