import paho.mqtt.client as mqtt
import json
import time
import threading



broker = "192.168.100.44" # MAC LAN IP
port = 1883

client = mqtt.Client(client_id="PythonPublisher")


command = {
    "device": "",
    "action": ""
}

command_ready = False

sensorData = {}
topicReceived = ""

lock = threading.Lock()

def send_command(topic, device, action):
    global command_ready, topicReceived
    with lock:
        command["device"] = device
        command["action"] = action
        topicReceived = topic
        command_ready = True

def getSensorData(): # should be sent to swift / will work on this later for e.g recieve temperature
    global sensorData
    with lock:
        return sensorData.copy()

def _publish(topic, command): # function for publishing
    payload = json.dumps(command)
    result = client.publish(topic, payload)
    status = result[0]
    if status == 0:
        print(f"{payload} send to topic: {topic}")
    else: 
        print("Failed to send publish message")

def on_message(client, userdata, msg): # triggers upon recieving any data from arduino 
    global sensorData
    payload = msg.payload.decode() # converting bytes into string
    data = json.loads(payload) #parsing json 
    sensorData = data

def mqtt_loop(): # runs in background
    global command_ready, command, topicReceived
    while True:
        with lock: # prevent overwrites
            if command_ready:
                _publish(topicReceived, command)
                command_ready = False  # reset after publishing
        time.sleep(0.1)  # small delay to prevent CPU overload
    
def start():
    client.on_message = on_message
    client.connect(broker, port)
    client.subscribe("home/#")
    client.loop_start()

    threading.Thread(target=mqtt_loop, daemon=True).start() # starts the entire process mqtt_loop in a different thread


# mqtt code ends here