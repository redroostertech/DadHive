import Foundation
import ObjectMapper

class Conversations: Mappable {
    var count: Int?
    var conversationWrapper: [ConversationWrapper]?

    required init?(map: Map) { }

    func mapping(map: Map) {
        self.count <- map["count"]
        self.conversationWrapper <- map["data"]
    }
}

class ConversationWrapper: Mappable {
  var conversation: Conversation?
  var participants: [User]?

  required init?(map: Map) { }

  func mapping(map: Map) {
    self.conversation <- map["conversation"]
    self.participants <- map["participants"]
  }

  func getChatParticipants() -> String {
    guard let array = self.participants?.filter({ (user) -> Bool in
      return user.uid != CurrentUser.shared.user?.uid
    }) else { return "There are no participants." }
    if array.count > 1 {
      return "This is a group chat."
    } else if array.count == 1 {
      return "There is 1 participant."
    } else {
      return "There are no participants."
    }
  }
}

class Conversation: Mappable, CustomStringConvertible {

  // MARK: - Public properties
    var _id: String?
    var id: String?
    private var createdAt: String?
    var updatedAt: String?
    var lastMessageId: String?
    var lastMessageText: String?

  // MARK: - Public computer properties
    var conversationDate: Date? {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM d, yyyy"
      guard let createdDate = self.createdAt, let date = formatter.date(from: createdDate) else {
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
      guard let updatedDate = self.updatedAt, let date = formatter.date(from: updatedDate) else {
        return nil
      }
      return date
    }

  // MARK: - Lifecycle methods
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        _id <- map["_id"]
        id <- map["id"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
        lastMessageId <- map["lastMessageId"]
        lastMessageText <- map["lastMessageText"]
    }
}
