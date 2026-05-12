from fastapi import APIRouter, HTTPException, Depends
from database.mongodb import db
from middleware.auth import get_current_user
from bson.objectid import ObjectId
from datetime import datetime

router = APIRouter(prefix="/api", tags=["Historique"])

@router.get("/historique")
def get_historique(current_user=Depends(get_current_user)):
    try:
        history = list(db.historique.find(
            {"user_id": str(current_user["_id"])},
            {"_id": 1, "predicted_class": 1, "maladie_nom": 1, "confidence": 1, "date": 1}
        ))
        for item in history:
            item["_id"] = str(item["_id"])
        return history
    except Exception as e:
        return []

@router.post("/historique")
def save_historique(entry: dict, current_user=Depends(get_current_user)):
    try:
        entry["user_id"] = str(current_user["_id"])
        entry["date"] = datetime.utcnow().isoformat()
        result = db.historique.insert_one(entry)
        return {"id": str(result.inserted_id), "message": "saved"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/historique/{entry_id}")
def delete_historique(entry_id: str, current_user=Depends(get_current_user)):
    try:
        result = db.historique.delete_one({
            "_id": ObjectId(entry_id),
            "user_id": str(current_user["_id"])
        })
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Entry not found")
        return {"message": "deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))