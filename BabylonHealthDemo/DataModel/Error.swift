//
//  Error.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 20/08/2017.
//  Copyright © 2017 Michael Brown. All rights reserved.
//

import Foundation

enum DataError: Error {
    case network(String)
    case parser(String)
    case persistence(String)
}
