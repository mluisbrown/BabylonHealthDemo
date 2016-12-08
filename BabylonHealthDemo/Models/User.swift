//
//  User.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 05/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct User {
    let id: Int
    let name: String
}

extension User: Decodable {
    static func decode(_ j: JSON) -> Decoded<User> {
        return curry(User.init)
            <^> j <| "id"
            <*> j <| "name"
    }
}
