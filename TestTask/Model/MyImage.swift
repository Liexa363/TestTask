//
//  MyImage.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import UIKit

struct MyImage {
    let image: UIImage
}

extension MyImage {
    init?(dictionary: [String: Any]) {
        guard let image = dictionary["image"] as? UIImage else { return nil }
        self.image = image
    }
}

