import os
import time
import requests
import pytz
from datetime import datetime
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://vjcmzareotkixgjwvshl.supabase.co" 
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqY216YXJlb3RraXhnand2c2hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0NDcxMjksImV4cCI6MjA1NDAyMzEyOX0.9kr7vf_FmeT0uTxtDj2beJxtssb3V89UXcLpwzlqv3I"  # Replace with your Supabase API Key

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

API_KEY = "AIzaSyCcEEXbsnVt9ESSxQmPDImXuEtjl9VkP3M"

def send_to_supabase(idy,current_lat,current_long,target_lat,target_long,at_work):
    """ Sends data to Supabase database """
    try:
        data = {
            "id": idy,
            "current_lat": current_lat,
            "current_long": current_long,
            "target_lat": target_lat,
            "target_long": target_long,
            "at_work": at_work,
        }
        record_id = 1   # our board can be Plow 1 rows
        response = supabase.table("plow_update").update(data).eq("id", record_id).execute()  
        print(f"Data updated successfully: {response}")
    except Exception as e:
        print(f"Error updating data to Supabase: {e}")

def get_location():
    scan_data = []
    scan_result = os.popen("sudo iwlist wlan0 scan").read()
    mac, signal = None, None

    for line in scan_result.split("\n"):
        if "Address" in line:
            mac = line.split("Address: ")[1].strip()
        if "Signal level" in line:
            try:
                signal = int(line.split("Signal level=")[1].split(" dBm")[0])
            except ValueError:
                signal = -100  # Default value

        if mac and signal is not None:
            scan_data.append({"macAddress": mac, "signalStrength": signal})
            mac, signal = None, None

    if not scan_data:
        print(" No Wi-Fi networks detected!")
        return None

    data = {"wifiAccessPoints": scan_data}
    url = f"https://www.googleapis.com/geolocation/v1/geolocate?key={API_KEY}"

    try:
        response = requests.post(url, json=data, timeout=10)
        response.raise_for_status()
        location = response.json()
        lat, lon = location['location']['lat'], location['location']['lng']
        print(f"Latitude: {lat}, Longitude: {lon}")

        # assign corresponding values
        idy = 1
        request_count = 10
        target_lat = "42.7274"
        target_long = "-84.4823"
        current_lat = lat
        current_long = lon
        
        # thresholding for boolean
        if ((float(current_lat)) >= float(target_lat)) and ((float(current_long)) >= float(target_long)):
            at_work = False
        else:
            at_work = True
        
        

        # Send data to Supabase
        send_to_supabase(idy,current_lat,current_long,target_lat,target_long,at_work)

    except requests.exceptions.RequestException as e:
        print(f"❌ Error fetching location: {e}")

# Run the function every 1 second
while True:
    get_location()
    time.sleep(2)  # Wait 2 second before the next update