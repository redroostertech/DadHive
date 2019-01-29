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
    
    private var firstName: Any?
    private var lastName: Any?
    private var fullName: Any?

    var toDict: [String: Any] {
        let dict = [
            "fullName": self.fullName
        ]
        return dict
    }

    required init?(map: Map) { }

    func mapping(map: Map) {
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        fullName <- map["fullName"]
    }

    var userFirstName: String {
        return (self.firstName as? String) ?? ""
    }

    var userLastName: String {
        return (self.lastName as? String) ?? ""
    }

    var userFullName: String {
        return (self.fullName as? String) ?? ""
    }

}
