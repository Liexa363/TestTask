//
//  RealmElement.swift
//  TestTask
//
//  Created by Liexa MacBook Pro on 10.04.2024.
//

import Foundation
import RealmSwift

class RealmElement: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var title: String = ""
    @Persisted var imageName: String = ""
    @Persisted var elementDescription: String = ""
    @Persisted var favorite: Bool = false
}

