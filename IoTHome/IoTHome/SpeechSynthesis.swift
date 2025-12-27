//
//  SpeechSynthesis.swift
//  IoTHome
//
//  Created by Suleman Akram on 15/12/2025.
//

import AVFoundation


class SpeechSynthesis: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()

    public func speechToText(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)


        // Configure the utterance.
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.2
        utterance.postUtteranceDelay = 0.5
        utterance.volume = 0.8


        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact")


        // Assign the voice to the utterance.
        utterance.voice = voice
        


        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
}

