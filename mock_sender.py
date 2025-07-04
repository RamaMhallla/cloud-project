import paho.mqtt.client as mqtt
import time
import json
import random
from datetime import datetime


broker_address = "broker.hivemq.com"  # بدل test.mosquitto.org
port = 1883
topic = "health/patient1/sensors"

client = mqtt.Client(client_id="MockRaspberryPi", protocol=mqtt.MQTTv311)
client.connect(broker_address, port)

print("Connected to broker, starting to send sensor data...")

try:
    while True:
        # فقط البيانات التي تقاس بالحساسات تُرسل هنا:
        data = {
            "trestbps": random.randint(94, 200),            # resting blood pressure
            "restecg": random.randint(0, 2),                # resting ECG results
            "thalach": random.randint(71, 202),             # max heart rate achieved
            "oldpeak": round(random.uniform(0.0, 6.2), 1),  # ST depression
            "slope": random.randint(0, 2),  # slope of ST segment
            "timestamp": datetime.utcnow().isoformat()  # ✅ هذا مهم

        }

        client.publish(topic, json.dumps(data), retain=False)
        print(f"Published sensor data: {data}")

        time.sleep(15)

except KeyboardInterrupt:
    print("\nStopped by user.")
    client.disconnect()
