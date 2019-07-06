import Foundation
import ObjectMapper
import Firebase

public class Match: Mappable {

    var key: Any?
    var id: Any?
    private var senderId: Any?
    private var recipientId: Any?
    private var createdAt: Any?
    var updatedAt: Any?

    var sender: User?
    var recipient: User?

    required public init?(map: Map) { }

    public func mapping(map: Map) {
        
        key <- map["snapshotKey"]
        id <- map["id"]
        senderId <- map["senderId"]
        recipientId <- map["recipientId"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]

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
