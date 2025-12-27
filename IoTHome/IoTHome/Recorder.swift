//
//  Recorder.swift
//  IoTHome
//
//  Created by Suleman Akram on 09/12/2025.
//

import Foundation
import AVFoundation
import SwiftUI
import Speech


class VoiceRecorder: NSObject, AVAudioRecorderDelegate, ObservableObject {
    
    @Published var features: IoTHomeFeatures
    let voiceManager = SpeechSynthesis()
    
    @Published var currentLevel: Float = 0.0
    @Published var isAuthorized: Bool = false
    @Published var transcribedText = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    var meterTimer: Timer?
    
    var audioRecorder: AVAudioRecorder?

    init(features: IoTHomeFeatures) {
        self.features = features
        super.init()
        requestPermissions()
    }
    
    
    func getFile() -> URL {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = "voice.m4a"
        return document.appendingPathComponent(filename)
    }
    
    let settings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 16000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    func requestPermissions() {
        // Request Microphone Permission
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone access granted.")
                    // Request Speech Recognition Permission
                    SFSpeechRecognizer.requestAuthorization { authStatus in
                        DispatchQueue.main.async {
                            switch authStatus {
                            case .authorized:
                                self.isAuthorized = true
                                print("Speech recognition authorized. App is ready.")
                            default:
                                self.isAuthorized = false
                                print("Speech recognition denied/restricted. Cannot function.")
                            }
                        }
                    }
                } else {
                    self.isAuthorized = false
                    print("Microphone access denied. Cannot function.")
                }
            }
        }
    }

    func startRecording() {
        
        do {
            print("Started Recording")
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            try audioRecorder = AVAudioRecorder(url: getFile(), settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.delegate = self
            audioRecorder?.record()
            

            meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                self.updateMeter()
            }
            
        } catch {
            print("Voice failed to record")
        }
        

    
    }
    
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        meterTimer?.invalidate()
        meterTimer = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                print("AVAudioSession deactivated.")
            } catch {
                print("Failed to deactivate audio session: \(error.localizedDescription)")
            }
        
    }
    
    func updateMeter() { // for the visualizer
        
        audioRecorder?.updateMeters()
        
        let dB = audioRecorder?.averagePower(forChannel: 0) ?? -160 // -160 means silence
        
        let level = pow(10, dB / 20)
        
        currentLevel = level
        
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
            transcribeSpeech(url: recorder.url)
            print("transcribed text sent to python..")
        } else {
            print("Recording failed")
        }
    }

    func transcribeSpeech(url: URL) {
            
        self.recognitionTask?.cancel()
        
        guard let speechRecognizer = self.speechRecognizer, speechRecognizer.isAvailable else {
                print("Recognizer not available")
                return
            }

            let request = SFSpeechURLRecognitionRequest(url: url)
            request.shouldReportPartialResults = false
            
        speechRecognizer.recognitionTask(with: request) { [weak self] (result, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let self = self else { return }
                        print("Attempting transcription now after delay...")

                        self.recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] (result, error) in
                            // This is the completion handler, it runs when the task is done/errors
                            DispatchQueue.main.async {
                                if let error = error {
                                    print("🛑 Transcription task ended with ERROR: \(error.localizedDescription)")
                                    self?.transcribedText = "Error: \(error.localizedDescription)"
                                } else if let result = result {
                                    if result.isFinal {
                                        self?.transcribedText = result.bestTranscription.formattedString
                                        print("✅ Transcription: \(self?.transcribedText ?? "")")
                                        
                                        sendToPython(dataToSend: self?.transcribedText.lowercased() ?? "") // sending the transcribed text to python to return command
                                        
                                        getFromPython() { result in
                                            
                                            
                                            guard let features = self?.features else {
                                                return
                                            }
                                            
                                            print("Got from python: ", "result: ", result.intent, "reply: ", result.reply)
                                            DispatchQueue.main.async { [weak self] in
                                                
                                                self?.voiceManager.speechToText(result.reply)
                                                interpretIntent(intent: result.intent, features: features)
                                            }
                                            
                                        }
                                    }
                                }
                                
                                self?.recognitionTask = nil
                            }
                        }
                    }
            }
        }
    }

    

struct AudioVisualizer: View {
    @ObservedObject var recorder: VoiceRecorder
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.8))
            .frame(width: 200, height: 200)
            .scaleEffect(1 + CGFloat(recorder.currentLevel) * 0.8)
            .animation(.easeOut(duration: 0.05), value: recorder.currentLevel)
    }
}

