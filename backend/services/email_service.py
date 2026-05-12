import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from config.settings import settings
import logging

logger = logging.getLogger(__name__)

class EmailService:
    
    @staticmethod
    def _send_email(to_email: str, subject: str, html_content: str):
        try:
            msg = MIMEMultipart('alternative')
            msg['From'] = settings.SMTP_USER
            msg['To'] = to_email
            msg['Subject'] = subject
            
            html_part = MIMEText(html_content, 'html')
            msg.attach(html_part)
            
            with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
                server.starttls()
                server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                server.send_message(msg)
            
            logger.info(f"Email envoyé à {to_email}")
            return True
        except Exception as e:
            logger.error(f"Erreur envoi email: {e}")
            return False
    
    @staticmethod
    def send_welcome_email(user_email: str, user_name: str):
        subject = "🌿 Bienvenue sur AgrIA !"
        html = f"""
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"></head>
        <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
            <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden;">
                <div style="background-color: #2ECC71; padding: 30px; text-align: center;">
                    <h1 style="color: white; margin: 0;">🌿 AgrIA</h1>
                    <p style="color: white; margin: 10px 0 0;">Assistant IA pour plantes</p>
                </div>
                <div style="padding: 30px;">
                    <h2>Bonjour {user_name},</h2>
                    <p>Merci de vous être inscrit sur <strong>AgrIA</strong> !</p>
                    <p>Notre intelligence artificielle est prête à vous aider à diagnostiquer vos plantes et à protéger vos cultures.</p>
                    <p>🌱 <strong>Ce que vous pouvez faire :</strong></p>
                    <ul>
                        <li>📸 Diagnostiquer vos plantes par photo</li>
                        <li>💊 Obtenir des traitements adaptés</li>
                        <li>📊 Suivre l'historique de vos diagnostics</li>
                        <li>🎓 Apprendre avec nos quiz</li>
                        <li>📝 Tenir un journal de bord</li>
                    </ul>
                    <a href="https://agria.com/app" style="background-color: #2ECC71; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin-top: 10px;">✨ Commencer maintenant</a>
                </div>
                <div style="background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 12px; color: #666;">
                    AgrIA - Votre assistant agricole intelligent<br>
                    Cet email a été envoyé automatiquement, merci de ne pas y répondre.
                </div>
            </div>
        </body>
        </html>
        """
        return EmailService._send_email(user_email, subject, html)
    
    @staticmethod
    def send_diagnosis_email(user_email: str, user_name: str, diagnosis_result: dict):
        disease_name = diagnosis_result.get("details", {}).get("nom", "Maladie inconnue")
        confidence = diagnosis_result.get("confidence", 0)
        
        subject = f"🔬 Diagnostic AgrIA - {disease_name}"
        html = f"""
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"></head>
        <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
            <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden;">
                <div style="background-color: #2ECC71; padding: 30px; text-align: center;">
                    <h1 style="color: white; margin: 0;">🔬 Résultat du diagnostic</h1>
                </div>
                <div style="padding: 30px;">
                    <h2>Bonjour {user_name},</h2>
                    <p>Voici le diagnostic de votre plante :</p>
                    <div style="background-color: #f8f8f8; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <p><strong>🪴 Maladie détectée :</strong> {disease_name}</p>
                        <p><strong>🎯 Confiance :</strong> {confidence}%</p>
                    </div>
                    <a href="https://agria.com/app" style="background-color: #2ECC71; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">📱 Voir dans l'application</a>
                </div>
                <div style="background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 12px; color: #666;">
                    AgrIA - Diagnostic automatique par IA
                </div>
            </div>
        </body>
        </html>
        """
        return EmailService._send_email(user_email, subject, html)