//
//  AppsView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import SwiftUI
import RealmSwift

struct AppsView: View {
    
    @Binding private var selectedTab: Int
    @Binding private var previousTab: Int
    
    public init(selectedTab: Binding<Int>, previousTab: Binding<Int>, selectedElement: Binding<Element>) {
        self._selectedTab = selectedTab
        self._previousTab = previousTab
        self._selectedElement = selectedElement
    }
    
    @Binding private var selectedElement: Element
    
    
    @State private var isDetailViewActive = false
    
    private var dropboxManager = DropboxManager()
    private var networkManager = NetworkManager()
    
    @State private var searchText = ""
    
    @State private var accessToken = ""
    @State private var elements = [Element(id: "", Name: "", Title: "", imageName: "", description: "", favorite: false)]
    
    var results: [String] {
        if searchText.isEmpty {
            return elements.map { $0.Name }
        } else {
            return elements
                .map { $0.Name }
                .filter { $0.contains(searchText) }
        }
    }
    
    @State private var isLoaded = false
    
    @State private var isShowingAlert = false
    
    @State private var isRealmFileExists = false
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [.customLightGreen, .customDarkGreen], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack {
                Text("Apps")
                    .font(.system(size: 25))
                    .padding()
                
                HStack(alignment: .top) {
                  Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
                    TextField("Search", text: $searchText)
                }
                .foregroundColor(.blackWhite)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .overlay(
                  RoundedRectangle(cornerRadius: 7)
                    .stroke(.blackWhite, lineWidth: 1)
                )
                .background(.whiteBlack)
                .cornerRadius(7)
                .padding(.horizontal, 20)
                
                if results.isEmpty {
                    Text("No results found")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                if isLoaded {
                    
                    if isRealmFileExists {
                        
                        Spacer()
                        
                        categoriesList()
                        
                        Spacer()
                        
                    } else {
                        
                        Text("No data downloaded")
                            .foregroundColor(.gray)
                            .padding()
                        
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
            
            isRealmFileExists = checkRealmFileExistence()
            
            selectedTab = 0
            previousTab = 0
            
            isLoaded = false
            
            DispatchQueue.main.async {
                uploadData()
            }
            
            
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("No Internet Connection"),
                  message: Text("Please check your internet connection. You cannot download data."),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func categoriesList() -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<results.count, id: \.self) { index in
                    categoryButton(index: index)
                }
            }
            .padding()
        }
    }
    
    func categoryButton(index: Int) -> some View {
        
        
        Button(action: {
            selectedElement = elements[index]
            selectedTab = 4
            isDetailViewActive = true
        }) {
            ZStack {
                Rectangle()
                    .foregroundColor(.customGray)
                    .frame(width: 170, height: 50)
                    .cornerRadius(7)
                
                Text(self.results[index])
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
    }
    
    
    func receiveAccessToken() {
        if let receivedAccessToken = dropboxManager.getAccessToken(refreshToken: K.Dropbox.refreshToken, clientID: K.Dropbox.appKey, clientSecret: K.Dropbox.appSecret) {
            accessToken = receivedAccessToken
        } else {
            print("Failed to retrieve access token")
        }
    }
    
    func receiveData() {
        if let receivedElements = dropboxManager.getFile(path: K.Paths.dataJSONPath, accessToken: accessToken) {
            
            elements.removeAll()
            
            for tempElement in receivedElements {
                let element = Element(id: "", Name: tempElement.Name, Title: tempElement.Title, imageName: tempElement.imageName, description: tempElement.description, favorite: false)
                
                elements.append(element)
            }
            
            let prePath = "/"
            
            for element in elements {
                let path = element.imageName
                
                dropboxManager.getImage(path: prePath + path, accessToken: accessToken)
            }
        } else {
            print("Failed to get file")
        }
    }
    
    func saveElementsToRealm(_ elements: [Element]) {
        do {
            let realm = try Realm()
            
            try realm.write {
                
                let existingElements = realm.objects(RealmElement.self)
                realm.delete(existingElements)
                
                for element in elements {
                    let realmElement = RealmElement()
                    realmElement.name = element.Name
                    realmElement.title = element.Title
                    realmElement.imageName = element.imageName
                    realmElement.elementDescription = element.description
                    
                    realm.add(realmElement)
                }
            }
        } catch {
            print("Error saving elements to Realm: \(error)")
        }
    }
    
    func getElementsFromRealm() {
        
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
                returnElements.append(element)
            }
            
            elements = returnElements
        } catch {
            print("Error loading elements from Realm: \(error)")
        }
    }
    
    func uploadData() {
        
        if isRealmFileExists {
            
            getElementsFromRealm()
            
            isLoaded = true
            
        } else {
            
            networkManager.isInternetConnection { isConnected in
                if isConnected {
                    
                    receiveAccessToken()
                    receiveData()
                    
                    saveElementsToRealm(elements)
                    
                    getElementsFromRealm()
                    
                    isRealmFileExists = true
                    
                    isLoaded = true
                    
                } else {
                    
                    isLoaded = true
                    self.isShowingAlert = true
                }
            }
        }
        
        
    }
    
    private func checkRealmFileExistence() -> Bool {
        let realm = try! Realm()
        
        let fileObjects = realm.objects(RealmElement.self)
        
        return !fileObjects.isEmpty
    }
    
}



