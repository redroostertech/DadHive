//
//  Conversation.swift
//  boothnoire
//
//  Created by Michael Westbrooks on 10/10/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Firebase

class Conversations: Mappable {
    var conversations: [Conversation]?

    required init?(map: Map) { }

    func mapping(map: Map) {
        self.conversations <- map["conversations"]
    }
}

public class Conversation: Mappable, CustomStringConvertible {

    var key: String?
    var id: String?
    var senderId: String?
    var recipientId: String?
    var createdAt: String?
    var updatedAt: String?
    var trueRecipient: User?
    var lastMessage: Message?

    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        key <- map["snapshotKey"]
        id <- map["id"]
        senderId <- map["senderId"]
        recipientId <- map["recipientId"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
        trueRecipient <- map["trueRecipient"]
        lastMessage <- map["lastMessage"]
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
