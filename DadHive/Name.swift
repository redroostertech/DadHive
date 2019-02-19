//
//  Name.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Name: Mappable {
    
    var fullName: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        fullName <- map["name"]
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

}
