import os
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from database.mongodb import db
from middleware.auth import get_current_user
from datetime import datetime
from bson.objectid import ObjectId
from groq import Groq
from dotenv import load_dotenv
from typing import Optional

load_dotenv()
router = APIRouter(prefix="/api", tags=["Chat"])

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
if GROQ_API_KEY:
    client = Groq(api_key=GROQ_API_KEY)
else:
    client = None

SYSTEM_PROMPT = (
    "Tu es un assistant agricole expert nommé AgrIA. Tu es spécialisé dans les plantes, "
    "les maladies des cultures, les traitements naturels, et l'agriculture durable. "
    "Réponds toujours en français, de manière claire et concise."
)

class ChatRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = None

@router.post("/chat")
async def chat(request: ChatRequest, current_user=Depends(get_current_user)):
    if not client:
        raise HTTPException(503, "Service IA non disponible (clé API manquante)")

    user_id = current_user["_id"]
    conv_id = request.conversation_id

    # Création ou mise à jour de la conversation
    if not conv_id:
        # Utiliser le premier message comme titre
        title = request.message[:50] if len(request.message) > 50 else request.message
        conv_doc = {
            "user_id": user_id,
            "title": title,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "last_message": request.message[:50]
        }
        result = db["conversations"].insert_one(conv_doc)
        conv_id = str(result.inserted_id)
    else:
        db["conversations"].update_one(
            {"_id": ObjectId(conv_id), "user_id": user_id},
            {"$set": {"updated_at": datetime.utcnow(), "last_message": request.message[:50]}}
        )

    try:
        completion = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": request.message}
            ],
            temperature=0.5,
            max_tokens=256,
        )
        reply = completion.choices[0].message.content
    except Exception as e:
        print(f"Erreur Groq: {type(e).__name__} - {str(e)}")
        reply = "Je suis désolé, le service IA est temporairement indisponible. Veuillez réessayer plus tard."

    # Sauvegarde du message
    db["chat_messages"].insert_one({
        "conversation_id": conv_id,
        "user_message": request.message,
        "bot_message": reply,
        "timestamp": datetime.utcnow()
    })

    return {"reply": reply, "conversation_id": conv_id}

@router.get("/chat/conversations")
async def get_conversations(current_user=Depends(get_current_user)):
    cursor = db["conversations"].find(
        {"user_id": current_user["_id"]},
        {"_id": 1, "title": 1, "created_at": 1, "updated_at": 1, "last_message": 1}
    ).sort("updated_at", -1)
    convs = []
    for doc in cursor:
        convs.append({
            "id": str(doc["_id"]),
            "title": doc.get("title", "Conversation"),
            "created_at": doc["created_at"].isoformat(),
            "updated_at": doc["updated_at"].isoformat(),
            "last_message": doc.get("last_message", "")
        })
    return {"conversations": convs}

@router.get("/chat/history/{conversation_id}")
async def get_conversation_history(conversation_id: str, current_user=Depends(get_current_user)):
    conv = db["conversations"].find_one({"_id": ObjectId(conversation_id), "user_id": current_user["_id"]})
    if not conv:
        raise HTTPException(404, "Conversation non trouvée")
    cursor = db["chat_messages"].find(
        {"conversation_id": conversation_id},
        {"_id": 0, "user_message": 1, "bot_message": 1, "timestamp": 1}
    ).sort("timestamp", 1)
    history = list(cursor)
    return {"history": history}

@router.post("/chat/conversations/{conversation_id}/rename")
async def rename_conversation(conversation_id: str, request: dict, current_user=Depends(get_current_user)):
    new_title = request.get("title")
    if not new_title:
        raise HTTPException(400, "Titre manquant")
    result = db["conversations"].update_one(
        {"_id": ObjectId(conversation_id), "user_id": current_user["_id"]},
        {"$set": {"title": new_title}}
    )
    if result.modified_count == 0:
        raise HTTPException(404, "Conversation non trouvée")
    return {"message": "Renommée"}

@router.delete("/chat/conversations/{conversation_id}")
async def delete_conversation(conversation_id: str, current_user=Depends(get_current_user)):
    conv = db["conversations"].find_one({"_id": ObjectId(conversation_id), "user_id": current_user["_id"]})
    if not conv:
        raise HTTPException(404, "Conversation non trouvée")
    db["conversations"].delete_one({"_id": ObjectId(conversation_id)})
    db["chat_messages"].delete_many({"conversation_id": conversation_id})
    return {"message": "Supprimée"}
