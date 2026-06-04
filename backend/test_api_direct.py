# test_api_direct.py
import requests
import json

print("🧪 TEST API DIRECT")
print("=" * 50)

# Données de connexion
login_data = {
    "email": "admin@agria.com",
    "password": "Admin123!"
}

print(f"📤 Envoi de la requête à http://localhost:8000/api/login")
print(f"   Body: {login_data}")

try:
    response = requests.post(
        "http://localhost:8000/api/login",
        json=login_data,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"\n📥 Réponse:")
    print(f"   Status: {response.status_code}")
    print(f"   Headers: {dict(response.headers)}")
    print(f"   Body: {response.text}")
    
    if response.status_code == 200:
        print("\n✅ CONNEXION RÉUSSIE !")
        data = response.json()
        print(f"   Token: {data.get('access_token', 'N/A')[:50]}...")
        print(f"   User: {data.get('user', {})}")
    else:
        print("\n❌ CONNEXION ÉCHOUÉE")
        
except requests.exceptions.ConnectionError:
    print("\n❌ Impossible de se connecter au backend")
    print("   Vérifiez que le backend tourne sur http://localhost:8000")
except Exception as e:
    print(f"\n❌ Erreur: {e}")

print("\n" + "=" * 50)