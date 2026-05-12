from database.mongodb import db

def init_database():
    # Créer les index
    db.users.create_index("email", unique=True)
    db.maladies.create_index("class_name", unique=True)
    
    print("✅ Index créés dans MongoDB")
    
    # Vérifier si la collection maladies est vide
    if db.maladies.count_documents({}) == 0:
        print("⚠️ La collection 'maladies' est vide. Exécutez import_maladies.py")
    
    return True

if __name__ == "__main__":
    init_database()