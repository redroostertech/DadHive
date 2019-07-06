import Foundation
import ObjectMapper

class Info: Mappable, CustomStringConvertible {
    var type: String?
    var info: String?
    var title: String?
    var icon: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        type <- map["type"]
        info <- map["info"]
        title <- map["title"]
        icon <- map["image"]
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
}

