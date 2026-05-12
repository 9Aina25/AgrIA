# prepare_plantvillage.py
import tensorflow_datasets as tfds
import tensorflow as tf
import os

# Téléchargement et chargement du dataset (la première fois, téléchargera ~ 1.5 Go)
# data_dir : répertoire où stocker les données (changez selon votre disque)
DATA_DIR = "D:/tensorflow_datasets"

print("Téléchargement/Chargement de plant_village...")
ds, info = tfds.load(
    "plant_village",
    split=["train"],
    data_dir=DATA_DIR,
    with_info=True,
    as_supervised=True  # retourne (image, label)
)

ds_train = ds[0]

# Afficher les informations
print(f"Nombre de classes : {info.features['label'].num_classes}")
print(f"Etiquettes : {info.features['label'].names}")
print(f"Taille du dataset : {len(ds_train)} images")

# Fonction de prétraitement
IMG_SIZE = 224

def preprocess(image, label):
    image = tf.image.resize(image, (IMG_SIZE, IMG_SIZE))
    image = tf.cast(image, tf.float32) / 255.0  # normalisation [0,1]
    return image, label

# Appliquer le prétraitement, batch, shuffle
batch_size = 32
ds_train = ds_train.map(preprocess).shuffle(1000).batch(batch_size).prefetch(tf.data.AUTOTUNE)

# Sauvegarder un exemple batch pour vérification
for images, labels in ds_train.take(1):
    print(f"Batch shape : {images.shape}, labels shape : {labels.shape}")
    break

print("✅ Dataset prêt pour l'entraînement")