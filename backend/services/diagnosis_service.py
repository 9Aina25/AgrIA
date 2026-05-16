import io
import numpy as np
from PIL import Image, ImageEnhance, ImageFilter
import tensorflow as tf
import logging
import os

logger = logging.getLogger(__name__)

class DiagnosisService:
    _instance = None
    model = None
    class_names = None
    
    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
    
    def load_model(self, model_path: str, class_names: list):
        try:
            if not os.path.exists(model_path):
                logger.error(f"❌ Fichier modèle introuvable: {model_path}")
                self.model = None
                return False
                
            self.model = tf.keras.models.load_model(model_path)
            self.class_names = class_names
            logger.info(f"✅ Modèle chargé depuis {model_path}")
            return True
        except Exception as e:
            logger.error(f"❌ Erreur chargement modèle: {e}")
            self.model = None
            return False
    
    def preprocess_image(self, image_bytes):
        try:
            img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            img = img.resize((128, 128))  # ← TAILLE CORRECTE (128x128)
            img_array = np.array(img).astype(np.float32) / 255.0
            return np.expand_dims(img_array, axis=0)
        except Exception as e:
            logger.error(f"Erreur prétraitement: {e}")
            img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            img = img.resize((128, 128))
            img_array = np.array(img).astype(np.float32) / 255.0
            return np.expand_dims(img_array, axis=0)
    
    def predict(self, image_bytes):
        if self.model is None:
            raise ValueError("Modèle non chargé")
        
        input_tensor = self.preprocess_image(image_bytes)
        predictions = self.model.predict(input_tensor)[0]
        predicted_idx = int(np.argmax(predictions))
        confidence = float(predictions[predicted_idx]) * 100
        
        if self.class_names and predicted_idx < len(self.class_names):
            predicted_class = self.class_names[predicted_idx]
        else:
            predicted_class = f"Classe_{predicted_idx}"
        
        logger.info(f"Prédiction: {predicted_class} ({confidence:.1f}%)")
        return predicted_class, confidence

diagnosis_service = DiagnosisService.get_instance()