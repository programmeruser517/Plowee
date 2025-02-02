import requests
import time

DB_ENDPOINT = "https://your-firebase-db.com/location"

def send_location(lat, lon):
    data = {"latitude": lat, "longitude": lon}
    response = requests.post(DB_ENDPOINT, json=data)
    print(response.json())

while True:
    # Replace with real GPS sensor data
    send_location(42.123, -84.123)
    time.sleep(60)  # Send every 60 seconds
