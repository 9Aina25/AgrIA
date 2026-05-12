from fastapi import APIRouter, HTTPException, Depends
from database.mongodb import db
from middleware.auth import get_current_user
from bson.objectid import ObjectId
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["User"])

@router.get("/user/stats")
def get_user_stats(current_user=Depends(get_current_user)):
    try:
        user_id = str(current_user["_id"])
        
        # Compter les diagnostics dans l'historique
        scans_count = db.historique.count_documents({"user_id": user_id})
        
        # Compter les diagnostics sains vs malades
        healthy_count = db.historique.count_documents({
            "user_id": user_id,
            "predicted_class": {"$regex": "healthy", "$options": "i"}
        })
        sick_count = scans_count - healthy_count
        
        # Calculer un score de santé (simple)
        if scans_count > 0:
            score = int((healthy_count / scans_count) * 100)
        else:
            score = 100
        
        # Top 3 plantes les plus scannées
        pipeline = [
            {"$match": {"user_id": user_id}},
            {"$group": {"_id": "$predicted_class", "count": {"$sum": 1}}},
            {"$sort": {"count": -1}},
            {"$limit": 3}
        ]
        top_plants = list(db.historique.aggregate(pipeline))
        
        return {
            "scans": scans_count,
            "healthy": healthy_count,
            "sick": sick_count,
            "score": score,
            "top_plants": top_plants
        }
    except Exception as e:
        logger.error(f"Erreur get_user_stats: {str(e)}")
        return {
            "scans": 0,
            "healthy": 0,
            "sick": 0,
            "score": 100,
            "top_plants": []
        }

@router.get("/user/profile")
def get_user_profile(current_user=Depends(get_current_user)):
    try:
        return {
            "email": current_user["email"],
            "full_name": current_user["full_name"],
            "created_at": current_user.get("created_at", ""),
            "email_verified": current_user.get("email_verified", False)
        }
    except Exception as e:
        logger.error(f"Erreur get_user_profile: {str(e)}")
        raise HTTPException(status_code=500, detail="Erreur lors de la récupération du profil")

@router.put("/user/profile")
def update_user_profile(
    data: dict,
    current_user=Depends(get_current_user)
):
    try:
        user_id = current_user["_id"]
        update_data = {}
        
        if "full_name" in data and data["full_name"]:
            update_data["full_name"] = data["full_name"]
        
        if "send_notifications" in data:
            update_data["send_notifications"] = data["send_notifications"]
        
        if update_data:
            db.users.update_one(
                {"_id": user_id},
                {"$set": update_data}
            )
        
        return {"message": "Profil mis à jour avec succès"}
    except Exception as e:
        logger.error(f"Erreur update_user_profile: {str(e)}")
        raise HTTPException(status_code=500, detail="Erreur lors de la mise à jour du profil")