//
//  IoTHomeFeatures.swift
//  IoTHome
//
//  Created by Suleman Akram on 11/12/2025.
//
import Foundation

public class IoTHomeFeatures: ObservableObject { // we use this class to communicate between API <--> swift <--> esp32
    @Published public var isLightOn: Bool = false
    @Published public var isDoorClosed: Bool = false
    @Published public var isCurtainsClosed: Bool = false
    @Published public var isFanOn: Bool = false
}



public func interpretIntent(intent: String, features: IoTHomeFeatures) {
        
    if intent == "light_on" {
        features.isLightOn = true // this updates the ui
    } else if intent == "light_off" {
        features.isLightOn = false
    } else if intent == "curtains_open" {
        features.isCurtainsClosed = false
    } else if intent == "curtains_close" {
        features.isCurtainsClosed = true
    } else if intent == "fan_on" {
        features.isFanOn = true
    } else if intent == "fan_off" {
        features.isFanOn = false
    } else if intent == "door_open" {
        features.isDoorClosed = false
    } else if intent == "door_close" {
        features.isDoorClosed = true
    }
    
}
