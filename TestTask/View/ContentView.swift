//
//  ContentView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 08.04.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab: Int = 0
    @State private var previousTab: Int = 0
    @State private var selectedElement: Element = Element(id: "", Name: "", Title: "", imageName: "", description: "", favorite: false)
    
    let tabItems = [
        TabItem(icon: "app.badge.fill", title: "Apps"),
        TabItem(icon: "sparkles.tv", title: "Games"),
        TabItem(icon: "heart.fill", title: "Favorites"),
        TabItem(icon: "align.vertical.top.fill", title: "Topics")
    ]
    
    var body: some View {
        
        VStack {
            
            switch selectedTab {
            case 0:
                AppsView(selectedTab: $selectedTab, previousTab: $previousTab, selectedElement: $selectedElement)
            case 1:
                GamesView(selectedTab: $selectedTab)
            case 2:
                FavoritesView(selectedTab: $selectedTab, previousTab: $previousTab, selectedElement: $selectedElement)
            case 3:
                TopicsView(selectedTab: $selectedTab)
            case 4:
                DetailView(selectedElement, selectedTab: $selectedTab, previousTab: $previousTab)
            default:
                EmptyView()
            }
            
            if selectedTab != 4 {
                Spacer()
                
                CustomTabBar(selectedTab: $selectedTab, tabItems: tabItems)
            }
            
        }
        
    }
}



#Preview {
    ContentView()
}

