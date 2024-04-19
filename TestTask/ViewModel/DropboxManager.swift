//
//  DropboxManager.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 08.04.2024.
//

import SwiftUI
import SwiftyDropbox

struct DropboxManager {
    
    func getAccessToken(refreshToken: String, clientID: String, clientSecret: String) -> String? {
        
        var returnAccessToken: String?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let url = URL(string: "https://api.dropbox.com/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        
        request.httpBody = parameters
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer {
                semaphore.signal()
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if response.statusCode == 200 {
                // Successful request, handle response data
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Parse JSON into Token struct
                    if let tokenType = json["token_type"] as? String,
                       let accessToken = json["access_token"] as? String,
                       let expiresIn = json["expires_in"] as? Int {
                        let token = Token(tokenType: tokenType, accessToken: accessToken, expiresIn: expiresIn)
                        
                        returnAccessToken = token.accessToken
                        
                    } else {
                        print("Failed to parse token output.")
                    }
                }
            } else {
                print("HTTP Status Code: \(response.statusCode)")
                if let responseData = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseData)")
                }
            }
        }
        
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return returnAccessToken
    }
    
    func getFile(path: String, accessToken: String) -> [TempElement]? {
        
        var returnElements: [TempElement]?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let url = URL(string: "https://content.dropboxapi.com/2/files/download")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("{\"path\":\"\(path)\"}", forHTTPHeaderField: "Dropbox-API-Arg")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer {
                semaphore.signal()
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if response.statusCode == 200 {
                // Convert data to JSON
                if let data = data {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        guard let jsonDict = jsonObject as? [String: Any], let dataArray = jsonDict["Data"] as? [[String: Any]] else {
                            print(NSError(domain: "InvalidDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
                            return
                        }
                        
                        let elements = dataArray.compactMap { TempElement(dictionary: $0) }
                        
                        returnElements = elements
                        
                    } catch {
                        print(error)
                    }
                } else {
                    print(NSError(domain: "NoDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data returned"]))
                }
            } else {
                print(NSError(domain: "HTTPError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Status Code: \(response.statusCode)"]))
            }
        }
        
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return returnElements
    }
    
    
    func downloadImageFromDropbox(path: String, accessToken: String, completion: @escaping ([MyImage]?, Error?) -> Void) {
        let url = URL(string: "https://content.dropboxapi.com/2/files/download")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("{\"path\":\"\(path)\"}", forHTTPHeaderField: "Dropbox-API-Arg")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                completion(nil, error ?? NSError(domain: "UnknownError", code: 0, userInfo: nil))
                return
            }
            
            if response.statusCode == 200 {
                // Convert data to UIImage or NSImage
                if let data = data, let image = UIImage(data: data) { // Or NSImage for macOS
                    let images = [MyImage(image: image)] // Assuming you're only dealing with one image
                    completion(images, nil)
                } else {
                    completion(nil, NSError(domain: "InvalidDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
                }
            } else {
                completion(nil, NSError(domain: "HTTPError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Status Code: \(response.statusCode)"]))
            }
        }
        
        task.resume()
    }
    
    func getImage(path: String, accessToken: String) {
        let semaphore = DispatchSemaphore(value: 0)
        
        let fileName = String(path.dropFirst())
        
        let url = URL(string: "https://content.dropboxapi.com/2/files/download")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("{\"path\":\"\(path)\"}", forHTTPHeaderField: "Dropbox-API-Arg")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                semaphore.signal()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("UnknownError")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        try data.write(to: self.getDocumentsDirectory().appendingPathComponent(fileName))
                        print("Image saved to: ",self.getDocumentsDirectory())
                    } catch {
                        print(error)
                    }
                } else {
                    print("InvalidDataError")
                }
            } else {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorSummary = json["error_summary"] as? String,
                   errorSummary == "path/not_found/" {
                    print("File not found")
                } else {
                    print("HTTPError: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }


    
    
}

