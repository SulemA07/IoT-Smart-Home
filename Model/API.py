import joblib
from flask import Flask, request, jsonify
import MQTTHandler
import random
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

responses = {
    'curtains_close': [
        'Sure, closing the curtains.',
        'Got it. Curtains are closing.',
        'Closing the curtains for you.',
        'On it. Bringing the shades down.',
        'Sure, shutting the blinds.',
        'Got it shutting the blinds.'
    ],
    'curtains_open': [
        'Sure, opening the curtains.',
        'Okay, raising the blinds now.',
        'Got it opening the shades.',
        'On it. Bringing the blinds up.',
        'Alright, opening the curtains.',
        'Lifting the shades for you.'
    ],
    'door_close': [
        'Sure, shutting the door.',
        'Okay, closing the door now.',
        'Got it locking the door.',
        'On it. Shutting the gate.',
        'Alright, closing and securing the door.',
        'Locking the gate for you.'
    ],
    'door_open': [
        'Sure, opening the door.',
        'Okay, unlocking the door now.',
        'Got it opening the gate.',
        'On it. The doors opening.',
        'Alright, the gate is open.',
        'Unlocking and opening the door for you.'
    ],
    'fan_off': [
        'Sure, switching the fan off.',
        'Okay, shutting the fan off now.',
        'Got it switching off the fan.',
        'On it. Closing the fan down.',
        'Alright, the fan is switching off.',
        'Shutting the fan off for you.'
    ],
    'fan_on': [
        'Sure, switching the fan on.',
        'Okay, turning the fan on now.',
        'Got it switching it on.',
        'On it. Starting up the fan.',
        'Alright, the fans coming on.',
        'Opening the fan for you.'
    ],
    'light_off': [
        'Sure, switching the light off.',
        'Okay, turning the light off now.',
        'Got it shutting the light off.',
        'On it. Switching off the light.',
        'Alright, the light is going off.',
        'Closing the light.'
    ],
    'light_on': [
        "Sure, switching the light on.",
        "Okay, turning the light on now.",
        "Got it switching on the light.",
        "On it. The light is coming on.",
        "Alright, lighting is on.",
        "Opening the light.",
        "The light is on."
    ],
    'unknown': [
        "Sorry, I didnt quite catch that.",
        "Could you say that another way?",
        "Im not sure I understand. Can you rephrase?",
        "I didnt get that. Can you try again?",
        "Hmm, Im having trouble understanding. Could you repeat that?",
        "Im not sure what you mean. Can you clarify?",
        "Could you put that differently?"
    ]
}


def get_reply(intent):
    global responses
    options = responses.get(intent)
    return random.choice(options)


def get_intent(command):
    prob = nlp_model.predict_proba([command])[0]
    idx = prob.argmax()
    intent = nlp_model.classes_[idx]
    confidence = round(prob[idx], 3)

    threshold = 0.25
    if confidence < threshold:
        intent = 'unknown'

    return intent

app = Flask(__name__)
nlp_model = joblib.load('/Users/sulemanakram/Desktop/Python/Model/trained_chatbot-3.joblib')


MQTTHandler.start()




message_rec = {
    'transcribedText': ''
}




def getTopic(device):
    if device == "light":
        topic = "home/light"
    elif device == "curtains":
        topic = "home/curtains"
    elif device == "fan":
        topic = "home/fan"
    else:
        topic = "home/door"
    return topic


@app.post('/sendCommand')

def receiveCommand(): # this is from button presses from swift

    data = request.get_json()

    device = data.get('device', '')
    action = data.get('action', '')
    topic = getTopic(device) # getting the topic according to device

    MQTTHandler.send_command(topic, device, action)


    return jsonify({
        'received': True,
        'echo': data
    })


@app.post('/send') # recieves transcribed data here 
def receiveSpeech():
    global message_rec
    data = request.get_json()

    spoken_text = data.get('transcribedText', '')

    characters = ["'", ".", ",", "!"]
    for char in characters:
        spoken_text = spoken_text.replace(char, "")

    message_rec['transcribedText'] = spoken_text

    return jsonify({
        'received': True,
        'echo': data
    })


@app.get('/get') # Python --> Swift / From transcription it returns an intent
def sendIntent():


    intent = get_intent(message_rec['transcribedText'])
    reply = get_reply(intent)

    intent_send = {
    'intent': intent,
    'reply': reply
    }

    print(intent_send)


    # all the comands are here to be sent to arduino

    device = ""
    action = ""
    topic = ""

    if intent == "light_on": # updates command with voice command
        device = "light"
        action = "on"
        topic = "home/light"
    
    elif intent == "light_off":
        device = "light"
        action = "off"
        topic = "home/light"

    elif intent == "fan_on":
        device = "fan"
        action = "on"
        topic = "home/fan"
    
    elif intent == "fan_off":
        device = "fan"
        action = "off"
        topic = "home/fan"
    

    if intent != "unknown" and device != "" and action != "" and topic != "":
        MQTTHandler.send_command(topic, device, action)


    

    return jsonify(intent_send)

@app.get("/getSensorData")
def sendSensorData():

    sensorData = MQTTHandler.getSensorData()

    return jsonify(sensorData)



app.run(host= "0.0.0.0", port=5000) # listening on all areas of the network