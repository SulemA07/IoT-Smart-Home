# IoT-Smart-Home
AI-enabled IoT Smart Home Automation system integrating ESP32 hardware, Python backend, and an iOS app with voice control. Real-time monitoring and physical prototype included.

System Architecture:
  •	ESP32 Microcontroller – Controls sensors and actuators.
  •	MQTT Broker (Eclipse Mosquitto) – Facilitates communication between devices and backend.
  •	Python Backend (Model) – Handles MQTT communication, API requests, and AI-based intent detection using joblib models.
  •	iOS App (IoTHome) – Provides user interface for manual and voice control.

Folder Structure: 
IoT-Smart-Home/
├── Model/               # Python backend with MQTT handler, API, and AI model
├── IoTHome/             # Swift iOS application
├── IoTHome_Arduino/     # Arduino code for ESP32 control
└── README.md            # This file

Getting Started
1. MQTT Broker
   Install and run Eclipse Mosquitto locally:
   bash: mosquitto -v
   
3. Python backend
   bash:
     cd Model
     pip install -r requirements.txt
     python api.py # Replace value of ip variable with your local ip

4. ESP32
   bash:
     cd IoTHome_Arduino
     open ESP32_Control.ino

5. iOS App
   Open the swift project in Xcode
   Replace ip address for post and get methods in IoTHome/API_py

Hardware Requirements
  ESP32 Microcontroller
  Fan, LED lights, servo motor, motor driver
  Temperature sensor, curtain motor, door mechanism

Features
  Manual control of home appliances
  Voice control using Apple Speech Framework
  Physical prototype demonstation

Notes
  All communication runs on local LAN # Can replaced using a cloud server
  Ensure proper wiring for ESP32 pins and sensors
   
     
