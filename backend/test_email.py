# test_email.py
import smtplib
from email.mime.text import MIMEText

def test_email():
    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        
        # Nouveau mot de passe SANS espaces
        server.login("9aina25@gmail.com", "babpumdmvsptqfts")
        print("✅ Authentification SMTP réussie !")
        
        msg = MIMEText("Test réussi ! Votre email fonctionne.")
        msg["Subject"] = "Test Agria - Email fonctionnel"
        msg["From"] = "9aina25@gmail.com"
        msg["To"] = "9aina25@gmail.com"
        
        server.send_message(msg)
        print("✅ Email envoyé avec succès !")
        
        server.quit()
        return True
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

if __name__ == "__main__":
    test_email()