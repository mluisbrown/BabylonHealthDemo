//
//  Collection.swift
//  BabylonHealthDemo
//
//  Created by Michael Brown on 14/12/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import Foundation

extension Collection {
    
    func dictionary<U: Hashable>(withKey keyGenerator: (Iterator.Element) -> U) -> [U : Iterator.Element] {
        var result: [U : Iterator.Element] = .init(minimumCapacity: underestimatedCount)
        forEach { result[keyGenerator($0)] = $0 }
        return result
    }
}
