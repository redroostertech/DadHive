import Foundation

public class Api {
    fileprivate let baseURL = (isLive) ? kLiveURL : kTestURL
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
        static let reportUser: String = {
            return Api.init().baseURL + "reportUser"
        }()
        static let addParticipant: String = {
            return Api.init().baseURL + "addParticipant"
        }()
        static let removeParticipant: String = {
            return Api.init().baseURL + "removeParticipant"
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
    }
}
