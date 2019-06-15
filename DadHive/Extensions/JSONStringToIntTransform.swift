import Foundation
import ObjectMapper

class JSONStringToIntTransform: TransformType {
    
    typealias Object = Int64
    typealias JSON = String
    
    init() {}
    func transformFromJSON(_ value: Any?) -> Int64? {
        if let strValue = value as? String {
            return Int64(strValue)
        }
        return value as? Int64 ?? nil
    }
    
    func transformToJSON(_ value: Int64?) -> String? {
        if let intValue = value {
            return "\(intValue)"
        }
        return nil
    }
}
