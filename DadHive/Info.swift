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
    private var type: Any?
    private var info: Any?

    required init?(map: Map) { }

    func mapping(map: Map) {
        type <- map["type"]
        info <- map["info"]
    }

    var userInfoType: String {
        return (self.type as? String) ?? ""
    }

    var userInfo: String {
        return (self.info as? String) ?? ""
    }
}

