//
//  File.swift
//  PopViewers
//
//  Created by Michael Westbrooks II on 5/13/18.
//  Copyright © 2018 MVPGurus. All rights reserved.
//

import Foundation

enum Errors:
    String,
    Error
{
    case InvalidCredentials = "InvalidCredentials"
    case JSONResponseError = "JSONResponseError"
    case EmptyAPIResponse = "EmptyAPIResponse"
    case SignUpCredentialsError = "SignUpCredentialsError"
    case SignInCredentialsError = "SignInCredentialsError"
    
    //  Add additional custom errors as needed
    //  ...
    
    var localizedDescription: String {
        switch self {
        case.InvalidCredentials:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "Invalid Credentials", comment: "")
        case.JSONResponseError:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "There was an error converting the JSON response", comment: "")
        case.EmptyAPIResponse:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "No data was returned from the request.", comment: "")
        case.SignUpCredentialsError:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "1 or more of your credentials is incorrect. Please check whether your passwords match, your email is a valid email address, or your username is greater than 3 characters.", comment: "")
        case.SignInCredentialsError:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "1 or more of your credentials is incorrect. Please check if your email is a valid email address and both fields are not empty.", comment: "")
        }
    }
}
