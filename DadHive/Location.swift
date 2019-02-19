//
//  Location.swift
//  DadHive
//
//  Created by Michael Westbrooks on 2/8/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Location: Mappable, CustomStringConvertible {

    var latitude: Double?
    var longitude: Double?
    var city: String?
    var state: String?
    var description: String?
    var country: String?
    var addressLine1: String?
    var addressLine2: String?
    var addressLine3: String?
    var addressLine4: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        city <- map["city"]
        state <- map["state"]
        description <- map["description"]
        country <- map["country"]
        addressLine1 <- map["addressLine1"]
        addressLine2 <- map["addressLine2"]
        addressLine3 <- map["addressLine3"]
        addressLine4 <- map["addressLine4"]
    }

    public var toDict: [String: Any] {
        var dictionary: [String: Any] = [String: Any]()
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                dictionary[propertyName] = child.value
            }
        }
        return dictionary
    }

    var getString: String? {
        if let city = self.city, let state = self.state {
            return city + ", " + state
        } else {
            return nil
        }
    }
}
