from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from datetime import datetime
import os
import json

# Configuration logs
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Import des modules
from config.settings import settings
from database.mongodb import db
from routes.auth import router as auth_router
from routes.diagnosis import router as diagnosis_router
from routes.diseases import router as diseases_router
from routes.historique import router as historique_router
from routes.user import router as user_router
from routes.plants import router as plants_router

# Chargement du modèle TensorFlow (unifié)
from tensorflow.keras.models import load_model

# Configuration du modèle
MODEL_PATH = "tomato_model_partial.keras"  # ou resnet50_plant_village_model.h5
CLASSES_PATH = "tomato_classes.json"

model = None
CLASS_NAMES = []

if os.path.exists(MODEL_PATH):
    try:
        model = load_model(MODEL_PATH)
        if os.path.exists(CLASSES_PATH):
            with open(CLASSES_PATH, 'r') as f:
                CLASS_NAMES = json.load(f)
        logger.info(f"✅ Modèle chargé depuis {MODEL_PATH} avec {len(CLASS_NAMES)} classes")
    except Exception as e:
        logger.error(f"❌ Erreur chargement modèle: {e}")
else:
    logger.warning(f"⚠️ Modèle introuvable: {MODEL_PATH}")

# Fonction de prétraitement (à garder pour compatibilité)
def preprocess_image(image_bytes):
    from PIL import Image
    import numpy as np
    import io
    
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((224, 224))
    img_array = np.array(img).astype(np.float32) / 255.0
    return np.expand_dims(img_array, axis=0)

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

# Exporter le modèle et les classes pour les routes
app.state.model = model
app.state.class_names = CLASS_NAMES

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True
    )