# populate_maladies.py
import pymongo
from pymongo import MongoClient
from config.settings import settings

client = MongoClient(settings.MONGO_URI)
db = client[settings.DATABASE_NAME]
maladies = db.maladies

# Supprimer les anciennes données (optionnel, mais faites une sauvegarde d'abord)
# maladies.delete_many({})

maladies_data = [
    {
        "class_name": "Tomato___Late_blight",
        "nom_fr": "Mildiou",
        "nom_scientifique": "Phytophthora infestans",
        "gravite_fr": "élevée",
        "description_fr": "Maladie fongique due à un excès d'humidité, provoquant des taches brunes sur les feuilles et les fruits.",
        "symptomes_fr": [
            "Taches brunes ou noires sur les feuilles, souvent entourées de jaune",
            "Duvet blanc sous les feuilles par temps humide",
            "Pourriture brune des fruits"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Rotation des cultures, arrosage au pied le matin, éviter l'humidité sur les feuilles."},
            {"titre": "Curatif", "description": "Bouillie bordelaise, fongicide à base de cuivre, retirer les parties infectées."}
        ],
        "conseils_arrosage_fr": "Arroser le matin sans mouiller les feuilles, au pied.",
        "conseils_fertilisation_fr": "Fumier bien décomposé, éviter les excès d'azote.",
        "prevention_fr": [
            "Planter des variétés résistantes",
            "Espacement suffisant des plants",
            "Paillage pour éviter les éclaboussures"
        ],
        "image_url": "https://example.com/mildiou.jpg"  # facultatif
    },
    {
        "class_name": "Tomato___Early_blight",
        "nom_fr": "Alternariose",
        "nom_scientifique": "Alternaria solani",
        "gravite_fr": "modérée",
        "description_fr": "Maladie fongique des feuilles et des tiges, caractérisée par des taches concentriques.",
        "symptomes_fr": [
            "Taches brunes avec anneaux concentriques (en cible)",
            "Jaunissement et chute des feuilles",
            "Taches sur les tiges et les fruits"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Rotation des cultures, paillage, espacement des plants."},
            {"titre": "Curatif", "description": "Fongicides à base de chlorothalonil ou cuivre, élimination des feuilles atteintes."}
        ],
        "conseils_arrosage_fr": "Arroser au pied, éviter de mouiller le feuillage.",
        "conseils_fertilisation_fr": "Éviter les excès d'azote, privilégier un sol équilibré.",
        "prevention_fr": [
            "Utiliser des semences saines",
            "Nettoyer les débris végétaux après récolte"
        ]
    },
    {
        "class_name": "Tomato___Leaf_Mold",
        "nom_fr": "Cladosporiose",
        "nom_scientifique": "Passalora fulva",
        "gravite_fr": "modérée",
        "description_fr": "Maladie fongique des feuilles, favorisée par une forte humidité.",
        "symptomes_fr": [
            "Taches jaunes sur le dessus des feuilles",
            "Moisissure olive sur le dessous",
            "Feuilles qui se dessèchent"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Aération de la serre, espacement des plants."},
            {"titre": "Curatif", "description": "Fongicides à base de soufre, réduire l'humidité."}
        ],
        "conseils_arrosage_fr": "Arroser le matin, aérer la serre.",
        "conseils_fertilisation_fr": "Éviter les excès d'azote.",
        "prevention_fr": [
            "Variétés résistantes",
            "Rotation des cultures"
        ]
    },
    {
        "class_name": "Tomato___Septoria_leaf_spot",
        "nom_fr": "Septoriose",
        "nom_scientifique": "Septoria lycopersici",
        "gravite_fr": "élevée",
        "description_fr": "Maladie fongique provoquant des taches grises sur les feuilles.",
        "symptomes_fr": [
            "Petites taches grises avec un bord brun",
            "Points noirs au centre (pycnides)",
            "Feuilles jaunissent et tombent"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Éliminer les feuilles atteintes, rotation des cultures."},
            {"titre": "Curatif", "description": "Fongicides à base de cuivre ou mancozèbe."}
        ],
        "conseils_arrosage_fr": "Arrosage au pied.",
        "conseils_fertilisation_fr": "Fertilisation équilibrée.",
        "prevention_fr": [
            "Nettoyer les outils",
            "Paillage"
        ]
    },
    {
        "class_name": "Tomato___Powdery_mildew",
        "nom_fr": "Oïdium",
        "nom_scientifique": "Leveillula taurica",
        "gravite_fr": "modérée",
        "description_fr": "Maladie fongique se manifestant par un feutrage blanc sur les feuilles.",
        "symptomes_fr": [
            "Poudre blanche sur les feuilles",
            "Feuilles se recroquevillent",
            "Croissance ralentie"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Aération, éviter l'humidité."},
            {"titre": "Curatif", "description": "Soufre mouillable, bicarbonate de soude + savon noir."}
        ],
        "conseils_arrosage_fr": "Arroser le matin, éviter l'humidité nocturne.",
        "conseils_fertilisation_fr": "Éviter excès d'azote.",
        "prevention_fr": [
            "Variétés résistantes",
            "Purin d'ortie"
        ]
    },
    {
        "class_name": "Tomato___Bacterial_spot",
        "nom_fr": "Taches bactériennes",
        "nom_scientifique": "Xanthomonas campestris",
        "gravite_fr": "élevée",
        "description_fr": "Maladie bactérienne provoquant des taches huileuses sur les feuilles et les fruits.",
        "symptomes_fr": [
            "Petites taches brunes cerclées de jaune",
            "Taches sur les fruits",
            "Défoliation"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Utiliser des semences saines."},
            {"titre": "Curatif", "description": "Bouillie bordelaise, éliminer les plants infectés."}
        ],
        "conseils_arrosage_fr": "Arrosage au pied, éviter le stress hydrique.",
        "conseils_fertilisation_fr": "Éviter les excès d'azote.",
        "prevention_fr": [
            "Rotation des cultures",
            "Désinfection des outils"
        ]
    },
    {
        "class_name": "Tomato___Tomato_mosaic_virus",
        "nom_fr": "Virus de la mosaïque",
        "nom_scientifique": "Tomato mosaic virus (ToMV)",
        "gravite_fr": "modérée",
        "description_fr": "Virus provoquant une mosaïque jaune-vert sur les feuilles.",
        "symptomes_fr": [
            "Mosaïque jaune-vert sur les feuilles",
            "Feuilles recroquevillées",
            "Fruits petits et déformés"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Variétés résistantes, désinfection des outils."},
            {"titre": "Curatif", "description": "Aucun traitement curatif, arracher les plants infectés."}
        ],
        "conseils_arrosage_fr": "Normal.",
        "conseils_fertilisation_fr": "Fertilisation équilibrée.",
        "prevention_fr": [
            "Utiliser des semences certifiées",
            "Lavage des mains"
        ]
    },
    {
        "class_name": "Tomato___Spider_mites",
        "nom_fr": "Araignée rouge",
        "nom_scientifique": "Tetranychus urticae",
        "gravite_fr": "modérée",
        "description_fr": "Acarien provoquant des décolorations et des toiles fines.",
        "symptomes_fr": [
            "Petites taches jaunes (ponctuations)",
            "Toiles fines sur les feuilles",
            "Feuilles desséchées"
        ],
        "traitements_fr": [
            {"titre": "Préventif", "description": "Maintenir une humidité élevée, introduire des prédateurs (phytoseiulus)."},
            {"titre": "Curatif", "description": "Savon noir, huile de neem, acaricides."}
        ],
        "conseils_arrosage_fr": "Brunnir le feuillage pour augmenter l'humidité.",
        "conseils_fertilisation_fr": "Éviter les excès d'azote.",
        "prevention_fr": [
            "Purin d'ortie",
            "Rotation des cultures"
        ]
    },
    {
        "class_name": "Tomato___Nitrogen_deficiency",
        "nom_fr": "Carence en azote",
        "nom_scientifique": "Déséquilibre nutritionnel",
        "gravite_fr": "faible",
        "description_fr": "Carence en azote, commune dans les sols pauvres.",
        "symptomes_fr": [
            "Feuilles jaunissent (commençant par les vieilles)",
            "Croissance ralentie",
            "Petits fruits"
        ],
        "traitements_fr": [
            {"titre": "Curatif", "description": "Apport d'engrais azoté (purin d'ortie, fumier)."}
        ],
        "conseils_arrosage_fr": "Normal.",
        "conseils_fertilisation_fr": "Apport régulier d'engrais organique riche en azote.",
        "prevention_fr": [
            "Analyser le sol",
            "Rotation des cultures"
        ]
    },
    {
        "class_name": "Tomato___Tomato_healthy",
        "nom_fr": "Tomate saine",
        "nom_scientifique": "",
        "gravite_fr": "aucune",
        "description_fr": "Plante en bonne santé, aucun symptôme.",
        "symptomes_fr": [],
        "traitements_fr": [],
        "conseils_arrosage_fr": "Arrosage régulier.",
        "conseils_fertilisation_fr": "Fertilisation équilibrée.",
        "prevention_fr": [
            "Entretien régulier"
        ]
    }
]

for data in maladies_data:
    # Vérifier si la maladie existe déjà par class_name
    existing = maladies.find_one({"class_name": data["class_name"]})
    if existing:
        print(f"Mise à jour de {data['class_name']}")
        maladies.update_one({"_id": existing["_id"]}, {"$set": data})
    else:
        print(f"Insertion de {data['class_name']}")
        maladies.insert_one(data)

print("✅ Données des maladies mises à jour avec succès.")
client.close()