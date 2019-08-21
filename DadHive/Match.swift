import Foundation
import ObjectMapper

public class Match: Mappable {

  var matchExists: Bool?

  required public init?(map: Map) { }

  public func mapping(map: Map) {
        
        matchExists <- map["matchExists"]
    }

    var conversationDate: Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = CustomDateFormat.regular.rawValue
        guard let createdDate = self.createdAt as? String, let date = formatter.date(from: createdDate) else {
            return nil
        }
        return date
    }

    var date: String? {
        guard let conversationDate = self.conversationDate else {
            return nil
        }
        return conversationDate.timeAgoDisplay()
    }

    private var senderDict: Any? {
        didSet {
            if let dict = self.senderDict as? [String: Any] {
                self.sender = User(JSON: dict)
            }
        }
    }
}
