import Foundation
import RRoostSDK

public class Api {
  fileprivate let baseURL = (isLocal) ? kLocalURL : (isLive) ? kLiveURL : kTestURL
    struct Endpoint {
        static let authToken: String = {
            return Api.init().baseURL + "authtoken"
        }()
        static let retrieveKeys: String = {
            return Api.init().baseURL + "retrievekeys"
        }()
        static let getUser: String = {
            return Api.init().baseURL + "getUser"
        }()
        static let createMatch: String = {
            return Api.init().baseURL + "createMatch"
        }()
        static let getMatches: String = {
            return Api.init().baseURL + "getMatches"
        }()
        static let deleteMatch: String = {
            return Api.init().baseURL + "deleteMatch"
        }()
        static let deleteConversation: String = {
            return Api.init().baseURL + "deleteConversation"
        }()
        static let addParticipant: String = {
            return Api.init().baseURL + "addParticipant"
        }()
        static let removeParticipant: String = {
            return Api.init().baseURL + "removeParticipant"
        }()
        static let createConversation: String = {
            return Api.init().baseURL + "createConversation"
        }()
        static let findConversations: String = {
            return Api.init().baseURL + "findConversations"
        }()
        static let getUsersInConversation: String = {
            return Api.init().baseURL + "getUsersInConversation"
        }()
        static let sendMessageCheck: String = {
            return Api.init().baseURL + "sendMessageCheck"
        }()
        static let saveLocation: String = {
            return Api.init().baseURL + "saveLocation"
        }()
        static let editUserProfile: String = {
            return Api.init().baseURL + "editUserProfile"
        }()
        static let getNearbyUsers: String = {
            return Api.init().baseURL + "getNearbyUsers"
        }()
        static let reportUser: String = {
          return Api.init().baseURL + "reportUser"
        }()
        static let getCategories: String = {
          return Api.init().baseURL + "getCategories"
        }()
        static let addCategory: String = {
            return Api.init().baseURL + "addCategory"
        }()
        static let addPost: String = {
          return Api.init().baseURL + "addPost"
        }()
        static let getPosts: String = {
          return Api.init().baseURL + "getPosts"
        }()
        static let getPostsByCategory: String = {
          return Api.init().baseURL + "getPostsByCategory"
        }()
        static let addEngagement: String = {
            return Api.init().baseURL + "addEngagement"
        }()
        static let getCommentsForPost: String = {
            return Api.init().baseURL + "getCommentsForPost"
        }()
        static let getActivityForUser: String = {
            return Api.init().baseURL + "getActivityForUser"
        }()
        static let searchForPost: String = {
            return Api.init().baseURL + "searchForPost"
        }()
        static let getUserActivity: String = {
          return Api.init().baseURL + "getUserActivity"
        }()
        static let reportPost: String = {
          return Api.init().baseURL + "reportPost"
        }()
        static let blockPost: String = {
          return Api.init().baseURL + "blockPost"
        }()
        static let blockUser: String = {
          return Api.init().baseURL + "blockUser"
        }()
      static let deletePost: String = {
        return Api.init().baseURL + "deletePost"
      }()
      static let getPostsByUser: String = {
        return Api.init().baseURL + "getPostsByUser"
      }()
      static let getBlockedUsers: String = {
        return Api.init().baseURL + "getBlockedUsers"
      }()
      static let unblockUser: String = {
        return Api.init().baseURL + "unblockUser"
      }()
      static let requestForDelete: String = {
        return Api.init().baseURL + "requestForDelete"
      }()
    }
}
