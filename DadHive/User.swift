//
//  User.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/17/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Users: Mappable {
    var users: [User]?

    required init?(map: Map) { }

    func mapping(map: Map) {
        self.users <- map["users"]
    }
}

class User: Mappable, CustomStringConvertible {

    var key: String?
    var uid: String?
    var id: String?
    var name: Name?
    private var timestamp: String?
    var email: String?
    var type: Double?
    var settings: Settings?
    var media: [Media]? {
        didSet {
            guard let mediaArray = self.media, mediaArray.count > 0 else { return }
            self.imageSectionOne.removeAll()
            self.imageSectionTwo.removeAll()
            var count = 0
            while count < mediaArray.count {
                if count <= 2 && mediaArray[count].url != nil {
                    self.imageSectionOne.append(mediaArray[count])
                }
                if count > 2 && mediaArray[count].url != nil {
                    self.imageSectionTwo.append(mediaArray[count])
                }
                count += 1
            }
        }
    }
    private var dob: String?
    var bio: String? {
        guard let userInfo = self.infoSectionOne else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "bio"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var jobTitle: String? {
        guard let userInfo = self.infoSectionOne else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "jobTitle"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var companyName: String? {
        guard let userInfo = self.infoSectionOne else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "companyName"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var schoolName: String? {
        guard let userInfo = self.infoSectionOne else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "schoolName"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var kidsNames: String? {
        guard let userInfo = self.infoSectionTwo else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "kidsNames"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var kidsAges: String? {
        guard let userInfo = self.infoSectionTwo else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "kidsAges"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var kidsBio: String? {
        guard let userInfo = self.infoSectionTwo else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "kidsBio"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var kidsCount: String? {
        guard let userInfo = self.infoSectionTwo else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "kidsCount"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var questionOneTitle: String? {
        guard let userInfo = self.infoSectionThree else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "questionOneTitle"
        }
        let result = results.first
        return result?.title ?? nil
    }
    var questionOneResponse: String? {
        guard let userInfo = self.infoSectionThree else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "questionOneResponse"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var questionTwoTitle: String? {
        guard let userInfo = self.infoSectionThree else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "questionTwoTitle"
        }
        let result = results.first
        return result?.title ?? nil
    }
    var questionTwoResponse: String? {
        guard let userInfo = self.infoSectionThree else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "questionTwoResponse"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var questionThreeTitle: String? {
        guard let userInfo = self.infoSectionThree else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "questionThreeTitle"
        }
        let result = results.first
        return result?.title ?? nil
    }
    var questionThreeResponse: String? {
        guard let userInfo = self.infoSectionThree else {
            return ""
        }
        let results = userInfo.filter {
            (item) -> Bool in
            return item.type == "questionThreeResponse"
        }
        let result = results.first
        return result?.info ?? nil
    }
    var canSwipe: Bool?
    private var swipeDateTimestamp: String?
    var profileCreation: Bool?
    var currentPage: Int?
    var docId: String?
    var lastId: String?
    var matches: [String]?

    //  MARK:- This is for displaying my profile to other users
    var infoSectionOne: [Info]?
    var infoSectionTwo: [Info]?
    var infoSectionThree: [Info]?
    var preferenceSection: [Info]?
    var imageSectionOne = [Media]()
    var imageSectionTwo = [Media]()

    required init?(map: Map) { }
    
    func mapping(map: Map) {
        key <- map["key"]
        uid <- map["uid"]
        id <- map["id"]
        name <- map["name"]
        timestamp <- map["createdAt"]
        email <- map["email"]
        type <- map["type"]
        settings <- map["settings"]
        media <- map["mediaArray"]
        dob <- map["dob"]
        infoSectionOne <- map["userInformationSection1"]
        infoSectionTwo <- map["userInformationSection2"]
        infoSectionThree <- map["userInformationSection3"]
        preferenceSection <- map["userPreferencesSection"]
        canSwipe <- map["canSwipe"]
        swipeDateTimestamp <- map["nextSwipeDate"]
        profileCreation <- map["profileCreation"]
        currentPage <- map["currentPage"]
        lastId <- map["lastId"]
        docId <- map["docId"]
        matches <- map["matches"]

        if self.media != nil, self.media!.count > 1 {
            self.media!.sort { $0.order! < $1.order! }
        }
    }

    var createdAt: Date? {
        return getDate(fromString: self.timestamp ?? "")
    }

    var age: Int? {
        guard let dob = self.dob else { return nil }
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        guard let birthdayDate = dateFormater.date(from: dob) else { return nil }
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate, to: now, options: [])
        guard let age = calcAge.year else { return nil }
        return age
    }

    var nextSwipeDate: Date? {
        return getDate(fromString: self.swipeDateTimestamp ?? "")
    }

    var countForSection1: Int {
        guard let infoSec1 = self.infoSectionOne else { return 0 }
        let infoSec1Array = infoSec1.filter({
            (item) -> Bool in
            return item.info != nil
        })
        return 2 + infoSec1Array.count
    }

    var countForSection2: Int {
        guard let infoSec1 = self.infoSectionOne, let infoSec2 = self.infoSectionTwo else { return 0 }
        let infoSec1Array = infoSec1.filter({
            (item) -> Bool in
            return item.info != nil
        })
        let infoSec2Array = infoSec2.filter({
            (item) -> Bool in
            return item.info != nil
        })
        return 2 + infoSec1Array.count + infoSec2Array.count
    }

    var countForSection3: Int {
        guard let infoSec1 = self.infoSectionOne, let infoSec2 = self.infoSectionTwo, let infoSec3 = self.infoSectionThree else { return 0 }
        let infoSec1Array = infoSec1.filter({
            (item) -> Bool in
            return item.info != nil
        })
        let infoSec2Array = infoSec2.filter({
            (item) -> Bool in
            return item.info != nil
        })
        let infoSec3Array = infoSec3.filter({
            (item) -> Bool in
            return item.info != nil
        })
        return 2 + infoSec1Array.count + infoSec2Array.count + infoSec3Array.count
    }

    var countForTable: Int {
        guard let infoSec1 = self.infoSectionOne, let infoSec2 = self.infoSectionTwo, let infoSec3 = self.infoSectionThree else { return 2 }
        let infoSec1Array = infoSec1.filter({
            (item) -> Bool in
            return item.info != nil
        })
        let infoSec2Array = infoSec2.filter({
            (item) -> Bool in
            return item.info != nil
        })
        let infoSec3Array = infoSec3.filter({
            (item) -> Bool in
            return item.info != nil
        })
        return 2 + infoSec1Array.count + infoSec2Array.count + infoSec3Array.count
    }

    var newNextSwipeDate: String? {
        guard let newNextSwipeDate = Date().add(days: 1) else { return nil }
        return newNextSwipeDate.toString()
    }

    var maxSwipes: Int {
        if type ?? 0.0 == 1.0 {
            return 10
        } else {
            return Int.max
        }
    }
}

//  MARK:- Model modification methods
extension User {
    func change(name: String, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateUser(withData: ["name" : name]) { (error) in
            if error == nil {
                self.name?.fullName = name
                completion(nil)
            } else {
                completion(error)
            }
        }
    }

    func setInformation(atKey: String, withValue value: String, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateUser(withData: [atKey : value]) { (error) in
            if error == nil {
                if let section1 = self.infoSectionOne {
                    for item in section1 {
                        if let type = item.type, type == atKey {
                            item.info = value
                        }
                    }
                }
                if let section2 = self.infoSectionTwo {
                    for item in section2 {
                        if let type = item.type, type == atKey {
                            item.info = value
                        }
                    }
                }
                if let section3 = self.infoSectionThree {
                    for item in section3 {
                        if let type = item.type, type == atKey {
                            item.info = value
                        }
                    }
                }
                completion(nil)
            }
        }
    }

    func setInformation(atKey: String, withValue value: Int, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateUser(withData: [atKey : value]) { (error) in
            if error == nil {
                if let section1 = self.infoSectionOne {
                    for item in section1 {
                        if let type = item.type, type == atKey {
                            item.info = String(describing: value)
                        }
                    }
                }
                if let section2 = self.infoSectionTwo {
                    for item in section2 {
                        if let type = item.type, type == atKey {
                            item.info = String(describing: value)
                        }
                    }
                }
                if let section3 = self.infoSectionThree {
                    for item in section3 {
                        if let type = item.type, type == atKey {
                            item.info = String(describing: value)
                        }
                    }
                }
                completion(nil)
            }
        }
    }

    func disableSwiping() {
        guard let newNextDate = newNextSwipeDate else { return }
        CurrentUser.shared.updateUser(withData:["canSwipe" : false, "nextSwipeDate" : newNextDate]) { (error) in
            if error == nil {
                self.canSwipe = false
                self.swipeDateTimestamp = newNextDate
            }
        }
    }

    func enableSwiping() {
        CurrentUser.shared.updateUser(withData: ["canSwipe" : true]) { (error) in
            if error == nil {
                self.canSwipe = true
            }
        }
    }

    func setNotificationToggle(_ state: Bool) {
        CurrentUser.shared.updateUser(withData: ["notifications" : state]) { (error) in
            if error == nil {
                self.settings?.notifications = state
            }
        }
    }

    func setMaximumDistance(_ distance: Double) {
        CurrentUser.shared.updateUser(withData: ["maxDistance" : distance]) { (error) in
            if error == nil {
                self.settings?.maxDistance = distance
            }
        }
    }

    func setInitialState(_ state: Bool, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateUser(withData: ["initialSetup" : state]) { (error) in
            if error == nil {
                self.settings?.initialSetup = state
                completion(nil)
            } else {
                completion(error)
            }
        }
    }

    func setLocation(_ location: Location, _ completion: @escaping(Error?)->Void) {
        if let lat = location.addressLat, let long = location.addressLong, let documentID = CurrentUser.shared.user?.key {
            let parameters: [String: Any] = [
                "userId": CurrentUser.shared.user!.uid!,
                "latitude": lat,
                "longitude": long
            ]
            APIRepository().performRequest(path: Api.Endpoint.saveLocation, method: .post, parameters: parameters) { (response, error) in
                if let err = error {
                    print(err)
                    completion(err)
                } else {
                    print("Successfully updated user data & added a geofire obbject.")
                    self.settings?.location = location
                    CurrentUser.shared.updateUser(withData: location.toDict) {
                        (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        } else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
        }
    }

    func setAgeRange(_ range: AgeRange) {
        guard let rangeId = range.id, let rangeMax = range.max, let rangeMin = range.min, let ageRange = AgeRange(JSON: ["ageRangeId" : rangeId, "ageRangeMax" : rangeMax, "ageRangeMin" : rangeMin]) else {
            print("Did not update user data.")
            return
        }
        CurrentUser.shared.updateUser(withData: ["ageRangeId" : rangeId, "ageRangeMax" : rangeMax, "ageRangeMin" : rangeMin]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
                self.settings?.ageRange = ageRange
            } else {
                print("Did not update user data.")
            }
        }
    }

    func setKidsAgeRange(_ range: AgeRange) {
        guard let range = range.getAgeRange else {
            print("Did not update user data.")
            return
        }
        CurrentUser.shared.updateUser(withData: ["kidsAges" : range]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Did not update user data.")
            }
        }
    }

    func updateCurrentPage(_ page: Int) {
        CurrentUser.shared.updateUser(withData: ["currentPage" : page]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Did not update user data.")
            }
        }
    }

    func updateLastId(_ id: String) {
        CurrentUser.shared.updateUser(withData: ["lastId" : id]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Did not update user data.")
            }
        }
    }

    func addMatches(withValue value: [String], _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateUser(withData: ["matches" : value]) { (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Did not update user data.")
            }
        }
    }

    private func getDate(fromString dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = CustomDateFormat.regular.rawValue
        guard let date = formatter.date(from: dateString) else {
            return nil
        }
        return date
    }

}
