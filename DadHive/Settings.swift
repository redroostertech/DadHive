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
    private var preferredCurrency: String?
    private var notifications: Bool?
    private var location: Location?
    private var maxDistance: Double?
    private var ageRange: AgeRange?
    private var initialSetup: Bool?

    required init?(map: Map) { }

    func mapping(map: Map) {
        preferredCurrency <- map["preferredCurrency"]
        notifications <- map["notifications"]
        location <- map["location"]
        maxDistance <- map["maxDistance"]
        ageRange <- map["ageRange"]
        initialSetup <- map["initialSetup"]
    }

    var userCurrency: String {
        return self.preferredCurrency ?? "USD"
    }

    var userNotifications: Bool {
        return self.notifications ?? false
    }

    var userMaximumDistancePreferences: Double {
        return self.maxDistance ?? 0
    }

    var userAgeRange: AgeRange? {
        return self.ageRange ?? nil
    }

    var userLocation: Location? {
        return self.location ?? nil
    }

    var userInitialState: Bool {
        return self.initialSetup ?? false
    }

    func setNotificationToggle(_ state: Bool) {
        self.notifications = state
        CurrentUser.shared.updateUser(withData: ["settings" : ["notifications" : state]]) { (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }
    }

    func setMaximumDistance(_ distance: Double) {
        self.maxDistance = distance
        CurrentUser.shared.updateUser(withData: ["settings" : ["maxDistance" : distance]]) { (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }
    }

    func setInitialState(_ state: Bool, _ completion: @escaping(Error?) -> Void) {
        self.initialSetup = state
        CurrentUser.shared.updateUser(withData: ["settings" : ["initialSetup" : state]]) { (error) in
            if error == nil {
                print("Successfully updated user data")
                completion(nil)
            } else {
                print("Did not update user data.")
                completion(error)
            }
        }
    }

}
