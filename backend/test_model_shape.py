# test_model_shape.py
from tensorflow.keras.models import load_model
import numpy as np

model = load_model('tomato_11classes_final.keras')
print("✅ Modèle chargé")
print(f"Input shape attendue : {model.input_shape}")