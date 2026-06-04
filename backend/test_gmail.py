# test_gmail.py
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

print("📧 TEST GMAIL COMPLET")
print("=" * 50)

# Configuration
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
EMAIL = "9aina25@gmail.com"
PASSWORD = "babpumdmvsptqfts"  # Votre mot de passe d'application (sans espaces)

# 1. Test de connexion
print("1. Test de connexion au serveur SMTP...")
try:
    server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
    server.starttls()
    print("   ✅ Connexion TLS établie")
except Exception as e:
    print(f"   ❌ Erreur connexion: {e}")
    exit()

# 2. Test d'authentification
print("\n2. Test d'authentification...")
try:
    server.login(EMAIL, PASSWORD)
    print("   ✅ Authentification réussie")
except Exception as e:
    print(f"   ❌ Erreur auth: {e}")
    print("\n   Solutions possibles:")
    print("   - Vérifiez que la validation à 2 étapes est activée")
    print("   - Générez un NOUVEAU mot de passe d'application")
    print("   - Allez sur: https://myaccount.google.com/apppasswords")
    server.quit()
    exit()

# 3. Test d'envoi d'email
print("\n3. Test d'envoi d'email...")
try:
    msg = MIMEMultipart()
    msg['From'] = EMAIL
    msg['To'] = EMAIL  # Envoi à soi-même
    msg['Subject'] = "Test AgrIA - Validation"
    
    body = """
    Test d'envoi d'email depuis AgrIA.
    Si vous recevez ce message, la configuration SMTP fonctionne !
    """
    msg.attach(MIMEText(body, 'plain'))
    
    server.send_message(msg)
    print("   ✅ Email envoyé avec succès !")
    print(f"   📨 Vérifiez votre boîte : {EMAIL}")
    
except Exception as e:
    print(f"   ❌ Erreur envoi: {e}")

# 4. Fermeture
server.quit()
print("\n" + "=" * 50)