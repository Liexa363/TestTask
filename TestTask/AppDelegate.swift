//
//  AppDelegate.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 09.04.2024.
//

import UIKit
import SwiftyDropbox
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        DropboxClientsManager.setupWithAppKey(K.Dropbox.appKey)
        
        do {
            _ = try Realm()
        } catch {
            print("Error with inialization Realm: \(error)")
        }
        
        return true
    }
    
}
