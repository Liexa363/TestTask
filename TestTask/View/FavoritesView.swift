//
//  FavoritesView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import SwiftUI
import RealmSwift

struct FavoritesView: View {
    
    @Binding private var selectedTab: Int
    @Binding private var previousTab: Int
    
    public init(selectedTab: Binding<Int>, previousTab: Binding<Int>, selectedElement: Binding<Element>) {
        self._selectedTab = selectedTab
        self._previousTab = previousTab
        self._selectedElement = selectedElement
    }
    
    @Binding private var selectedElement: Element
    
    @State private var isLoaded = false
    
    @State private var elements = [Element(id: "", Name: "", Title: "", imageName: "", description: "", favorite: false)]
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [.customLightGreen, .customDarkGreen], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack {
                Text("Favorites")
                    .font(.system(size: 25))
                    .padding()
                
                if isLoaded {
                    
                    if elements.isEmpty {
                        
                        Text("No favorites elements")
                            .foregroundColor(.gray)
                            .padding()
                        
                        Spacer()
                        
                    } else {
                        
                        Spacer()
                        
                        favoritesList()
                        
                        Spacer()
                    }
                    
                } else {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            
            selectedTab = 2
            previousTab = 2
            
            isLoaded = false
            
            DispatchQueue.main.async {
                getFavoritesFromRealm()
            }
            
            
        }
    }
    
    func favoritesList() -> some View {
        ScrollView {
            ForEach(0..<elements.count, id: \.self) { index in
                
                Button(action: {
                    selectedElement = elements[index]
                    selectedTab = 4
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.customGray)
                            .frame(height: 50)
                            .cornerRadius(7)
                        
                        Text(self.elements[index].Name)
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.white, lineWidth: 0.7)
                        .shadow(color: Color.black, radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                .padding(.vertical, 5)
                
            }
        }
    }
    
    func getFavoritesFromRealm() {
        
        do {
            let realm = try Realm()
            
            let realmElements = realm.objects(RealmElement.self)
            
            var returnElements: [Element] = []
            for realmElement in realmElements {
                let element = Element(id: realmElement._id.stringValue,
                                      Name: realmElement.name,
                                      Title: realmElement.title,
                                      imageName: realmElement.imageName,
                                      description: realmElement.elementDescription,
                                      favorite: realmElement.favorite)
                
                if element.favorite {
                    returnElements.append(element)
                }
            }
            
            elements = returnElements
            
            isLoaded = true
        } catch {
            print("Error loading elements from Realm: \(error)")
        }
    }
}

