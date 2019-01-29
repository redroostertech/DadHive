//
//  Global+Functions.swift
//  test
//
//  Created by Michael Westbrooks on 10/13/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import UIKit

func set(_ value: String?) -> String {
    guard let value = value else {
        return ""
    }
    return value
}

func set(_ value: Double?) -> Double {
    guard let value = value else {
        return 0.0
    }
    return value
}

func set(_ value: Int?) -> Int {
    guard let value = value else {
        return 0
    }
    return value
}

func set(_ value: UIImage?) -> UIImage {
    guard let value = value else {
        return UIImage(named: "placeholder")!
    }
    return value
}

func set(_ value: UIColor?) -> UIColor {
    guard let value = value else {
        return UIColor.white
    }
    return value
}

