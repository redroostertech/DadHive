//
//  User.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/17/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable, CustomStringConvertible {

    private var key: Any?
    private var uid: Any?
    private var id: Any?
    private var type: Any?
    private var email: Any?
    private var createdAt: Any?
    private var refCode: Any?

    var name: Name?
    var userInformation: [Info]?
    var userDetails: [Info]?
    var profilePictures: [Media]?
    var profileCreation: Bool?
    var userCanSwipe: Bool?
    private var paymentMethod: PaymentMethod?
    private var settings: Settings?

    private var rawName: Any? {
        didSet {
            guard let name = self.rawName as? [String : Any] else {
                return
            }
            self.name = Name(JSON: name)
        }
    }

    private var rawSettings: Any? {
        didSet {
            guard let rawSettings = self.rawSettings as? [String : Any] else {
                return
            }
            self.settings = Settings(JSON: rawSettings)
        }
    }

    private var rawPaymentMethod: Any? {
        didSet {
            guard let rawPaymentMethod = self.rawPaymentMethod as? [String : Any] else {
                return
            }
            self.paymentMethod = PaymentMethod(JSON: rawPaymentMethod)
        }
    }

    private var userInformationArray: Any? {
        didSet {
            guard let userInformationArray = self.userInformationArray as? [String : Any] else {
                return
            }
            var emptyUserInformationArray = [Info]()
            for key in userInformationArray.keys {
                guard let item = userInformationArray[key] as? [String: Any], let obj = Info(JSON: item) else {
                    return
                }
                emptyUserInformationArray.append(obj)
            }
            self.userInformation = emptyUserInformationArray
        }
    }

    private var userDetailsArray: Any? {
        didSet {
            guard let userDetailsArray = self.userDetailsArray as? [[String : Any]] else {
                return
            }
            var emptyUserDetailsArray = [Info]()
            for userDetail in userDetailsArray {
                guard let obj = Info(JSON: userDetail) else {
                    return
                }
                emptyUserDetailsArray.append(obj)
            }
            self.userDetails = emptyUserDetailsArray
        }
    }

    private var mediaArray: Any? {
        didSet {
            guard let mediaArray = self.mediaArray as? [[String : Any]] else {
                return
            }
            var emptyMediaArray = [Media]()
            for media in mediaArray {
                guard let obj = Media(JSON: media) else {
                    return
                }
                emptyMediaArray.append(obj)
            }
            self.profilePictures = emptyMediaArray
        }
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        key <- map["snapshotKey"]
        uid <- map["uid"]
        id <- map["id"]
        type <- map["type"]
        email <- map["email"]
        createdAt <- map["createdAt"]
        mediaArray <- map["mediaArray"]
        rawName <- map["name"]
        userInformationArray <- map["userInformation"]
        userDetailsArray <- map["userDetails"]
        rawSettings <- map["settings"]
        rawPaymentMethod <- map["paymentMethod"]
        refCode <- map["refCode"]
        profileCreation <- map["profileCreation"]
        userCanSwipe <- map["canSwipe"]
    }

    var userKey: String {
        return (self.key as? String) ?? ""
    }

    var userId: String {
        return (self.id as? String) ?? ((self.uid as? String) ?? "")
    }
    
    var userType: Int {
        return (self.type as? Int) ?? 1
    }

    var userEmail: String {
        return (self.email as? String) ?? ""
    }

    var userSettings: Settings? {
        return self.settings ?? nil
    }

    var userCreatedDate: Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = CustomDateFormat.regular.rawValue
        guard let createdDate = self.createdAt as? String, let date = formatter.date(from: createdDate) else {
            return nil
        }
        return date
    }

    var countForTable: Int {
        return 2 + (self.userInformation?.count ?? 0) + (self.userDetails?.count ?? 0)
    }

    var maxCountForInfo: Int {
        guard let array = self.userInformation else { return 2 }
        return 2 + array.count
    }

    var userAge: Int {
        guard let userInfo = self.userInformation else {
            return 0
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "age"
        }
        let result = results.first
        return Int(result?.userInfo ?? "0") ?? 0
    }

    var userLocation: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "location"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userBio: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "bio"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userWork: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "work"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userJobTitle: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "jobTitle"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userSchool: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "school"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userKidsNames: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "kidsNames"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userKidsAges: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "kidsAges"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userKidsBio: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "kidsBio"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userQuestionOne: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "questionOne"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userQuestionTwo: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "questionTwo"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }

    var userQuestionThree: String {
        guard let userInfo = self.userInformation else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.userInfoType == "questionThree"
        }
        let result = results.first
        return result?.userInfo ?? ""
    }
    
    func setInformation(_ data: [String:Any]) {
        let info = Info(JSON: data)
        if self.userInformation == nil {
            self.userInformation = [Info]()
        }
        self.userInformation?.append(info!)
        FIRFirestoreDB.shared.update(withData: ["userInformation" : [info?.userInfoType ?? "" : data]], from: kUsers, at: "\(CurrentUser.shared.user?.userKey ?? "")") {
            (success, error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }
//        FIRRealtimeDB.shared.update(withData: [info?.userInfoType ?? "" : data], atChild: "users/\(CurrentUser.shared.user?.userKey ?? "")/userInformation") {
//            (success, results, error) in
//            if error == nil {
//                print("Successfully updated user data")
//            } else {
//                print("Didnot update user data.")
//            }
//        }
    }

    func setDetails(_ data: [String:Any]) {
        let info = Info(JSON: data)
        if self.userDetails == nil {
            self.userDetails = [Info]()
        }
        self.userDetails?.append(info!)
        FIRFirestoreDB.shared.update(withData: ["userDetails" : [info?.userInfoType ?? "" : data]], from: kUsers, at: "\(CurrentUser.shared.user?.userKey ?? "")") {
            (success, error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }
//        FIRRealtimeDB.shared.update(withData: data, atChild: "users/\(CurrentUser.shared.user?.userKey ?? "")/userDetails") {
//            (success, results, error) in
//            if error == nil {
//                print("Successfully updated user data")
//            } else {
//                print("Didnot update user data.")
//            }
//        }
    }

//    var userNextSwipeDate: Date? {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone.current
//        formatter.dateFormat = CustomDateFormat.regular.rawValue
//        guard let createdDate = self.nextSwipeDate as? String, let date = formatter.date(from: createdDate) else {
//            return nil
//        }
//        return date
//    }
//
//    func setNextActiveDate() {
//        let calendar = Calendar.current
//        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .weekOfMonth, .weekOfYear, .weekday, .minute, .second],
//                                                     from: date)
//        let newComponents = DateComponents(calendar: calendar,
//                                           timeZone: .current,
//                                           year: dateComponents.year,
//                                           month: dateComponents.month,
//                                           day: dateComponents.day,
//                                           hour: dateComponents.hour,
//                                           minute: dateComponents.minute,
//                                           second: dateComponents.second,
//                                           weekday: dateComponents.weekday,
//                                           weekOfMonth: dateComponents.weekOfMonth,
//                                           weekOfYear: dateComponents.weekOfYear)
//
//    }

    func disableSwiping() {
        if self.userCanSwipe == nil {
            self.userCanSwipe = Bool()
        }
        self.userCanSwipe = false
        FIRFirestoreDB.shared.update(withData: ["canSwipe" : false], from: kUsers, at: "\(CurrentUser.shared.user?.userKey ?? "")") {
            (success, error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Didnot update user data.")
            }
        }
    }

}
