import Foundation
import ObjectMapper

class JSONStringToStringTransform: TransformType {
    
    typealias Object = String
    typealias JSON = String
    
    init() {}
    func transformFromJSON(_ value: Any?) -> String? {
        if let strValue = value as? String {
            return String(strValue)
        }
        return value as? String ?? nil
    }
    
    func transformToJSON(_ value: String?) -> String? {
        if let strValue = value {
            return "\(strValue)"
        }
        return nil
    }
}
