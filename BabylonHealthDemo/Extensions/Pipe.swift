//
//  Pipe.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 22/08/2017.
//  Copyright © 2017 Michael Brown. All rights reserved.
//

import Foundation

precedencegroup PipePrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |> : PipePrecedence

public func |> <T, U>(x: T, f: (T) -> U) -> U {
    return f(x)
}
