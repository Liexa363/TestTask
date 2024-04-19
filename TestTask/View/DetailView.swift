//
//  DetailView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import SwiftUI
import RealmSwift

struct DetailView: View {
    
    @Binding private var selectedTab: Int
    @Binding private var previousTab: Int
    
    init(_ selectedElement: Element, selectedTab: Binding<Int>, previousTab: Binding<Int>) {
        self.selectedElement = selectedElement
        self._selectedTab = selectedTab
        self._previousTab = previousTab
    }
    
    let selectedElement: Element
    
    @State private var isFavorite = false
    
    @State private var offset = CGSize.zero
    
    @State private var isLoaded = false
    
    @State private var isErrorDownloadingImage = false
    
    private var dropboxManager = DropboxManager()
    
    @State private var image: MyImage?
    @State var downloadedImage: Image?
    
    @State private var isLoading = false
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(colors: [.customLightGreen, .customDarkGreen], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack {
                
                HStack {
                    Button(action: {
                        selectedTab = previousTab
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.customGray)
                                .cornerRadius(7)
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Text(selectedElement.Name)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        // download button
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.customGray)
                                .cornerRadius(7)
                            Image(systemName: "square.and.arrow.down.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top)
                
                Spacer()
                
                if isLoaded {
                    SquareView()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 80)
                        .foregroundColor(.customGreen)
                } else {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                Spacer()
            }
        }
        .onAppear {
            
            isFavorite = selectedElement.favorite
            
            UITabBar.appearance().isHidden = true
            
            isLoading = true
            
            isLoaded = false
            
            DispatchQueue.main.async {
                receiveImage()
            }
            
            
        }
        .gesture(DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                if value.translation.width > 100 {
                    selectedTab = 0
                }
                offset = .zero
            }
        )
        
        
        
    }
    
    func SquareView() -> some View {
        
        ZStack {
            Rectangle()
                .cornerRadius(10)
            
            VStack {
                
                HStack {
                    if isLoading {
                        HStack {
                            ProgressView("")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .foregroundColor(.black)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 60)
                    } else {
                        if let image = downloadedImage {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(7)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .foregroundColor(.gray)
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .alert(isPresented: $isErrorDownloadingImage) {
                    Alert(title: Text("Error downloading image"),
                          message: Text("Image is not found."),
                          dismissButton: .default(Text("OK")))
                }
                
                HStack {
                    Text(selectedElement.Title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.customGray)
                    
                    Spacer()
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text(selectedElement.description)
                        .font(.headline)
                        .foregroundColor(.customGray)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                }
                
                Spacer()
                
                Button(action: {
                    
                    addToFavorites()
                    
                }) {
                    HStack {
                        Text("Favorite")
                            .foregroundColor(.white)
                        
                        if isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.customRed)
                        } else {
                            Image(systemName: "heart")
                                .foregroundColor(.customRed)
                        }
                    }
                }
                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                .background(.customGray)
                .cornerRadius(10)
                
            }
            .padding(.all, 10)
            .onAppear {
                
                isLoading = true
                
                DispatchQueue.main.async {
                    
                    if let image = image {
                        downloadedImage = Image(uiImage: image.image)
                        isLoading = false
                    } else {
                        downloadedImage = nil
                        isLoading = false
                        print("Error downloading image")
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    func receiveImage() {
        
        let fileName = selectedElement.imageName
        
        if let loadedImage = UIImage(contentsOfFile: self.getDocumentsDirectory().appendingPathComponent(fileName).path) {
            image = MyImage(image: loadedImage)
            
            isLoaded = true
        } else {
            image = nil
            print("Failed to get image")
            
            isLoaded = true
            
            self.isErrorDownloadingImage = true
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func addToFavorites() {
        
        do {
            let realm = try Realm()
            
            let id = try ObjectId(string: selectedElement.id)
            
            if let objectToUpdate = realm.object(ofType: RealmElement.self, forPrimaryKey: id) {
                
                try! realm.write {
                    objectToUpdate.favorite.toggle()
                }
                
                isFavorite.toggle()
            } else {
                print("Error with searching object in Realm")
            }
        } catch {
            print("Error with updating object in Realm")
        }
        
    }
    
}

