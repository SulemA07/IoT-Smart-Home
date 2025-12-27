//
//  APIManagement.swift
//  APIapp
//
//  Created by Suleman Akram on 09/12/2025.
//


// LAN IP FOR THIS MAC: 192.168.1.101

import Foundation

// using this struct to decode the json sent from python
struct PythonResponse: Codable { // has to match key and values of json sent by python
    let intent: String
    let reply: String
}

struct espResponse: Codable {
    let temperature: String
    let humidity: String
}

func sendCommandToPython(device: String, action: String) {
    let url = URL(string: "http://192.168.100.44:5000/sendCommand")!
    
    let body: [String: Any] = [ // Creating a dictionary for the data to send
        "device": device,
        "action": action
    ]
    
    let jsonData = try! JSONSerialization.data(withJSONObject: body, options: [])
    
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = jsonData
    
    // data is sent to python successfully
    
    // but we want python to send a feedback message so
    
    URLSession.shared.dataTask(with: request) { data, _, _ in // data, response, error are optional but we only want data
        
        if let data = data { // unwrapping if data is a string
            
            let response = String(data: data, encoding: .utf8)
            print("Python responded:", response ?? "")
        }
        
                  
    }.resume()
}

func sendToPython(dataToSend: String) {
    
    let url = URL(string: "http://192.168.100.44:5000/send")!
    
    let body: [String: Any] = [ // Creating a dictionary for the data to send
        "transcribedText": dataToSend // sending transcribed text to python
    ]
    
    let jsonData = try! JSONSerialization.data(withJSONObject: body, options: [])
    
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = jsonData
    
    // data is sent to python successfully
    
    // but we want python to send a feedback message so
    
    URLSession.shared.dataTask(with: request) { data, _, _ in // data, response, error are optional but we only want data
        
        if let data = data { // unwrapping if data is a string
            
            let response = String(data: data, encoding: .utf8)
            print("Python responded:", response ?? "")
        }
        
                  
    }.resume()
}

func getFromPython(completion: @escaping((intent: String, reply: String)) -> Void) {
    
    let url = URL(string: "http://192.168.100.44:5000/get")!
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
        
        if let data = data {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON from Python:", jsonString)
            }
            
            do { // decoding the data
                let response = try JSONDecoder().decode(PythonResponse.self, from: data)
                completion((intent: response.intent, reply: response.reply))
            } catch {
                print("Decoding failed:", error)
            }

        }
    }.resume()
}

func getSensorData(completion: @escaping((temperature: String, humidity: String)) -> Void) {
    
    let url = URL(string: "http://192.168.100.44:5000/getSensorData")!
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
        
        if let data = data {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON from Python:", jsonString)
            }
            
            do { // decoding the data
                let response = try JSONDecoder().decode(espResponse.self, from: data)
                completion((temperature: response.temperature, humidity: response.humidity))
            } catch {
                print("Decoding failed:", error)
            }

        }
    }.resume()
}
