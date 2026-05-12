import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
import os
import json
from datetime import datetime

# Configuration
DATA_DIR = "D:/chemin/vers/tomates"  # À MODIFIER
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 20

print("📊 Comptage des classes...")
classes = [d for d in os.listdir(DATA_DIR) if os.path.isdir(os.path.join(DATA_DIR, d))]
print(f"✅ {len(classes)} classes trouvées : {classes}")

# Data augmentation
train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=30,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest',
    validation_split=0.2
)

# Charger les données
train_generator = train_datagen.flow_from_directory(
    DATA_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='training',
    shuffle=True
)

validation_generator = train_datagen.flow_from_directory(
    DATA_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='validation',
    shuffle=False
)

print(f"📊 Training samples: {train_generator.samples}")
print(f"📊 Validation samples: {validation_generator.samples}")

# Sauvegarder les noms des classes
class_names = list(train_generator.class_indices.keys())
with open('tomato_classes.json', 'w') as f:
    json.dump(class_names, f)
print(f"✅ Classes sauvegardées: {class_names}")

# Charger ResNet50 pré-entraîné
base_model = ResNet50(weights='imagenet', include_top=False, input_shape=(224, 224, 3))

# Geler les premières couches (transfer learning)
for layer in base_model.layers[:100]:
    layer.trainable = False

# Ajouter des couches personnalisées
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(512, activation='relu')(x)
x = Dropout(0.5)(x)
predictions = Dense(len(classes), activation='softmax')(x)

model = Model(inputs=base_model.input, outputs=predictions)

# Compiler
model.compile(
    optimizer=Adam(learning_rate=0.0001),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

model.summary()

# Callbacks
callbacks = [
    EarlyStopping(patience=5, restore_best_weights=True),
    ModelCheckpoint('tomato_best_model.keras', save_best_only=True),
    ReduceLROnPlateau(factor=0.2, patience=3)
]

# Entraînement
print("🚀 Début de l'entraînement...")
history = model.fit(
    train_generator,
    epochs=EPOCHS,
    validation_data=validation_generator,
    callbacks=callbacks
)

# Sauvegarder le modèle final
model.save('tomato_finetuned_model.keras')
print("✅ Modèle fine-tuné sauvegardé: tomato_finetuned_model.keras")

# Afficher les résultats finaux
final_accuracy = history.history['val_accuracy'][-1]
print(f"\n🎉 Précision finale sur validation: {final_accuracy*100:.2f}%")