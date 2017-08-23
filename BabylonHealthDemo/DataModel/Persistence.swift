//
//  Persistence.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 14/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

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

func read(from localURL: URL) -> SignalProducer<Data, DataError> {
    return SignalProducer<Data, DataError> { observer, _ in
        do {
            let data = try Data(contentsOf: localURL)
            observer.send(value: data)
            observer.sendCompleted()
        } catch {
            observer.send(error: DataError.persistence(error.localizedDescription))
            observer.sendCompleted()
        }
    } 
}

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
