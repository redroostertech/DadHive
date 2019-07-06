import Foundation
import ObjectMapper
import Firebase

class Messages: Mappable {
    var messages: [Message]?

    required init?(map: Map) { }

    func mapping(map: Map) {
        self.messages <- map["messages"]
    }
}

public class Message: Mappable {
    
    var key: String?
    var id: String?
    var conversationId: String?
    var senderId: String?
    var message: String?
    private var createdAt: String?

    required public init?(map: Map) { }

    public func mapping(map: Map) {
        key <- map["snapshotKey"]
        id <- map["id"]
        conversationId <- map["conversationId"]
        message <- map["message"]
        createdAt <- map["createdAt"]
        senderId <- map["senderId"]
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
}
