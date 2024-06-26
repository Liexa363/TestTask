//
//  Element.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 09.04.2024.
//

import Foundation

struct Element {
    let id: String
    let Name: String
    let Title: String
    let imageName: String
    let description: String
    let favorite: Bool
}

extension Element: Codable {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["Name"] as? String,
              let title = dictionary["Title"] as? String,
              let description = dictionary["description"] as? String,
              let imageName = dictionary["imageName"] as? String,
              let favorite = dictionary["favorite"] as? Bool else {
            return nil
        }
        self.id = id
        self.Name = name
        self.Title = title
        self.description = description
        self.imageName = imageName
        self.favorite = favorite
    }
}

