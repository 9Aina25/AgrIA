import os
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

client = MongoClient(os.getenv("MONGO_URI", "mongodb://localhost:27017"))
db = client[os.getenv("DATABASE_NAME", "agria")]
maladies_col = db["maladies"]

# Données enrichies pour toutes les maladies
diseases_data = {
    "Tomato___Early_blight": {
        "nom_fr": "Mildiou précoce de la tomate",
        "description_fr": "Maladie fongique très commune causée par Alternaria solani. Elle apparaît sur les feuilles inférieures sous forme de taches brunes concentriques, puis progresse vers le haut de la plante. Les taches peuvent atteindre 1-2 cm de diamètre. Le champignon se développe particulièrement par temps frais et humide (15-25°C).\n\n⚠️ Cette maladie peut entraîner une perte de rendement allant jusqu'à 80% si elle n'est pas traitée rapidement.",
        "symptomes_fr": [
            "🔴 Taches brunes concentriques sur les feuilles (forme d'œil de grenouille)",
            "🔴 Jaunissement progressif du feuillage",
            "🔴 Chute prématurée des feuilles (défoliation)",
            "🔴 Taches nécrotiques sur les tiges",
            "🔴 Fruits avec des taches déprimées autour du pédoncule"
        ],
        "traitements_fr": [
            {"type": "chimique", "titre": "🍄 Fongicide à base de chlorothalonil", "description": "Appliquez tous les 7-10 jours dès l'apparition des premiers symptômes. Respectez une dose de 2g/L d'eau. Traitez le matin ou le soir pour éviter les brûlures."},
            {"type": "biologique", "titre": "🌿 Purin de prêle", "description": "Pulvérisez une solution de purin de prêle diluée à 10% tous les 5 jours. Ce traitement renforce les défenses naturelles de la plante."},
            {"type": "cultural", "titre": "✂️ Élimination des parties infectées", "description": "Retirez et brûlez les feuilles et tiges infectées. Ne les mettez pas au compost pour éviter la propagation du champignon."}
        ],
        "conseils_arrosage_fr": "💧 Arrosez uniquement au pied des plants, de préférence le matin. Évitez absolument de mouiller le feuillage, car l'humidité favorise le développement du champignon. Le paillage du sol permet de réduire les éclaboussures d'eau. Un arrosage par goutte-à-goutte est idéal.",
        "conseils_fertilisation_fr": "🌱 Utilisez un engrais équilibré NPK 10-10-10. Réduisez les apports d'azote en excès qui rendent la plante plus sensible. Privilégiez un apport de potassium pour renforcer les tissus végétaux.",
        "prevention_fr": [
            "🔄 Rotation des cultures sur 3-4 ans (ne replantez pas de solanacées)",
            "📏 Espacement suffisant entre les plants (50-60 cm pour favoriser l'aération)",
            "🌾 Utilisation de variétés résistantes (ex: 'Mountain Magic', 'Jasper')",
            "🧹 Nettoyage des résidus de culture en fin de saison",
            "🛡️ Traitements préventifs à base de cuivre avant les périodes pluvieuses"
        ],
        "gravite_fr": "élevée"
    },
    
    "Tomato___healthy": {
        "nom_fr": "Tomate saine",
        "description_fr": "Félicitations ! Votre plante ne présente aucun signe de maladie visible. Elle semble vigoureuse et en bonne santé.\n\nContinuez vos bonnes pratiques culturales pour maintenir cette bonne santé.",
        "symptomes_fr": ["✅ Aucun symptôme de maladie détecté", "✅ Feuilles vertes et vigoureuses", "✅ Tiges solides"],
        "traitements_fr": [
            {"type": "preventif", "titre": "🌿 Entretien régulier", "description": "Continuez à surveiller votre plante régulièrement pour détecter l'apparition précoce d'éventuels problèmes."}
        ],
        "conseils_arrosage_fr": "💧 Maintenez un arrosage régulier mais modéré. Arrosez au pied le matin, en évitant les excès. Un sol constamment détrempé peut favoriser le pourrissement des racines.",
        "conseils_fertilisation_fr": "🌱 Apportez du compost ou un engrais organique une fois par mois. Au printemps, un engrais riche en azote favorise la croissance, puis un engrais riche en potassium et phosphore pour la floraison et la fructification.",
        "prevention_fr": [
            "🔍 Inspectez vos plantes régulièrement (1 à 2 fois par semaine)",
            "💨 Maintenez une bonne aération en espaçant les plants",
            "🍂 Retirez les feuilles jaunies et les mauvaises herbes",
            "🛡️ Appliquez un purin d'ortie préventif une fois par mois"
        ],
        "gravite_fr": "aucune"
    },
    
    "Strawberry___Leaf_scorch": {
        "nom_fr": "Brûlure des feuilles du fraisier",
        "description_fr": "Maladie fongique causée par Diplocarpon earlianum. Elle se caractérise par l'apparition de petites taches pourpres-violet sur les feuilles, qui s'agrandissent et fusionnent. Les zones touchées deviennent nécrotiques, donnant à la feuille un aspect brûlé.\n\n⚠️ Cette maladie réduit la capacité photosynthétique et peut affaiblir la plante, réduisant la production de fruits.",
        "symptomes_fr": [
            "🟣 Petites taches pourpres-violet sur le dessus des feuilles (1-3 mm)",
            "🟣 Fusion des taches en grandes zones nécrotiques",
            "🟣 Brunissement et dessèchement des bords des feuilles",
            "🟣 Feuilles qui s'enroulent et se dessèchent",
            "🍓 Réduction de la taille et de la qualité des fraises"
        ],
        "traitements_fr": [
            {"type": "chimique", "titre": "🧪 Fongicide à base de cuivre", "description": "Pulvérisez une solution de bouillie bordelaise à 1-2% dès l'apparition des premiers symptômes. Renouvelez l'application tous les 10-14 jours. Évitez par temps pluvieux."},
            {"type": "biologique", "titre": "🌿 Purin de consoude", "description": "Appliquez une solution de purin de consoude diluée à 10% chaque semaine. Riche en potassium, il renforce les tissus et limite la progression de la maladie."},
            {"type": "cultural", "titre": "✂️ Suppression des feuilles touchées", "description": "Retirez et éliminez les feuilles infectées. Désinfectez vos outils entre chaque coupe pour ne pas propager la maladie."}
        ],
        "conseils_arrosage_fr": "💧 Arrosez toujours au pied du plant, sans mouiller les feuilles. Un arrosage le matin est préférable pour que les feuilles sèchent rapidement. Utilisez un paillage pour éviter les éclaboussures et maintenir une humidité constante.",
        "conseils_fertilisation_fr": "🌱 Fertilisation équilibrée avec un apport légèrement plus élevé en potassium (K). Évitez les excès d'azote qui rendent les plantes plus sensibles. Un bon ratio est NPK 5-10-10 pour les fraisiers.",
        "prevention_fr": [
            "🌬️ Plantez en rangs espacés pour favoriser la circulation de l'air",
            "🍂 Éliminez les vieilles feuilles après la récolte",
            "🔄 Rotation des cultures (ne replantez pas de fraisiers au même endroit avant 3-4 ans)",
            "🌾 Choisissez des variétés résistantes (ex: 'Elsanta', 'Darselect')",
            "🧹 Nettoyez soigneusement le sol en fin de saison"
        ],
        "gravite_fr": "élevée"
    },
    
    "Strawberry___healthy": {
        "nom_fr": "Fraisier sain",
        "description_fr": "Votre fraisier semble en excellente santé ! Aucun signe de maladie ou de carence n'a été détecté.\n\nContinuez vos soins pour obtenir de belles fraises sucrées.",
        "symptomes_fr": ["✅ Feuilles vertes et brillantes", "✅ Plante vigoureuse", "✅ Bon développement des stolons"],
        "traitements_fr": [{"type": "preventif", "titre": "🌿 Entretien", "description": "Maintenez vos bonnes habitudes culturales."}],
        "conseils_arrosage_fr": "💧 Arrosage régulier sans excès. Le paillage est recommandé pour protéger les fruits du contact avec le sol.",
        "conseils_fertilisation_fr": "🌱 Apportez un engrais spécial fraisiers riche en potassium pendant la floraison.",
        "prevention_fr": ["🔍 Surveillance régulière", "🍂 Suppression des stolons superflus", "🌾 Paillage"],
        "gravite_fr": "aucune"
    },
    
    "Potato___Early_blight": {
        "nom_fr": "Mildiou précoce de la pomme de terre",
        "description_fr": "Maladie fongique causée par Alternaria solani, très répandue dans les cultures de pomme de terre. Les premières lésions apparaissent sur les feuilles âgées sous forme de taches brunes concentriques.\n\n⚠️ Cette maladie peut entraîner un flétrissement prématuré et une réduction significative du rendement (10-40%).",
        "symptomes_fr": [
            "🟤 Taches brunes angulaires sur les feuilles",
            "🟤 Cercles concentriques caractéristiques",
            "🟤 Jaunissement du feuillage autour des taches",
            "🟤 Taches allongées sur les tiges",
            "🥔 Tubercules peuvent présenter des taches brunes et une pourriture"
        ],
        "traitements_fr": [
            {"type": "chimique", "titre": "🧪 Mancozèbe", "description": "Appliquez un fongicide à base de mancozèbe tous les 7-10 jours. Dose : 2g/L d'eau. Traitez préventivement en période de risque."},
            {"type": "biologique", "titre": "🌿 Purin d'ortie", "description": "Pulvérisez du purin d'ortie dilué à 10% sur le feuillage. Renouvelez tous les 5 jours. Action répulsive et stimulante."}
        ],
        "conseils_arrosage_fr": "💧 Évitez les arrosages fréquents et légers qui favorisent le développement du champignon. Préférez des arrosages plus espacés mais plus abondants, au pied des plants.",
        "conseils_fertilisation_fr": "🌱 Maintenez une bonne nutrition en potassium et phosphore. Réduisez l'azote qui favorise le feuillage dense et l'humidité.",
        "prevention_fr": [
            "🔄 Rotation longue (4-5 ans) avec des non-solanacées",
            "🌾 Utilisation de tubercules certifiés",
            "💨 Buttage pour protéger les tubercules",
            "🪓 Suppression des pieds infectés"
        ],
        "gravite_fr": "élevée"
    },
    
    "Potato___healthy": {
        "nom_fr": "Pomme de terre saine",
        "description_fr": "Votre plant de pomme de terre ne présente aucun signe de maladie. Le feuillage est vert et bien développé, les tiges sont robustes.",
        "symptomes_fr": ["✅ Feuillage vert et vigoureux", "✅ Tiges robustes", "✅ Bonne croissance"],
        "traitements_fr": [{"type": "preventif", "titre": "🌿 Entretien", "description": "Maintenez vos bonnes pratiques."}],
        "conseils_arrosage_fr": "💧 Arrosage régulier mais modéré. Plus important pendant la formation des tubercules.",
        "conseils_fertilisation_fr": "🌱 Fertilisation riche en potassium pour les tubercules.",
        "prevention_fr": ["🔄 Rotation", "🪓 Surveillance", "🌾 Utilisation de plants certifiés"],
        "gravite_fr": "aucune"
    },

    "Non_plant": {
        "nom_fr": "❌ Ce n'est pas une plante",
        "description_fr": "L'image que vous avez envoyée ne semble pas être une plante ou une feuille de plante.\n\nPour utiliser AgrIA, veuillez prendre une photo claire d'une feuille de plante. Idéalement :\n- Cadrez bien la feuille\n- Évitez les ombres\n- Assurez-vous que la feuille est bien éclairée\n\nEssayez à nouveau avec une photo de feuille de plante !",
        "symptomes_fr": [
            "⚠️ Image non identifiée comme une plante",
            "📷 Photo floue ou mal cadrée",
            "🔍 Objet non végétal détecté"
        ],
        "traitements_fr": [
            {"type": "conseil", "titre": "📸 Refaire la photo", "description": "Prenez une nouvelle photo en suivant ces conseils : cadrez bien une feuille, assurez un bon éclairage, tenez l'appareil stable."},
            {"type": "conseil", "titre": "🌿 Préparer un échantillon", "description": "Pour un diagnostic précis, utilisez une feuille fraîche, sans saleté, et photographiez-la sur un fond uni."}
        ],
        "conseils_arrosage_fr": "",
        "conseils_fertilisation_fr": "",
        "prevention_fr": [
            "📸 Vérifiez que votre photo montre bien une feuille de plante",
            "🔍 Assurez-vous que la plante est au centre du cadre",
            "💡 Privilégiez la lumière naturelle pour les photos"
        ],
        "gravite_fr": "aucune"
    }
}

# Mettre à jour les maladies
for class_name, data in diseases_data.items():
    result = maladies_col.update_one(
        {"class_name": class_name},
        {"$set": data}
    )
    if result.modified_count > 0:
        print(f"✅ {class_name} mis à jour")
    else:
        print(f"⚠️ {class_name} : aucune modification")

print("\n🎉 Enrichissement terminé !")