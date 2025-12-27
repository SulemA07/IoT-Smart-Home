//
//  ClimateControl.swift
//  IoTHome
//
//  Created by Suleman Akram on 16/12/2025.
//

import Foundation
import SwiftUI

struct ClimateControl: View {
    
    @ObservedObject var IoTHomeFeatures: IoTHomeFeatures
    
    let maxTemp: Double = 48
    @State private var temperature = ""
    @State private var humidity = ""
        
    
    var body: some View {
        
        ZStack {
            
            Color.white.ignoresSafeArea()
            VStack {
                Text("Climate Control").foregroundStyle(Color.black)
                
                Spacer()
                                
                ZStack { // Temp Overview
                    Circle().stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    
                    Circle().trim(from: 0, to: CGFloat(Double(temperature) ?? 0) / CGFloat(maxTemp))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(x: 1, y: -1)
                        .animation(.linear(duration: 1), value: Int(temperature))
                    
                    VStack {
                        Text("Temp: " + temperature + "°C").foregroundStyle(Color.black).font(.largeTitle).bold()
                        Text("Humidity: " + humidity + "%").foregroundStyle(Color.gray.opacity(0.3)).font(.title2)
                    }

                }.frame(width:300)
                
                Button {
                    
                } label: {
                        
                        HStack {
                            Image(systemName: "calendar").resizable().frame(width: 20, height: 20).aspectRatio(contentMode: .fit).foregroundStyle(Color.black)
                            Text("Schedule").foregroundStyle(Color.black)
                        }.padding()

                }   .frame(height: 50).foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 2)
                    ).padding()
                
                Spacer()
                
                
            }

            
        }.onAppear() {
            _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                getSensorData() { result in
                    DispatchQueue.main.async {
                        temperature = result.temperature
                        humidity = result.humidity
                    }
                }
            }
        } // end of on appear
    }
    
}
