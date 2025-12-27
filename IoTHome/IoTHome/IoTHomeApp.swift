//
//  IoTHomeApp.swift
//  IoTHome
//
//  Created by Suleman Akram on 09/12/2025.
//

import SwiftUI
import Speech
import AVFoundation

@main
struct IoTHomeApp: App {
    
    
    init() {
        requestSpeechPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(features: IoTHomeFeatures())
        }
    }
    func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Speech recognition authorized ✅")
            case .denied, .restricted, .notDetermined:
                print("Speech recognition NOT authorized ❌")
            @unknown default:
                break
            }
        }
    }
}
