# create_aide_messages.py
from pymongo import MongoClient
from datetime import datetime

client = MongoClient('mongodb://localhost:27017')
db = client['agria']

print("=" * 50)
print("📚 CRÉATION DES COLLECTIONS AIDE ET MESSAGES")
print("=" * 50)

# Collection Aide (FAQ)
aide_data = [
    {
        'question': 'Comment utiliser l\'assistant IA ?',
        'reponse': 'Prenez une photo de votre plante, téléversez-la dans l\'application, et l\'IA identifiera les maladies possibles.',
        'category': 'utilisation',
        'order': 1,
        'created_at': datetime.utcnow()
    },
    {
        'question': 'Quelles plantes sont supportées ?',
        'reponse': 'Actuellement, l\'application supporte les tomates, pommes de terre, et poivrons. D\'autres plantes arrivent bientôt.',
        'category': 'plantes',
        'order': 2,
        'created_at': datetime.utcnow()
    },
    {
        'question': 'Comment interpréter les résultats ?',
        'reponse': 'L\'IA vous donne un diagnostic avec un niveau de confiance. Plus le pourcentage est élevé, plus le diagnostic est fiable.',
        'category': 'diagnostic',
        'order': 3,
        'created_at': datetime.utcnow()
    },
    {
        'question': 'L\'application est-elle gratuite ?',
        'reponse': 'Oui, AgrIA est entièrement gratuite pour tous les agriculteurs et jardiniers.',
        'category': 'general',
        'order': 4,
        'created_at': datetime.utcnow()
    }
]

# Supprimer l'ancienne collection aide si elle existe
if 'aide' in db.list_collection_names():
    db.aide.drop()
    print("✅ Ancienne collection 'aide' supprimée")

# Insérer les nouvelles données
result_aide = db.aide.insert_many(aide_data)
print(f"✅ {len(result_aide.inserted_ids)} questions/réponses ajoutées à 'aide'")

# Collection Messages (pour les messages système)
messages_data = [
    {
        'type': 'welcome',
        'title': 'Bienvenue sur AgrIA',
        'content': 'Votre assistant intelligent pour la détection des maladies des plantes',
        'role': 'system',
        'created_at': datetime.utcnow(),
        'active': True
    },
    {
        'type': 'info',
        'title': 'Nouveauté',
        'content': 'Le modèle IA a été mis à jour avec plus de précision',
        'role': 'system',
        'created_at': datetime.utcnow(),
        'active': True
    }
]

# Supprimer l'ancienne collection messages si elle existe
if 'messages' in db.list_collection_names():
    db.messages.drop()
    print("✅ Ancienne collection 'messages' supprimée")

# Insérer les nouvelles données
result_messages = db.messages.insert_many(messages_data)
print(f"✅ {len(result_messages.inserted_ids)} messages ajoutés à 'messages'")

# Vérification
print("\n" + "=" * 50)
print("📊 VÉRIFICATION FINALE")
print("=" * 50)

print(f"📚 Collection aide: {db.aide.count_documents({})} documents")
print(f"💬 Collection messages: {db.messages.count_documents({})} documents")
print(f"👥 Collection users: {db.users.count_documents({})} utilisateurs")

# Afficher l'admin
admin = db.users.find_one({'email': 'admin@agria.com'})
if admin:
    print(f"👑 Admin présent: {admin['email']} (actif: {admin['is_active']})")

client.close()
print("\n✅ Configuration terminée !")