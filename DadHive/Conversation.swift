import Foundation
import ObjectMapper
import Firebase

class Conversations: Mappable {
    var conversations: [Conversation]?
    var count: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        self.count <- map["count"]
        self.conversations <- map["conversations"]
    }
}

public class Conversation: Mappable, CustomStringConvertible {

    var _id: String?
    var id: String?
    var participants: [String]?
    var createdAt: String?
    var updatedAt: String?
    var lastMessageId: String?

    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        _id <- map["_id"]
        id <- map["id"]
        participants <- map["participants"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
        lastMessageId <- map["lastMessageId"]
    }

    var conversationDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        guard let createdDate = self.createdAt as? String, let date = formatter.date(from: createdDate) else {
            return nil
        }
        return date
    }

    var date: String? {
        if let conversationDate = self.conversationUpdatedDate {
            return conversationDate.timeAgoDisplay()
        } else {
            return nil
        }
    }

    var conversationUpdatedDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        guard let updatedDate = self.updatedAt as? String, let date = formatter.date(from: updatedDate) else {
            return nil
        }
        return date
    }
}
