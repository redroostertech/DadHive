//
//  SignInCredentials.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/18/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import RRoostSDK

struct AuthCredentials {
    var email: String
    var password: String

    func isValid() -> Bool {
        guard email != "", password != "" else {
                return false
        }
        return email.contains("@")
    }
}
