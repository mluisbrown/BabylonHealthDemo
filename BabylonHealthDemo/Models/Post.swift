//
//  Post.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 05/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct Post {
    let id: Int
    let userId: Int
    let title: String
    let body: String
    var comments: [Comment]?
}

extension Post: Decodable {
    static func decode(_ j: JSON) -> Decoded<Post> {
        return curry(Post.init)
            <^> j <| "id"
            <*> j <| "userId"
            <*> j <| "title"
            <*> j <| "body"
            <*> .success(nil)
    }
}
