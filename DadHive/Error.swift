//
//  File.swift
//  PopViewers
//
//  Created by Michael Westbrooks II on 5/13/18.
//  Copyright © 2018 MVPGurus. All rights reserved.
//

import Foundation

enum Errors: Error {
    case InvalidCredentials
    case JSONResponseError
    case EmptyAPIResponse
    case SignUpCredentialsError
    case SignInCredentialsError
    case MaximumSwipesReached
    case NoMoreUsersAvailable
    
    //  Add additional custom errors as needed
    //  ...

}

extension Errors: LocalizedError {
    
    var errorDescription: String {
        switch self {
        case .InvalidCredentials:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "Invalid Credentials", comment: "")
        case .JSONResponseError:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "There was an error converting the JSON response", comment: "")
        case .EmptyAPIResponse:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "No data was returned from the request.", comment: "")
        case .SignUpCredentialsError:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "1 or more of your credentials is incorrect. Please check whether your passwords match, your email is a valid email address, or your username is greater than 3 characters.", comment: "")
        case .SignInCredentialsError:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "1 or more of your credentials is incorrect. Please check if your email is a valid email address and both fields are not empty.", comment: "")
        case .MaximumSwipesReached:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "You have reached the maximum numbebr of swipes today. Either upgrade for unlimited swipes or come back tomorrow.", comment: "")
        case .NoMoreUsersAvailable:
            return NSLocalizedString("\(Errors.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "No more users in your area.", comment: "")
        }
    }
}

enum DadHiveError: String {
    case invalidCredentials = "Invalid Credentials"
    case jsonResponseError = "There was an error converting the JSON response"
    case emptyAPIResponse = "No data was returned from the request."
    case signUpCredentialsError = "1 or more of your credentials is incorrect. Please check whether your passwords match, your email is a valid email address, or your username is greater than 3 characters."
    case signInCredentialsError = "1 or more of your credentials is incorrect. Please check if your email is a valid email address and both fields are not empty."
    case maximumSwipesReached = "You have reached the maximum numbebr of swipes today. Either upgrade for unlimited swipes or come back tomorrow."
    case noMoreUsersAvailable = "No more users in your area."
    case locationAccessDisabled = "Please provide access to your location to find users in your area."
}
