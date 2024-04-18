//
//  TopicsView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import SwiftUI

struct TopicsView: View {
    
    @Binding private var selectedTab: Int
    
    public init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                LinearGradient(colors: [.customLightGreen, .customDarkGreen], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack {
                    Text("Topics")
                        .font(.system(size: 25))
                        .padding()
                    
                    Spacer()
                    
                }
            }
        }
    }
}

