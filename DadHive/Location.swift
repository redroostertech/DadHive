import Foundation
import ObjectMapper
import RRoostSDK

class Location: Mappable, CustomStringConvertible {

    var addressLat: Double?
    var addressLong: Double?
    var addressCity: String?
    var addressState: String?
    var description: String?
    var addressCountry: String?
    var addressLine1: String?
    var addressLine2: String?
    var addressLine3: String?
    var addressLine4: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        addressLat <- map["addressLat"]
        addressLong <- map["addressLong"]
        addressCity <- map["addressCity"]
        addressState <- map["addressState"]
        description <- map["description"]
        addressCountry <- map["addressCountry"]
        addressLine1 <- map["addressLine1"]
        addressLine2 <- map["addressLine2"]
        addressLine3 <- map["addressLine3"]
        addressLine4 <- map["addressLine4"]
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

    var getString: String? {
        if let city = self.addressCity, let state = self.addressState, let country = self.addressCountry {
            return city + ", " + state + ", " + country
        } else {
            return nil
        }
    }
}
