//
//  User.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 05/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
