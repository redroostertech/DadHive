//
//  Info.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Info: Mappable, CustomStringConvertible {
    var type: String?
    var info: String?
    var title: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        type <- map["type"]
        info <- map["info"]
        title <- map["title"]
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

