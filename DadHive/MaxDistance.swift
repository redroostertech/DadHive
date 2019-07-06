import Foundation
import ObjectMapper

class MaxDistance: Mappable, CustomStringConvertible {

    private var interval: Int?
    private var max: Int?
    private var min: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        interval <- map["interval"]
        max <- map["max"]
        min <- map["min"]
    }

    var getInterval: Double {
        if let int = self.interval {
            return Double(exactly: int) ?? 0.0
        } else {
            return 0.0
        }
    }

    var getMax: Double {
        if let int = self.max {
            return Double(exactly: int) ?? 0.0
        } else {
            return 0.0
        }
    }

    var getMin: Double {
        if let int = self.min {
            return Double(exactly: int) ?? 0.0
        } else {
            return 0.0
        }
    }
}
