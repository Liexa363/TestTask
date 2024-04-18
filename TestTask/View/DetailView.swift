//
//  DetailView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import SwiftUI

struct DetailView: View {
    
    @Binding private var selectedTab: Int
    
    init(_ selectedElement: Element, selectedTab: Binding<Int>) {
        self.selectedElement = selectedElement
        self._selectedTab = selectedTab
    }
    
    let selectedElement: Element
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var offset = CGSize.zero
    
    @State private var isLoaded = false
    
    @State private var isShowingAlert = false
    
    private var dropboxManager = DropboxManager()
    private var networkManager = NetworkManager()
    
    @State private var accessToken = ""
    @State private var image: MyImage?
    
    @State var downloadedImage: Image?
    
    @State private var isLoading = false
    @State private var isContentAppeared = false
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(colors: [.customLightGreen, .customDarkGreen], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack {
                
                HStack {
                    Button(action: {
                        selectedTab = 0
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
            
            UITabBar.appearance().isHidden = true
            
            isContentAppeared = false
            isLoading = true
            
            isLoaded = false
            
            DispatchQueue.main.async {
                checkInternetConnectionAndDownloadData()
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
                        }
                    }
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("No Internet Connection"),
                          message: Text("Please check your internet connection. A photo will not be uploaded"),
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
                    
                    // add to favorites and save it to Realm
                    
                }) {
                    HStack {
                        Text("Favorite")
                            .foregroundColor(.white)
                        
                        Image(systemName: "heart")
                            .foregroundColor(.customRed)
                    }
                }
                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                .background(.customGray)
                .cornerRadius(10)
                
            }
            .padding(.all, 10)
            .onAppear {
                
                isContentAppeared = false
                isLoading = true
                
                DispatchQueue.main.async {
                    
                    if let image = image {
                        downloadedImage = Image(uiImage: image.image)
                        isLoading = false
                    } else {
                        print("Error downloading image")
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    func receiveAccessToken() {
        if let receivedAccessToken = dropboxManager.getAccessToken(refreshToken: K.Dropbox.refreshToken, clientID: K.Dropbox.appKey, clientSecret: K.Dropbox.appSecret) {
            accessToken = receivedAccessToken
        } else {
            print("Failed to retrieve access token")
        }
    }
    
    func receiveImage(path: String) {
        
        let prePath = "/"
        
        if let receivedImages = dropboxManager.getImage(path: prePath + path, accessToken: accessToken) {
            image = receivedImages.first!
        } else {
            print("Failed to get image")
        }
    }
    
    func checkInternetConnectionAndDownloadData() {
        networkManager.isInternetConnection { isConnected in
            if isConnected {
                
                receiveAccessToken()
                receiveImage(path: selectedElement.imageName)
                
                isLoaded = true
                
            } else {
                
                downloadedImage = Image(systemName: "photo")
                
                isLoaded = true
                self.isShowingAlert = true
            }
        }
    }
    
}

