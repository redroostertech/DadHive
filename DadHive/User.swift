import Foundation
import ObjectMapper
import FirebaseAuth
import RRoostSDK

class Users: Mappable {
    var users: [User]?
    required init?(map: Map) { }
    func mapping(map: Map) {
        self.users <- map["users"]
    }
}

// MARK: - Private properties
private var timestamp: String?
private var dob: String?
private var swipeDateTimestamp: String?

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

class User: Mappable, CustomStringConvertible {

    // MARK: - Public properties
    var key: String?
    var uid: String?
    var id: String?
    var name: Name?
    var email: String?
    var type: Double?
    var settings: Settings?
    var canSwipe: Bool?
    var profileCreation: Bool?
    var currentPage: Int?
    var docId: String?
    var lastId: String?
    var matches: [String]?
    var likes: [String]?

    var actions: Actions?
    
    // MARK: - Public computed properties
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
    var createdAt: Date? {
        return getDate(fromString: timestamp ?? "")
    }
    var age: Int? {
        guard let dob = dob else { return nil }
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
        return getDate(fromString: swipeDateTimestamp ?? "")
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

    //  MARK:- This is for displaying my profile to other users
    var infoSectionOne: [Info]?
    var infoSectionTwo: [Info]?
    var infoSectionThree: [Info]?
    var preferenceSection: [Info]?
    var imageSectionOne = [Media]()
    var imageSectionTwo = [Media]()

    // MARK: - Lifecycle methods
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
        actions <- map["actions_results"]

        if self.media != nil, self.media!.count > 1 {
            self.media!.sort { $0.order! < $1.order! }
        }
    }

    // MARK: Public member functions
    func change(email: String, _ completion: @escaping(Error?) -> Void) {
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
            guard error == nil else {
                return completion(error!)
            }
            CurrentUser.shared.updateProfile(withData: [
                "type": "email",
                "value": email]) { (error) in
                if error == nil {
                    self.email = email
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        })
    }

    func change(name: String, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateProfile(withData: ["type": "name", "value": name]) { (error) in
            if error == nil {
                completion(nil)
            } else {
                completion(error)
            }
        }
    }

    func change(dob: String, _ completion: @escaping(Error?) -> Void) {
      CurrentUser.shared.updateProfile(withData: ["type": "dob", "value": dob]) { (error) in
        if error == nil {
          completion(nil)
        } else {
          completion(error)
        }
      }
    }

    func change(bio: String, _ completion: @escaping(Error?) -> Void) {
      CurrentUser.shared.updateProfile(withData: ["type": "bio", "value": bio]) { (error) in
        if error == nil {
          completion(nil)
        } else {
          completion(error)
        }
      }
    }

    func change(companyName: String, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateProfile(withData: ["type": "companyName", "value": companyName]) { (error) in
            if error == nil {
                completion(nil)
            } else {
                completion(error)
            }
        }
    }

    func change(type: String, value: String, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateProfile(withData: ["type": type, "value": value]) { (error) in
            if error == nil {
                completion(nil)
            } else {
                completion(error)
            }
        }
    }

    func change(type: String, value: Int, _ completion: @escaping(Error?) -> Void) {
      CurrentUser.shared.updateProfile(withData: ["type": type, "value": value]) { (error) in
            if error == nil {
                completion(nil)
            } else {
                completion(error)
            }
        }
    }

    func setInformation(atKey: String, withValue value: String, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateProfile(withData: [atKey : value]) { (error) in
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
        CurrentUser.shared.updateProfile(withData: [atKey : value]) { (error) in
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
        CurrentUser.shared.updateProfile(withData: ["type": "canSwipe", "value": false]) { (error) in
            if error == nil {
                self.canSwipe = false
                swipeDateTimestamp = newNextDate
            }
        }
    }

    func enableSwiping() {
        CurrentUser.shared.updateProfile(withData: ["type": "canSwipe", "value" : true]) { (error) in
            if error == nil {
                self.canSwipe = true
            }
        }
    }

    func setNotificationToggle(_ state: Bool) {
        CurrentUser.shared.updateProfile(withData: [
            "type": "notifications",
             "value": state]) { (error) in
            if error == nil {
                self.settings?.notifications = state
            }
        }
    }

    func setMaximumDistance(_ distance: Double) {
        CurrentUser.shared.updateProfile(withData: [
            "type": "maxDistance",
            "value": distance]) { (error) in
            if error == nil {
                self.settings?.maxDistance = distance
            }
        }
    }

    func setInitialState(_ state: Bool, _ completion: @escaping(Error?) -> Void) {
        CurrentUser.shared.updateProfile(withData: [
            "type": "initialSetup",
            "value": state]) { (error) in
            if error == nil {
                self.settings?.initialSetup = state
                completion(nil)
            } else {
                completion(error)
            }
        }
    }

    func setLocation(_ location: Location, _ completion: @escaping(Error?)->Void) {
        if
            let currentuser = CurrentUser.shared.user,
            let lat = location.addressLat,
            let long = location.addressLong {
            
            let parameters: [String: Any] = [
                "userId": currentuser.uid ?? "",
                "latitude": lat,
                "longitude": long
            ]
            APIRepository().performRequest(path: Api.Endpoint.saveLocation, method: .post, parameters: parameters) { (response, error) in
                if let err = error {
                    print(err)
                    completion(err)
                } else {
                   completion(nil)
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
        CurrentUser.shared.updateProfile(withData: [
            "type": "ageRanges",
            "value" : rangeId]) {
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
        CurrentUser.shared.updateProfile(withData: [
            "type": "kidsAges",
            "value": range]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Did not update user data.")
            }
        }
    }

    func updateCurrentPage(_ page: Int) {
        CurrentUser.shared.updateProfile(withData: [
            "type": "currentPage",
            "value": page]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Did not update user data.")
            }
        }
    }

    func updateLastId(_ id: String) {
        CurrentUser.shared.updateProfile(withData: [
            "type": "lastId",
            "value": id]) {
            (error) in
            if error == nil {
                print("Successfully updated user data")
            } else {
                print("Did not update user data.")
            }
        }
    }
}

class Actions: Mappable, CustomStringConvertible {

  // MARK: - Public properties
  var _id: String?
  var id: String?
  private var createdAt: String?
  var updatedAt: String?
  var ownerID: String?
  private var likedIDs: [String]? {
    didSet {
      guard let array = self.likedIDs else { return }
      for i in array {
        self.excludedIDs.append(i)
      }
    }
  }
  private var matchedIDs: [String]? {
    didSet {
      guard let array = self.matchedIDs else { return }
      for i in array {
        self.excludedIDs.append(i)
      }
    }
  }
  private var blockedIDs: [String]? {
    didSet {
      guard let array = self.blockedIDs else { return }
      for i in array {
        self.excludedIDs.append(i)
      }
    }
  }
  private var conversationIDs: [String]?

  // MARK: - Public computer properties
  var conversationDate: Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    guard let createdDate = self.createdAt, let date = formatter.date(from: createdDate) else {
      return nil
    }
    return date
  }

  var date: String? {
    if let conversationDate = self.conversationUpdatedDate {
      return conversationDate.timeAgoDisplay()
    } else {
      return nil
    }
  }

  var conversationUpdatedDate: Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    guard let updatedDate = self.updatedAt, let date = formatter.date(from: updatedDate) else {
      return nil
    }
    return date
  }

  var excludedIDs = [String]()

  // MARK: - Lifecycle methods
  required public init?(map: Map) { }

  public func mapping(map: Map) {
    _id <- map["_id"]
    id <- map["id"]
    createdAt <- map["createdAt"]
    updatedAt <- map["updatedAt"]
    likedIDs <- map["likes"]
    matchedIDs <- map["matches"]
    ownerID <- map["owner"]
    blockedIDs <- map["blocked"]
    conversationIDs <- map["conversations"]
  }
}
