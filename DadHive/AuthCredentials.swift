//
//  SignInCredentials.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/18/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthCredentials:
    Mappable
{
    var email: String?
    var password: String?
    var confirmPassword: String?
    var username: String?
    var phone: String?
    var fullname: String?

    required init?(map: Map) { }
    
    func mapping(map: Map) {
        email <- map["email"]
        password <- map["password"]
        confirmPassword <- map["confirmPassword"]
        username <- map["username"]
        phone <- map["phone"]
        fullname <- map["fullname"]
    }

    func isValid() -> Bool {
        if let confirmPassword = self.confirmPassword {
            guard
                let password = self.password,
                let email = self.email,
                let fullname = self.fullname,
                email != "",
                password != "",
                confirmPassword != "",
                fullname != "" else {
                return false
            }
            return password == confirmPassword && email.contains("@") && fullname.count > 1
        } else {
            guard
                let password = self.password,
                let email = self.email,
                email != "",
                password != "" else {
                    return false
            }
            return email.contains("@")
        }
    }
}
