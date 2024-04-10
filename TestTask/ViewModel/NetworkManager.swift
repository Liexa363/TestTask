//
//  NetworkManager.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import Foundation
import Network

struct NetworkManager {
    func isInternetConnection(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
