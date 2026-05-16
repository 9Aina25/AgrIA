from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from datetime import datetime
import os
import json
from tensorflow.keras.models import load_model

# Configuration logs
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Import des modules
from config.settings import settings
from database.mongodb import db
from services.diagnosis_service import diagnosis_service
from routes.auth import router as auth_router
from routes.diagnosis import router as diagnosis_router
from routes.diseases import router as diseases_router
from routes.historique import router as historique_router
from routes.user import router as user_router
from routes.plants import router as plants_router
from routes.journal import router as journal_router
from routes.password_reset import router as password_reset_router

# Création de l'application
app = FastAPI(
    title="AgrIA API",
    description="Assistant IA pour diagnostic des maladies des plantes",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclusion des routes
app.include_router(auth_router)
app.include_router(diagnosis_router)
app.include_router(diseases_router)
app.include_router(historique_router)
app.include_router(user_router)
app.include_router(plants_router)
app.include_router(journal_router)
app.include_router(password_reset_router)

# Variables globales pour le modèle
model = None
CLASS_NAMES = []

# Chargement du modèle
MODEL_PATH = "tomato_11classes_final.keras"
CLASSES_PATH = "classes.json"

if os.path.exists(MODEL_PATH) and os.path.exists(CLASSES_PATH):
    try:
        model = load_model(MODEL_PATH)
        with open(CLASSES_PATH, 'r') as f:
            CLASS_NAMES = json.load(f)
        logger.info(f"✅ Modèle chargé depuis {MODEL_PATH} avec {len(CLASS_NAMES)} classes")
    except Exception as e:
        logger.error(f"❌ Erreur chargement modèle: {e}")
        model = None
        CLASS_NAMES = []
else:
    logger.warning(f"⚠️ Modèle ou classes.json introuvable")
    model = None
    CLASS_NAMES = []

# Rendre le modèle disponible pour les routes
app.state.model = model
app.state.class_names = CLASS_NAMES

# Routes de base
@app.get("/")
def root():
    return {
        "message": "AgrIA API prête",
        "version": "1.0.0",
        "status": "online",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 Démarrage du serveur AgrIA...")
    if model is not None:
        logger.info(f"✅ Modèle IA chargé: {len(CLASS_NAMES)} classes")
    else:
        logger.warning("⚠️ Mode dégradé: modèle IA non disponible")
    logger.info("✅ Serveur prêt")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("🛑 Arrêt du serveur AgrIA")
    db.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True
    )