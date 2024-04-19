//
//  TempElement.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 19.04.2024.
//

import Foundation

struct TempElement {
    let Name: String
    let Title: String
    let imageName: String
    let description: String
}

extension TempElement: Codable {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["Name"] as? String,
              let title = dictionary["Title"] as? String,
              let description = dictionary["description"] as? String,
              let imageName = dictionary["imageName"] as? String else {
            return nil
        }
        self.Name = name
        self.Title = title
        self.description = description
        self.imageName = imageName
    }
}

