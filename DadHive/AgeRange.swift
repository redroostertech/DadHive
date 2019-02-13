//
//  AgeRange.swift
//  DadHive
//
//  Created by Michael Westbrooks on 2/11/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class AgeRange: Mappable, CustomStringConvertible {
    var min: Double?
    var max: Double?

    required init?(map: Map) { }

    func mapping(map: Map) {
        min <- map["min"]
        max <- map["max"]
    }

    var userAgeRangePreferences: String? {
        return "\(min ?? 0) to \(max ?? 0) years old"
    }

    func setAgeRange() {
        CurrentUser.shared.updateUser(withData: ["settings" : ["ageRange" : self]]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }
    }
}

