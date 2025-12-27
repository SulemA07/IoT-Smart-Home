//
//  Home.swift
//  IoTHome
//
//  Created by Suleman Akram on 16/12/2025.
//

import SwiftUI

struct Home: View {

    @ObservedObject var features: IoTHomeFeatures
    @StateObject var recorder: VoiceRecorder
    @StateObject var voiceManager: SpeechSynthesis
    
    init(features: IoTHomeFeatures) {
        self.features = features
        _recorder = StateObject(wrappedValue: VoiceRecorder(features: features))
        _voiceManager = StateObject(wrappedValue: SpeechSynthesis())
    }
    
    @State private var name = "Suleman"
    
    @State private var recordPresent: Bool = false
    
    @State private var countdownTimer: Int = 0
    
    @State private var timer: Timer?
    
    // IotFeature Vars
    
    func mainStartRecording() {
        countdownTimer = 0
        
        recorder.startRecording()
        recordPresent = true
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            countdownTimer += 1
        }
    }
    
    func mainStopRecording() {
        timer?.invalidate()
        timer = nil
        countdownTimer = 0
        
        recordPresent = false
    
        recorder.stopRecording()
    
        let url = recorder.getFile()
        print("Audio file exists:", FileManager.default.fileExists(atPath: url.path))
    
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attr[.size] as? UInt64 {
            print("Audio file size:", size)
        }
    }
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack(alignment: .center) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome Home,").font(.title).bold().foregroundStyle(Color.white)
                        Text(name).font(.title).bold().foregroundStyle(Color.white)
                    }
                    
                    Spacer()
                    
                    Button() { // starting the recording
                        mainStartRecording()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.white)
                            
                            Image(systemName: "waveform.path")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                    }
                    
                }.padding() // end of Hstack
                
                .sheet(isPresented: $recordPresent) {
                    
                    Text("Hi, How may I assist you today").font(.largeTitle).padding()
                    
                    Spacer()
                    
                    AudioVisualizer(recorder: recorder).padding()
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        Text(String(format: "00:%02d", countdownTimer)).foregroundStyle(Color.gray)
                        Button {
                            mainStopRecording()
                        } label: {
                            Text("Stop recording").padding().bold()
                        }.frame(width: 150, height: 50).background(Color.red).cornerRadius(20).foregroundStyle(Color.white)
                    }.padding() // end of hstack
                } // end of sheet
                
                VStack() {
                    HStack() {
                        
                        ZStack{ // light button
                            
                            RoundedRectangle(cornerRadius: 20).fill(Color.white).frame(width: 150, height: 150).shadow(radius: 10)
                            
                            VStack(alignment: .trailing) {
                                HStack {
                                    Text("Lights").foregroundStyle(Color.blue)
                                    Toggle("", isOn: $features.isLightOn).tint(.blue).onChange(of: features.isLightOn) { _, isOn in
                                        let action = isOn ? "on" : "off"
                                        sendCommandToPython(device: "light", action: action)
                                    }
                                }
                                
                                Image(systemName: features.isLightOn ? "lightbulb.max.fill" : "lightbulb.max")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.blue)
                                
                                Spacer()
                            }.padding().frame(width: 150, height: 150)
                        }.padding()
                        
                        ZStack{ // door button
                            RoundedRectangle(cornerRadius: 20).fill(Color.white).frame(width: 150, height: 150).shadow(radius: 10)
                            
                            VStack(alignment: .trailing) {
                                HStack {
                                    Text("Door").foregroundStyle(Color.blue)
                                    Toggle("", isOn: $features.isDoorClosed).tint(.blue).onChange(of: features.isDoorClosed) { _, isOn in
                                        let action = isOn ? "closed" : "open"
                                        sendCommandToPython(device: "door", action: action)
                                    }
                                }
                                
                                Image(systemName: features.isDoorClosed ? "door.left.hand.closed" : "door.left.hand.open")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.blue)
                                
                                Spacer()
                            }.padding().frame(width: 150, height: 150)
                        }.padding()
                        
                    }.padding(.top) // end of Hstack/row of 2 buttons
                    
                    HStack() {
                        ZStack{ // blinds button
                            RoundedRectangle(cornerRadius: 20).fill(Color.white).frame(width: 150, height: 150).shadow(radius: 10)
                            
                            VStack(alignment: .trailing) {
                                HStack {
                                    Text("Blinds").foregroundStyle(Color.blue)
                                    Toggle("", isOn: $features.isCurtainsClosed).tint(.blue).onChange(of: features.isCurtainsClosed) { _, isOn in
                                        let action = isOn ? "closed" : "open"
                                        sendCommandToPython(device: "curtains", action: action)
                                    }
                                }
                                
                                Image(systemName: features.isCurtainsClosed ? "curtains.closed" : "curtains.open")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.blue)
                                
                                Spacer()
                            }.padding().frame(width: 150, height: 150)
                        }.padding()
                        
                        ZStack{ // fan button
                            RoundedRectangle(cornerRadius: 20).fill(Color.white).frame(width: 150, height: 150).shadow(radius: 10)
                            
                            VStack(alignment: .trailing) {
                                HStack {
                                    Text("Fan").foregroundStyle(Color.blue)
                                    Toggle("", isOn: $features.isFanOn).tint(.blue).onChange(of: features.isFanOn) { _, isOn in
                                        let action = isOn ? "on" : "off"
                                        sendCommandToPython(device: "fan", action: action)
                                    }
                                }
                                
                                Image(systemName: features.isFanOn ? "fan.fill" : "fan")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.blue)
                                
                                Spacer()
                            }.padding().frame(width: 150, height: 150)
                        }.padding()
                    }
                }
                
                Spacer()
                
            } // end of Vstack
            .onChange(of: countdownTimer) {
                if countdownTimer == 15 {
                    mainStopRecording()
                }
            }
        } // end of zstack
    } // end of body
} // end of struct

#Preview {
    Home(features: IoTHomeFeatures())
}
