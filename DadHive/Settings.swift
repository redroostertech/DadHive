import Foundation
import ObjectMapper
import RRoostSDK

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
