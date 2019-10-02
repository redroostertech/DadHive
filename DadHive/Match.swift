import Foundation
import ObjectMapper

public class Match: Mappable {

  var matchExists: Bool?

  required public init?(map: Map) { }

  public func mapping(map: Map) {
        
        matchExists <- map["match_exists"]
    }
}
