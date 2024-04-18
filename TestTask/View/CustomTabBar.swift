//
//  CustomTabBar.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 18.04.2024.
//

import SwiftUI

struct CustomTabBar: View {
    
    @Binding var selectedTab: Int
    let tabItems: [TabItem]
    
    var body: some View {
        HStack {
            
            Spacer()
            
            ForEach(tabItems.indices, id: \.self) { index in
                TabBarItem(
                    item: tabItems[index],
                    isSelected: index == selectedTab,
                    onTap: {
                        selectedTab = index
                    }
                )
                Spacer()
            }
        }
        
    }
}

struct TabItem {
    let icon: String
    let title: String
}

struct TabBarItem: View {
    let item: TabItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blackWhite : .gray)
                
                Text(item.title)
                    .font(.system(size: 15))
                    .foregroundColor(isSelected ? .blackWhite : .gray)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
    }
}
