from fastapi import APIRouter, Depends
from database.mongodb import db
from middleware.auth import get_current_user
from datetime import datetime

router = APIRouter(prefix="/api", tags=["Journal"])

@router.get("/journal")
def get_journal(current_user=Depends(get_current_user)):
    entries = list(db.journal.find({"user_id": str(current_user["_id"])}, {"_id": 0}))
    return entries

@router.post("/journal")
def add_journal(entry: dict, current_user=Depends(get_current_user)):
    entry["user_id"] = str(current_user["_id"])
    entry["date"] = datetime.utcnow().isoformat()
    db.journal.insert_one(entry)
    return {"message": "added"}