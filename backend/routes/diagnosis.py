from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Request
from database.mongodb import db
from middleware.auth import get_current_user
from datetime import datetime
import logging
import numpy as np
from PIL import Image
import io

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api", tags=["Diagnosis"])

def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((128, 128))
    img_array = np.array(img).astype(np.float32) / 255.0
    return np.expand_dims(img_array, axis=0)

@router.post("/diagnose")
async def diagnose(
    request: Request,
    file: UploadFile = File(...),
    current_user = Depends(get_current_user)
):
    model = request.app.state.model
    class_names = request.app.state.class_names
    
    if model is None:
        raise HTTPException(status_code=503, detail="Modèle IA non disponible")
    
    try:
        contents = await file.read()
        input_tensor = preprocess_image(contents)
        predictions = model.predict(input_tensor)[0]
        predicted_idx = int(np.argmax(predictions))
        confidence = float(predictions[predicted_idx]) * 100
        
        predicted_class = class_names[predicted_idx] if class_names else f"Classe_{predicted_idx}"
        
        # Chercher les détails dans MongoDB
        maladie = db.maladies.find_one({"class_name": predicted_class})
        
        if maladie:
            details = {
                "nom": maladie.get("nom", predicted_class),
                "description": maladie.get("description", ""),
                "symptomes": maladie.get("symptomes", []),
                "traitements": maladie.get("traitements", []),
                "conseils_arrosage": maladie.get("conseils_arrosage", ""),
                "conseils_fertilisation": maladie.get("conseils_fertilisation", ""),
                "prevention": maladie.get("prevention", []),
                "gravite": maladie.get("gravite", "modérée")
            }
        else:
            details = {
                "nom": predicted_class,
                "description": "Information non disponible",
                "symptomes": [],
                "traitements": [],
                "conseils_arrosage": "",
                "conseils_fertilisation": "",
                "prevention": [],
                "gravite": "modérée"
            }
        
        # Sauvegarder dans l'historique
        db.historique.insert_one({
            "user_id": str(current_user["_id"]),
            "predicted_class": predicted_class,
            "maladie_nom": details["nom"],
            "confidence": confidence,
            "date": datetime.utcnow().isoformat()
        })
        
        return {
            "success": True,
            "predictedClass": predicted_class,
            "confidence": round(confidence, 2),
            "details": details
        }
        
    except Exception as e:
        logger.error(f"Erreur diagnostic: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))