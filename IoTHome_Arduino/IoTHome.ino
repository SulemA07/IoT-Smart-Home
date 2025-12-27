#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>
#include "DHT.h"

// curtain motor setup
const int IN1 = 22;
const int IN2 = 23;


void openCurtain() {
  Serial.println("Opening Curtain...");
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);// when 3 seconds pass we stop the function
  delay(700);
  digitalWrite(IN1, LOW); 

}

void closeCurtain() {
  Serial.println("Closing Curtain...");
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  delay(700);// when 3 seconds pass we stop the function
  digitalWrite(IN2, LOW); 
}

// door servo setup
Servo doorServo;
const int servoPin = 5;
int currentAngle = 0; // track position

// servo function
void moveServo(int angle) {
  currentAngle = angle;
  doorServo.write(angle);
}

// === DHT11 Setup ===
#define DHTPIN 27     
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);
float temperature = 0;
float humidity = 0;
unsigned long lastDHTRead = 0;

// Wifi Setup
const char* ssid = "LOF_Students";
const char* password = "987654321";

// MQTT Setup
const char* mqtt_server = "192.168.100.44"; // Mac LAN IP Goes here
const char* topic1 = "home/light"; // all the topics we're listening for
const char* topic2 = "home/curtains";
const char* topic3 = "home/fan";
const char* topic4 = "home/door";

// Hardware
const int fanPin = 19;
const int ledPin = 18;

WiFiClient espClient;
PubSubClient client(espClient);

// Call back which is triggered when data is published to topic it's subscribed to 
void callback(char* topic, byte* payload, unsigned int length) {

  Serial.print("Message arrived on topic: ");
  Serial.println(topic);

  Serial.print("Payload: ");
  // converting the payload into string 
  String message;
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  // Parsing the json recieved which is command = { "device": "", "action", ""}
  StaticJsonDocument<200> doc;
  DeserializationError error = deserializeJson(doc, message);

  if (error) {
    Serial.println("JSON Parse Failed");
    return;
  }

  const char* device = doc["device"];
  const char* action = doc["action"];

  // decision making/communicating with the hardware
  if (strcmp(device, "light") == 0) {
    if (strcmp(action, "on") == 0) {
      digitalWrite(ledPin, HIGH);
    }
    if (strcmp(action, "off") == 0) {
      digitalWrite(ledPin, LOW);
    }
  }

  if (strcmp(device, "fan") == 0) {

    if (strcmp(action, "on") == 0) {
      digitalWrite(fanPin, HIGH); // starts off at 25% speed
    }

    
    if (strcmp(action, "off") == 0) {
      digitalWrite(fanPin, LOW);
    }
  }

  if (strcmp(device, "door") == 0) {
    if (strcmp(action, "open") == 0) {
      moveServo(180);
    }
    if (strcmp(action, "closed") == 0) {
      moveServo(0);
    }
  }

    if (strcmp(device, "curtains") == 0) {
    if (strcmp(action, "open") == 0) {
      openCurtain();
    }
    if (strcmp(action, "closed") == 0) {
      closeCurtain();
    }
  }

} // end of callback function

// Wifi Setup
void setup_wifi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");
}

// MQTT Broker

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32_Client-" + String(random(300));
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      client.subscribe(topic1);
      client.subscribe(topic2);
      client.subscribe(topic3);
      client.subscribe(topic4);
      Serial.println("Subscribed to all topics");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  // put your setup code here, to run once:

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(fanPin, OUTPUT);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(ledPin, LOW);
  digitalWrite(fanPin, LOW);

  dht.begin();


  Serial.begin(9600);

  // servo motor
  doorServo.attach(servoPin);
  doorServo.write(currentAngle);

  // temperature sensor


  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}




void loop() {
  // put your main code here, to run repeatedly:
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  if (millis() - lastDHTRead > 3000) { // every 2 seconds updated and published
    lastDHTRead = millis();   

    temperature = dht.readTemperature();
    humidity = dht.readHumidity();

    if (isnan(humidity) || isnan(temperature)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
    }

    char tmpStr[8];
    char humStr[8];
    dtostrf(temperature, 4, 1, tmpStr); // 4 = min width, 1 = decimal places
    dtostrf(humidity, 4, 1, humStr);

    StaticJsonDocument<200> sensorData;

    sensorData["temperature"] = tmpStr;
    sensorData["humidity"] = humStr;

    char payload[128];

    serializeJson(sensorData, payload);

    client.publish("home/sensorData", payload);

    Serial.println(humidity);
    Serial.println(temperature);

  }
  
}
