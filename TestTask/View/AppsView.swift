//
//  AppsView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import SwiftUI
import RealmSwift

struct AppsView: View {
    
    @State private var isDetailViewActive = false
    
    private var dropboxManager = DropboxManager()
    private var networkManager = NetworkManager()
    
    @State private var searchText = ""
    
    @State private var accessToken = ""
    @State private var elements = [Element(Name: "", Title: "", imageName: "", description: "")]
    
    @State private var selectedElement = Element(Name: "", Title: "", imageName: "", description: "")
    
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
    
    var body: some View {
        NavigationView {
            VStack {
                
                if results.isEmpty {
                    Text("No results found")
                        .foregroundColor(.gray)
                }
                
                if isLoaded {
                    Spacer()
                    
                    categoriesList()
                } else {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
            .navigationTitle("Apps")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            
            isLoaded = false
            
            DispatchQueue.main.async {
                checkInternetConnectionAndDownloadData()
            }
            
            
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("No Internet Connection"),
                  message: Text("Please check your internet connection. You will get not updated data if you login earlier."),
                  dismissButton: .default(Text("OK")))
        }
        .tag(1)
        .searchable(text: $searchText)
    }
    
    func categoriesList() -> some View {
        List {
            ForEach(results.indices, id: \.self) { rowIndex in
                HStack {
                    ForEach(0..<2) { columnIndex in
                        let index = rowIndex * 2 + columnIndex
                        if index < self.results.count {
                            categoryButton(index: index)
                        } else {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
        }
    }
    
    func categoryButton(index: Int) -> some View {
        Button(action: {
            isDetailViewActive = true
            selectedElement = elements[index]
        }) {
            ZStack {
                Rectangle()
                    .foregroundColor(Color.black)
                    .frame(width: 150, height: 50)
                    .cornerRadius(10)
                
                Text(self.results[index])
                    .foregroundColor(Color.white)
                    .font(.system(size: 15))
                    .fontWeight(.bold)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            NavigationLink("", destination: DetailView(selectedElement), isActive: $isDetailViewActive).hidden())
    }
    
    
    func receiveAccessToken() {
        if let receivedAccessToken = dropboxManager.getAccessToken(refreshToken: K.Dropbox.refreshToken, clientID: K.Dropbox.appKey, clientSecret: K.Dropbox.appSecret) {
            accessToken = receivedAccessToken
        } else {
            print("Failed to retrieve access token")
        }
    }
    
    func receiveElements() {
        if let receivedElements = dropboxManager.getFile(path: K.Paths.dataJSONPath, accessToken: accessToken) {
            elements = receivedElements
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
                let element = Element(Name: realmElement.name,
                                      Title: realmElement.title,
                                      imageName: realmElement.imageName,
                                      description: realmElement.elementDescription)
                returnElements.append(element)
            }
            
            elements = returnElements
        } catch {
            print("Error loading elements from Realm: \(error)")
        }
    }
    
    func checkInternetConnectionAndDownloadData() {
        networkManager.isInternetConnection { isConnected in
            if isConnected {
                
                receiveAccessToken()
                receiveElements()
                
                saveElementsToRealm(elements)
                
                isLoaded = true
                
            } else {
                
                getElementsFromRealm()
                
                isLoaded = true
                self.isShowingAlert = true
            }
        }
    }
    
}



