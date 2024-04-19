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
    
    @State private var isErrorDownloadingImage = false
    
    private var dropboxManager = DropboxManager()
    private var networkManager = NetworkManager()
    
    @State private var accessToken = ""
    
    @State private var isNoInternetConnection = false
    @State private var isSuccessfulDownloadingImage = false
    
    @State private var image: MyImage?
    @State var downloadedImage: Image?
    
    @State private var isLoading = true
    
    @State private var isImageExist = false
    
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
                    .alert(isPresented: $isNoInternetConnection) {
                        Alert(title: Text("No Internet Connection"),
                              message: Text("Please check your internet connection. You cannot download image."),
                              dismissButton: .default(Text("OK")))
                    }
                    
                    Spacer()
                    
                    Text(selectedElement.Name)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if isImageExist {
                        
                        if let downloadedImage {
                            if #available(iOS 16.0, *) {
                                ShareLink(item: downloadedImage, 
                                          preview: SharePreview(selectedElement.imageName,
                                          image: downloadedImage)) {
                                    
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
                        }
                        
                    } else {
                        Button(action: {
                            downloadImage()
                            
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
                        .alert(isPresented: $isErrorDownloadingImage) {
                            Alert(title: Text("Error downloading image"),
                                  message: Text("Image is not found."),
                                  dismissButton: .default(Text("OK")))
                        }
                    }
                    
                    
                }
                .onAppear {
                    
                    let fileName = selectedElement.imageName
                    
                    isImageExist = fileExists(at: fileName)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top)
                
                Spacer()
                
                SquareView()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 80)
                    .foregroundColor(.customGreen)
                
                Spacer()
            }
        }
        .onAppear {
            
            isFavorite = selectedElement.favorite
            
            UITabBar.appearance().isHidden = true
            
            isLoading = true
            
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
                    selectedTab = previousTab
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
                .alert(isPresented: $isSuccessfulDownloadingImage) {
                    Alert(title: Text("Success"),
                          message: Text("Image successfully downloaded."),
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
                
            }
        }
        
    }
    
    func receiveImage() {
        
        let prePath = "/"
        
        let fileName = selectedElement.imageName
        
        let isImageExist = fileExists(at: fileName)
        
        if isImageExist {
            
            if let loadedImage = UIImage(contentsOfFile: self.getDocumentsDirectory().appendingPathComponent(fileName).path) {
                image = MyImage(image: loadedImage)
                
                if let image = image {
                    
                    downloadedImage = Image(uiImage: image.image)
                    
                    isLoading = false
                } else {
                    downloadedImage = nil
                    
                    isLoading = false
                    
                    self.isErrorDownloadingImage = true
                }
                
            } else {
                
                downloadedImage = nil
                print("Failed to get image")
                
                isLoading = false
                
                self.isErrorDownloadingImage = true
            }
            
        } else {
            networkManager.isInternetConnection { isConnected in
                if isConnected {
                    
                    receiveAccessToken()
                    
                    image = dropboxManager.getImageFromDropbox(path: prePath + fileName, accessToken: accessToken)
                    
                    if let image = image {
                        
                        downloadedImage = Image(uiImage: image.image)
                        
                        isLoading = false
                    } else {
                        downloadedImage = nil
                        print("Error downloading image")
                        
                        
                        self.isErrorDownloadingImage = true
                        isLoading = false
                    }
                    
                    
                } else {
                    
                    downloadedImage = nil
                    print("Error downloading image")
                    
                    isLoading = false
                    
                    self.isNoInternetConnection = true
                }
            }
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
    
    func receiveAccessToken() {
        if let receivedAccessToken = dropboxManager.getAccessToken(refreshToken: K.Dropbox.refreshToken, clientID: K.Dropbox.appKey, clientSecret: K.Dropbox.appSecret) {
            accessToken = receivedAccessToken
        } else {
            print("Failed to retrieve access token")
        }
    }
    
    func downloadImage() {
        
        let prePath = "/"
        
        let fileName = selectedElement.imageName
        
        networkManager.isInternetConnection { isConnected in
            if isConnected {
                
                receiveAccessToken()
                
                dropboxManager.getImage(path: prePath + fileName, accessToken: accessToken)
                
                isImageExist = fileExists(at: fileName)
                
                if isImageExist {
                    
                    receiveImage()
                    
                    self.isSuccessfulDownloadingImage = true
                    
                } else {
                    self.isErrorDownloadingImage = true
                }
                
            } else {
                
                self.isNoInternetConnection = true
                
            }
        }
        
    }
    
    private func fileExists(at fileName: String) -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    
    
}

