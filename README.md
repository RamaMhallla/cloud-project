---

## ❤️ Heart Disease Prediction Model

- Trained using clinical features such as:
  - Age, Sex, Blood Pressure, Cholesterol, Max Heart Rate
- Built with Keras (Dense + Dropout layers)
- Converted to `.tflite` for integration with the Flutter app

### ▶️ Training Script:
Located in: `Heart Disease Prediction/model/train_model.py`

---

## 🩻 Pneumonia Detection from X-Ray

- Based on Kaggle dataset:  
  [Chest X-ray Images (Pneumonia)](https://www.kaggle.com/datasets/paultimothymooney/chest-xray-pneumonia)
- Trained on Google Colab using CNN
- Data processed with `ImageDataGenerator` and resizing
- Exported model to TFLite

### ▶️ Notebook:

Located in: `Detecting Pneumonia using Chest X-Ray/xray_model_training.ipynb`

---

## 📱 Flutter App

- Collects patient inputs (cholesterol, blood pressure, etc.)
- Integrates with TFLite model to give prediction results
- Receives sensor data (e.g., from Raspberry Pi) via MQTT
- Connected with a real-time MQTT listener (`mock_sender.py` used for simulation)

---

## 🚀 Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/RamaMhalla/cloud-project.git
   ```
