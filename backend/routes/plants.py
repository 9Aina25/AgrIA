from fastapi import APIRouter, HTTPException, Depends
from database.mongodb import db
from middleware.auth import get_current_user
from bson.objectid import ObjectId
from datetime import datetime

router = APIRouter(prefix="/api", tags=["Plants"])

@router.get("/plants")
def get_plants(current_user=Depends(get_current_user)):
    try:
        plants = list(db.plants.find(
            {"user_id": str(current_user["_id"])},
            {"_id": 0}
        ))
        return plants
    except Exception as e:
        return []

@router.post("/plants")
def add_plant(plant: dict, current_user=Depends(get_current_user)):
    try:
        plant["user_id"] = str(current_user["_id"])
        plant["created_at"] = datetime.utcnow().isoformat()
        result = db.plants.insert_one(plant)
        return {"id": str(result.inserted_id), "message": "Plante ajoutée"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/plants/{plant_id}")
def delete_plant(plant_id: str, current_user=Depends(get_current_user)):
    try:
        result = db.plants.delete_one({
            "_id": ObjectId(plant_id),
            "user_id": str(current_user["_id"])
        })
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Plant not found")
        return {"message": "deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))