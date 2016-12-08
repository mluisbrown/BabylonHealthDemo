//
//  Comment.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 05/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct Comment {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

extension Comment: Decodable {
    static func decode(_ j: JSON) -> Decoded<Comment> {
        return curry(Comment.init)
            <^> j <| "id"
            <*> j <| "postId"
            <*> j <| "name"
            <*> j <| "email"
            <*> j <| "body"
    }
}
