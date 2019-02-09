//
//  FIRAuth.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/17/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import Firebase

class FIRAuthentication {
    static let shared = FIRAuthentication()

    private init() { }
    
    func performLogin(credentials: AuthCredentials?,
                      completion: @escaping (Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.invalidCredentials.rawValue]))
        }
        Auth.auth().signIn(withEmail: credentials.email ?? "",
                           password: credentials.password ?? "") { (results, error) in
            if let error = error {
                completion(error)
            } else {
                guard let _ = results else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                }
                completion(nil)
            }
        }
    }

    func performRegisteration(usingCredentials credentials: AuthCredentials?,
                              completion: @escaping (Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.invalidCredentials.rawValue]))
        }
        
        Auth.auth().createUser(withEmail: credentials.email ?? "",
                               password: credentials.password ?? "") { (results, error) in
            if let error = error {
                completion(error)
            } else {
                guard let results = results else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                }
                let userData: [String: Any] = [
                    "email": credentials.email ?? "",
                    "name": [
                        "fullName" : (credentials.fullname ?? "")
                    ],
                    "uid": results.uid,
                    "createdAt": results.metadata.creationDate?.toString(format: CustomDateFormat.timeDate.rawValue),
                    "type": 1,
                    "settings": [
                        "notifications" : false,
                        "location" : nil,
                        "maxDistance" : 25
                    ],
                    "profileCreation" : false
                ]
                if let user = User(JSON: userData) {
                    self.createUser(withData: user, completion: {
                        user in
                        guard let _ = user else {
                            return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                        }
                        completion(nil)
                    })
                }
            }
        }
    }
    
    func sessionCheck(_ window: UIWindow? = nil) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let _ = Auth.auth().currentUser {
            CurrentUser.shared.refreshCurrentUser {
                guard let _ = CurrentUser.shared.user else {
                    self.signout(window)
                    return
                }
                let vc = sb.instantiateViewController(withIdentifier: "CustomTabBar")
                self.goTo(vc: vc, forWindow: window)
            }
        } else {
            self.signout(window)
        }
    }
    
    func signout(_ window: UIWindow? = nil) {
        CurrentUser.shared.signout { (success) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "ViewController")
            self.goTo(vc: vc, forWindow: window)
        }
    }

    private func goTo(vc: UIViewController, forWindow window: UIWindow? = nil) {
        if window == nil {
            UIApplication.shared.keyWindow?.rootViewController = vc
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        } else {
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        }
    }
}

extension FIRAuthentication {
    func createUser(withData data: User, completion: @escaping(User?) -> Void) {
        ModuleHandler.shared.firebaseRepository.firestore.add(data: data.toJSON(), to: kUsers) { (success, result, error) in
            completion(data)
        }
    }
}
