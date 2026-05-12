from fastapi import APIRouter, HTTPException
from database.mongodb import db
from models.disease import DiseaseResponse

router = APIRouter(prefix="/api", tags=["Maladies"])

@router.get("/maladies", response_model=list)
def get_maladies(skip: int = 0, limit: int = 100):
    maladies = list(db.maladies.find({}, {"_id": 0}).skip(skip).limit(limit))
    return maladies

@router.get("/maladies/{class_name}")
def get_maladie_by_class(class_name: str):
    maladie = db.maladies.find_one({"class_name": class_name}, {"_id": 0})
    if not maladie:
        raise HTTPException(status_code=404, detail="Maladie non trouvée")
    return maladie