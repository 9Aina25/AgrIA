from pymongo import MongoClient
from config.settings import settings

class MongoDB:
    _instance = None
    
    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
    
    def __init__(self):
        self.client = MongoClient(settings.MONGO_URI)
        self.db = self.client[settings.DATABASE_NAME]
        self.users = self.db["users"]
        self.maladies = self.db["maladies"]
        self.historique = self.db["historique"]
        self.notifications = self.db["notifications"]
        self.plants = self.db["plants"]
        print(f"✅ MongoDB connecté: {settings.MONGO_URI}")
    
    def close(self):
        self.client.close()

# Export facile
db = MongoDB.get_instance()