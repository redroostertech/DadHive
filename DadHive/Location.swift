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

    var latitude: Any?
    var longitude: Any?
    var city: Any?
    var state: Any?
    var description: Any?
    var country: Any?

    required init?(map: Map) { }

    func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        city <- map["city"]
        state <- map["state"]
        description <- map["description"]
        country <- map["country"]
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

    var userLocation: String {
        return "\(city ?? ""), \(state ?? "")"
    }

    func setLocation(_ completion: @escaping(Error?)->Void) {
        CurrentUser.shared.updateUser(withData: ["settings" : ["location" : self.toDict]]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
                completion(nil)
            } else {
                print(error!.localizedDescription)
                completion(error!)
            }
        }

    }

}
