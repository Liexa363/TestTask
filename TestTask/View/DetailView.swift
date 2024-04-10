//
//  DetailView.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import SwiftUI

struct DetailView: View {
    
    init(_ selectedElement: Element) {
        self.selectedElement = selectedElement
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
        
        NavigationView {
            
            if isLoaded {
                SquareView()
                    .padding()
                    .foregroundColor(Color.gray)
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            
        }
        .navigationBarTitle(selectedElement.Name)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward.square")
                .foregroundColor(.black)
        })
        .navigationBarItems(trailing: Button(action: {
            
            // Action for the custom navigation bar item
            
        }) {
            Image(systemName: "arrow.down.square")
                .foregroundColor(.black)
        })
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 50)
        .onAppear {
            
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
                    presentationMode.wrappedValue.dismiss()
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
                                .foregroundColor(.white)
                                .padding()
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
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                
                HStack {
                    Text(selectedElement.description)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    
                    // add to favorites and save it to Realm
                    
                }) {
                    HStack {
                        Text("Favorite")
                            .foregroundColor(.white)
                        
                        Image(systemName: "heart")
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                .background(.black)
                .cornerRadius(10)
                .padding()
                
            }
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

