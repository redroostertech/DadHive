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
    var recipientId: Any?
    var createdAt: Any?
    private var lastMessageID: Any?
    var updatedAt: Any?

    var otherUser: User? {
        if senderId as? String ?? "" == CurrentUser.shared.user?.uid ?? "n/a" {
            return self.recipient
        } else {
            return self.sender
        }
    }

    var sender: User?
    var recipient: User?
    var lastMessage: Message?

    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        key <- map["snapshotKey"]
        id <- map["id"]
        senderId <- map["senderId"]
        recipientId <- map["recipientId"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
        lastMessageID <- map["lastMessageID"]

        DispatchQueue.global(qos: .background).async {
            //  MARK:- Get Sender
            FIRFirestoreDB.shared.retrieveUser(withId: self.senderId as? String ?? "", completion: { (success, document, error) in
                if let err = error {
                    print("No user data from API")
                } else {
                    if let data = document?.data(), let user = User(JSON: data) {
                        self.sender = user
                    } else {
                        print("Sender document data is empty.")
                    }
                }
            })
        }

        DispatchQueue.global(qos: .background).async {
            //  MARK:- Get Recipient
            FIRFirestoreDB.shared.retrieveUser(withId: self.recipientId as? String ?? "", completion: { (success, document, error) in
                if let err = error {
                    print("No user data from API")
                } else {
                    if let data = document?.data(), let user = User(JSON: data) {
                        self.recipient = user
                    } else {
                        print("Sender document data is empty.")
                    }
                }
            })
        }

        DispatchQueue.global(qos: .background).async {
            //  MARK:- Get Message
            FIRFirestoreDB.shared.retrieveUser(withId: self.recipientId as? String ?? "", completion: { (success, document, error) in
                if let err = error {
                    print("No user data from API")
                } else {
                    if let data = document?.data(), let user = User(JSON: data) {
                        self.recipient = user
                    } else {
                        print("Sender document data is empty.")
                    }
                }
            })
        }
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
