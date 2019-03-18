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
                guard let email = credentials.email, let name = credentials.fullname else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                }
                let parameters: [String: Any] = [
                    "email": email,
                    "name": name,
                    "uid": results.user.uid,
                    "type": 1
                ]
                APIRepository().performRequest(path: Api.Endpoint.createUser, method: .post, parameters: parameters) { (response, error) in
                    if error != nil {
                        print(error)
                        completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    } else {
                        if let res = response as? [String: Any], let data = res["data"] as? [String: Any] {
                            completion(nil)
                        } else {
                            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                        }
                    }
                }
            }
        }
    }

    func checkSession(_ window: UIWindow? = nil) {
        CurrentUser.shared.refreshCurrentUser {
            if let initialSetup = CurrentUser.shared.user?.settings?.initialSetup, initialSetup == false {
                self.sessionCheck(window, goToVC: "PermissionsVC")
            } else {
                self.sessionCheck(window)
            }
        }
    }
    
    func sessionCheck(_ window: UIWindow? = nil, goToVC vcID: String = "CustomTabBar") {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let _ = Auth.auth().currentUser {
            let vc = sb.instantiateViewController(withIdentifier: vcID)
            self.goTo(vc: vc, forWindow: window)
        } else {
            self.signout(window)
        }
    }
    
    func signout(_ window: UIWindow? = nil, goToVC vcID: String = "ViewController") {
        CurrentUser.shared.signout { (success) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcID)
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

//  MARK:- Deprecated
extension FIRAuthentication {
    func createUser(withData data: User, completion: @escaping(User?) -> Void) {
        FIRRepository.shared.firestore.add(data: data.toJSON(), to: kUsers) { (success, result, error) in
            completion(data)
        }
    }
}
