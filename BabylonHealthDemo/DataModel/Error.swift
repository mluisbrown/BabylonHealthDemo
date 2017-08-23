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
    case data(String)
}

extension DataError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case let .network(message),
             let .parser(message),
             let .persistence(message),
             let .data(message):
            return message
        }
    }
}

func decodingErrorDescription(_ error: Error) -> String {
    switch error {
    case DecodingError.dataCorrupted(let context), 
         DecodingError.keyNotFound(_, let context), 
         DecodingError.typeMismatch(_, let context):
        return context.debugDescription
    default:
        return error.localizedDescription
    }
}
