import os
from groq import Groq
from dotenv import load_dotenv

load_dotenv()
client = Groq(api_key=os.getenv("GROQ_API_KEY"))

try:
    completion = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": "Bonjour"}],
        max_tokens=50,
    )
    print("✅ Réponse :", completion.choices[0].message.content)
except Exception as e:
    print("❌ Erreur :", e)