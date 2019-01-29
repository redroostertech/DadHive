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

public class Conversation: Mappable, CustomStringConvertible {
    var key: Any?
    var id: Any?
    var senderId: Any?
    var sender: User?
    var recipientId: Any?
    var recipient: User?
    var createdAt: Any?
    var lastMessage: Message?
    var updatedAt: Any?

    var otherUser: User? {
        if senderId as? String ?? "" == CurrentUser.shared.user?.userId {
            return self.recipient
        } else {
            return self.sender
        }
    }

    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        key <- map["snapshotKey"]
        id <- map["id"]
        senderId <- map["senderId"]
        recipientId <- map["recipientId"]
        senderDict <- map["sender"]
        recipientDict <- map["recipient"]
        createdAt <- map["createdAt"]
        lastMessageDict <- map["lastMessage"]
        updatedAt <- map["updatedAt"]
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
        if let conversationDate = self.conversationDate {
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

    private var lastMessageDict: Any? {
        didSet {
            if let dict = self.lastMessageDict as? [String: Any] {
                lastMessage = Message(JSON: dict)
            }
        }
    }

    private var senderDict: Any? {
        didSet {
            if let dict = self.senderDict as? [String: Any] {
                sender = User(JSON: dict)
            }
        }
    }

    private var recipientDict: Any? {
        didSet {
            if let dict = self.recipientDict as? [String: Any] {
                recipient = User(JSON: dict)
            }
        }
    }
}

public class Message: Mappable {
    var key: Any?
    var id: Any?
    var conversationId: Any?
    var sender: User?
    var senderId: Any?
    var message: Any?
    private var createdAt: Any?
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        key <- map["snapshotKey"]
        id <- map["id"]
        conversationId <- map["conversationId"]
        senderDict <- map["sender"]
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

    private var senderDict: Any? {
        didSet {
            if let dict = self.senderDict as? [String: Any] {
                self.sender = User(JSON: dict)
            }
        }
    }
}
