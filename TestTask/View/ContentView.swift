//
//  ContentView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 08.04.2024.
//

import SwiftUI
import SwiftyDropbox

struct ContentView: View {
    
    @State private var selectedTab: Int = 0
    
    @State private var isLoaded = true
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            if isLoaded {
                
                NavigationView {
                    AppsView()
                }
                .tabItem {
                    Image(systemName: "a.square")
                    Text("Apps")
                }
                
                NavigationView {
                    GamesView()
                }
                .tabItem {
                    Image(systemName: "g.square")
                    Text("Games")
                }
                
                NavigationView {
                    FavoritesView()
                }
                .tabItem {
                    Image(systemName: "f.square")
                    Text("Favorites")
                }
                
                NavigationView {
                    TopicsView()
                }
                .tabItem {
                    Image(systemName: "t.square")
                    Text("Topics")
                }
                
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
        }
    }
    
}

#Preview {
    ContentView()
}

