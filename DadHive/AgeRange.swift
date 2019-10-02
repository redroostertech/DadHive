import Foundation
import ObjectMapper
import RRoostSDK

class AgeRange: Mappable, CustomStringConvertible {

    var id: Int?
    var min: Double?
    var max: Double?

    required init?(map: Map) { }

    func mapping(map: Map) {
        id <- map["id"]
        min <- map["min"]
        max <- map["max"]
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

    var getAgeRange: String? {
        if let min = self.min, let max = self.max {
            return "\(Int(min)) to \(Int(max)) years old."
        } else {
            return nil
        }
    }

}

