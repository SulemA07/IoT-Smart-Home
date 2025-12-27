//
//  ContentView.swift
//  IoTHome
//
//  Created by Suleman Akram on 09/12/2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var features: IoTHomeFeatures
    init(features: IoTHomeFeatures) {
        _features = StateObject(wrappedValue: features)
        
        UITabBar.appearance().tintColor = UIColor.systemRed
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    

    var body: some View {
        
        
            TabView {
                Home(features: features).tabItem {
                    Image(systemName: "house")
                    Text("Home")
                    
                }
                ClimateControl(IoTHomeFeatures: features).tabItem {
                    Image(systemName: "cloud.sun.fill")
                    Text("Climate Control")
                }
            }
        

        

    } // end of body

        
}// end of struct
    


#Preview {
    ContentView(features: IoTHomeFeatures())
}
