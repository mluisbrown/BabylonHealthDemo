//
//  Persistence.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 14/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Result

struct LocalResource {
    static let users = documentURL(with: "users.json")
    static let posts = documentURL(with: "posts.json")
    
    private static func documentURL(with filename: String) -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        let path = URL(fileURLWithPath: documentsDirectory, isDirectory: true).appendingPathComponent(filename)
        
        return path
    }
}

//func loadCollection<T: Decodable>(from localURL: URL) -> [T] {
//    guard let data = try? Data(contentsOf: localURL) else {
//        return []
//    }
//    
//    let decoded: Result<[T], NetworkError> = parseArray(from: data)
//    
//    switch decoded {
//    case .success(let collection):
//        return collection
//    case .failure:
//        return []
//    }
//}

func write<T: Encodable>(collection: [T], to localURL: URL) throws {
    do {
        let data: Data = try JSONEncoder().encode(collection)
        try data.write(to: localURL, options: .atomic)
    }
    catch {
        NSLog("Error writing collection to local storage: \(error)")
        throw error
    }
}
