//
//  Settings.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Settings: Mappable, CustomStringConvertible {

    var preferredCurrency: String?
    var notifications: Bool?
    var location: Location?
    var maxDistance: Double?
    var ageRange: AgeRange?
    var initialSetup: Bool?

    required init?(map: Map) { }

    func mapping(map: Map) {
        preferredCurrency <- map["preferredCurrency"]
        notifications <- map["notifications"]
        location <- map["location"]
        maxDistance <- map["maxDistance"]
        ageRange <- map["ageRange"]
        initialSetup <- map["initialSetup"]
    }

}
