import Foundation
import ObjectMapper
import RRoostSDK

public enum PostType {
  case thought
  case none
}

class Posts: Mappable {
  var count: Int?
  var posts: [Post]?

  required init?(map: Map) { }

  func mapping(map: Map) {
    self.count <- map["count"]
    self.posts <- map["data"]
  }
}

class PostWrapper: Mappable {
  var post: Post?
  var owner: User?
  var numberOfLikes: Int?

  required init?(map: Map) { }

  func mapping(map: Map) {
    self.post <- map["post"]
    self.owner <- map["owner"]
    self.numberOfLikes <- map["numberOfLikes"]
  }
}

class Post: Mappable, CustomStringConvertible {

  // MARK: - Public properties
  var _id: String?
  var id: String?
  var createdAt: String?
  var updatedAt: String?
  var owner: [User]?
  private var type: String?
  var description: String?
  var categories: [Category]?
  var title: String?
  private var media: String?
  var numberOfLikes: Int?
  var numberOfComments: Int?
  var numberOfUpvotes: Int?
  var numberOfDownvotes: Int?
  var myLike: Int?

  // MARK: - Public computer properties
  var conversationDate: Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    guard let createdDate = self.createdAt, let date = formatter.date(from: createdDate) else {
      return nil
    }
    return date
  }

//  var date: String? {
//    if let createdAt = self.createdAt {
//      return createdAt.timeAgoDisplay()
//    } else {
//      return nil
//    }
//  }

  var postType: PostType {
    guard let type = self.type else { return .none }
    if type == "thought" {
      return .thought
    }
    return .none
  }

  var mediaUrl: URL? {
    guard let mediaurl = self.media else { return nil }
    return URL(string: mediaurl)
  }

  // MARK: - Lifecycle methods
  required public init?(map: Map) { }

  public func mapping(map: Map) {
    _id <- map["_id"]
    id <- map["id"]
    createdAt <- map["createdAt"]
    updatedAt <- map["updatedAt"]
    owner <- map["owner"]
    type <- map["type"]
    categories <- map["categories"]
    title <- map["title"]
    description <- map["description"]
    media <- map ["media"]
    numberOfLikes <- map ["numOfLikes"]
    numberOfComments <- map ["numOfComments"]
    numberOfUpvotes <- map ["numOfUpvotes"]
    numberOfDownvotes <- map ["numOfDownvotes"]
    myLike <- map["myLike"]
  }
}

class Engagements: Mappable {
  var count: Int?
  var engagements: [Engagement]?

  required init?(map: Map) { }

  func mapping(map: Map) {
    self.count <- map["count"]
    self.engagements <- map["data"]
  }
}

class Engagement: Mappable, CustomStringConvertible {

  // MARK: - Public properties
  var _id: String?
  var id: String?
  var createdAt: String?
  var updatedAt: String?
  var owner: [User]?
  private var type: String?
  var post: String?
  var comment: String?

  var numberOfLikes: Int?
  var numberOfComments: Int?
  var numberOfUpvotes: Int?
  var numberOfDownvotes: Int?
  var myLike: Int?

  // MARK: - Public computer properties
  var conversationDate: Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    guard let createdDate = self.createdAt, let date = formatter.date(from: createdDate) else {
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
    owner <- map["owner"]
    type <- map["type"]
    post <- map["post"]
    comment <- map["comment"]
    numberOfLikes <- map ["numOfLikes"]
    numberOfComments <- map ["numOfComments"]
    numberOfUpvotes <- map ["numOfUpvotes"]
    numberOfDownvotes <- map ["numOfDownvotes"]
    myLike <- map["myLike"]
  }
}

class NotificationResponse: Mappable {
  var count: Int?
  var notifications: [Notifications]?

  required init?(map: Map) { }

  func mapping(map: Map) {
    self.count <- map["count"]
    self.notifications <- map["data"]
  }
}

class Notifications: Mappable, CustomStringConvertible {

  // MARK: - Public properties
  var _id: String?
  var id: String?
  var createdAt: String?
  var updatedAt: String?
  var senderId: [User]?
  var owner: [User]?
  var type: String?
  var post: [Post]?
  var comment: String?
  var message: String?

  // MARK: - Public computer properties
//  var conversationDate: Date? {
//    let dateFormatter = DateFormatter()
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
//    dateFormatter.dateFormat = CustomDateFormat.regular.rawValue
//    guard let createdDate = self.createdAt, let date = dateFormatter.date(from: createdDate) else {
//      return nil
//    }
//    return date
//  }

  // MARK: - Lifecycle methods
  required public init?(map: Map) { }

  public func mapping(map: Map) {
    _id <- map["_id"]
    id <- map["id"]
    createdAt <- map["createdAt"]
    updatedAt <- map["updatedAt"]
    senderId <- map["senderId"]
    owner <- map["owner"]
    type <- map["type"]
    post <- map["post"]
    comment <- map["comment"]
    message <- map["message"]
  }
}
