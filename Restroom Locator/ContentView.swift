// ContentView.swift

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapTabView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            NearestRestroomView()
                .tabItem {
                    Image(systemName: "location")
                    Text("Nearest Restroom")
                }
        }
    }
}

