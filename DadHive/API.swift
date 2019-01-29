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
    }
}
