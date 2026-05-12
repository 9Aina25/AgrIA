from pydantic import BaseModel
from typing import List, Optional

class Treatment(BaseModel):
    type: str
    titre: str
    description: str
    icone: str = "💊"

class DiseaseResponse(BaseModel):
    class_name: str
    nom: str
    nom_scientifique: Optional[str] = ""
    description: str
    symptomes: List[str] = []
    traitements: List[dict] = []
    conseils_arrosage: str = ""
    conseils_fertilisation: str = ""
    prevention: List[str] = []
    categorie: str = ""
    gravite: str = ""