//
//  API.swift
//  PopViewers
//
//  Created by Michael Westbrooks II on 5/13/18.
//  Copyright © 2018 MVPGurus. All rights reserved.
//

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
        static let getUsers: String = {
            return Api.init().baseURL + "getUsers"
        }()
        static let getUser: String = {
            return Api.init().baseURL + "getUser"
        }()
        static let createUser: String = {
            return Api.init().baseURL + "createUser"
        }()
        static let getNearbyUsers: String = {
            return Api.init().baseURL + "getNearbyUsers"
        }()
        static let createMatch: String = {
            return Api.init().baseURL + "createMatch"
        }()
        static let findMatch: String = {
            return Api.init().baseURL + "findMatch"
        }()
        static let findConversations: String = {
            return Api.init().baseURL + "findConversations"
        }()
        static let findConversation: String = {
            return Api.init().baseURL + "findConversation"
        }()
        static let getMessages: String = {
            return Api.init().baseURL + "getMessages"
        }()
        static let sendMessage: String = {
            return Api.init().baseURL + "sendMessage"
        }()
        static let saveLocation: String = {
            return Api.init().baseURL + "saveLocation"
        }()
        static let updateConversation: String = {
            return Api.init().baseURL + "updateConversation"
        }()
    }
}
