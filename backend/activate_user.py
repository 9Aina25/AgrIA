# activate_user.py
from pymongo import MongoClient
import sys

def activate_user(email):
    client = MongoClient('mongodb://localhost:27017')
    db = client['agria']
    
    # Chercher l'utilisateur
    user = db.users.find_one({'email': email})
    
    if not user:
        print(f"❌ Utilisateur {email} non trouvé")
        client.close()
        return False
    
    print(f"📧 Utilisateur trouvé: {user['email']}")
    print(f"   Actif actuellement: {user.get('is_active', False)}")
    print(f"   Vérifié actuellement: {user.get('is_email_verified', False)}")
    
    # Activer
    result = db.users.update_one(
        {'email': email},
        {'$set': {
            'is_active': True,
            'is_email_verified': True
        }}
    )
    
    if result.modified_count > 0:
        print(f"\n✅ Utilisateur {email} activé avec succès!")
        
        # Vérifier
        updated = db.users.find_one({'email': email})
        print(f"   Nouveau statut: actif={updated.get('is_active')}, vérifié={updated.get('is_email_verified')}")
    else:
        print(f"\n⚠️ Aucune modification (peut-être déjà actif)")
    
    client.close()
    return True

if __name__ == "__main__":
    email = input("Entrez l'email à activer: ").strip()
    if email:
        activate_user(email)
    else:
        print("Email invalide")