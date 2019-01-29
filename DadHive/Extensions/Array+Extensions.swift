//
//  Array+Extensions.swift
//  test
//
//  Created by Michael Westbrooks on 11/14/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {
    var uniqueElementsInOrder: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

public extension Array where Element: Hashable {
    public func uniqueArray() -> Array {
        return Array(Set(self))
    }
}
