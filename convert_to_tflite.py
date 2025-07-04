import tensorflow as tf

# Load the model
model = tf.keras.models.load_model("heart_model.h5")

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save TFLite file
with open("heart_model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Model converted and saved as heart_model.tflite")
