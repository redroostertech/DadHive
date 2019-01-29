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
    private var preferredCurrency: Any?
    private var notifications: Any?
    private var location: Any?
    private var maxDistance: Any?
    private var ageRange: Any?

    required init?(map: Map) { }

    func mapping(map: Map) {
        preferredCurrency <- map["preferredCurrency"]
        notifications <- map["notifications"]
        location <- map["location"]
        maxDistance <- map["maxDistance"]
        ageRange <- map["ageRange"]
    }

    var userCurrency: String {
        guard let preferredCurrency = self.preferredCurrency as? String else {
            return "USD"
        }
        return preferredCurrency
    }

    var userNotifications: Bool {
        guard let notifications = self.notifications as? Bool else {
            return false
        }
        return notifications
    }

    var userLocation : String {
        guard let userLocation = self.location as? String else {
            return ""
        }
        return userLocation
    }

    var userAgeRangePreferences: String {
        guard let ageRange = self.ageRange as? [String : Any] else {
            return ""
        }
        return "\(ageRange["min"] ?? 0) to \(ageRange["max"] ?? 0) years old"
    }

    var userMaximumDistancePreferences: Int {
        guard let maxDistance = self.maxDistance as? Int else {
            return 0
        }
        return maxDistance
    }

    func setNotificationToggle(_ state: Bool) {
        self.notifications = state
        FIRFirestoreDB.shared.update(withData: ["settings" : ["notifications" : state]], from: kUsers, at: "\(CurrentUser.shared.user?.userKey ?? "")") {
            (success, error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }

//        FIRRealtimeDB.shared.update(withData: ["notifications" : state], atChild: "users/\(CurrentUser.shared.user?.userKey ?? "")/settings") {
//            (success, results, error) in
//            if error == nil {
//                print("Successfully updated user data")
//            } else {
//                print("Didnot update user data.")
//            }
//        }
    }

    func setMaximumDistance(_ distance: Int) {
        self.maxDistance = distance
        FIRFirestoreDB.shared.update(withData: ["settings" : ["maxDistance" : distance]], from: kUsers, at: "\(CurrentUser.shared.user?.userKey ?? "")") {
            (success, error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }

        //        FIRRealtimeDB.shared.update(withData: ["notifications" : state], atChild: "users/\(CurrentUser.shared.user?.userKey ?? "")/settings") {
        //            (success, results, error) in
        //            if error == nil {
        //                print("Successfully updated user data")
        //            } else {
        //                print("Didnot update user data.")
        //            }
        //        }
    }

    func setAgeRange(_ ageRange: [String: Any]) {
        self.ageRange = ageRange
        FIRFirestoreDB.shared.update(withData: ["settings" : ["ageRange" : ageRange]], from: kUsers, at: "\(CurrentUser.shared.user?.userKey ?? "")") {
            (success, error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }

        //        FIRRealtimeDB.shared.update(withData: ["notifications" : state], atChild: "users/\(CurrentUser.shared.user?.userKey ?? "")/settings") {
        //            (success, results, error) in
        //            if error == nil {
        //                print("Successfully updated user data")
        //            } else {
        //                print("Didnot update user data.")
        //            }
        //        }
    }

}
