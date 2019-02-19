//
//  CurrentUser.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/18/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import Firebase

class CurrentUser {

    static let shared = CurrentUser()
    var defaults: DefaultsManager!
    var user: User?
    var apiRepo: APIRepository!

    private init() {
        self.defaults = DefaultsManager()
        self.apiRepo = ModuleHandler.shared.apiRepository
    }

    func signout(_ completion: @escaping(Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            user = nil
            UserDefaults.standard.set(nil, forKey: kLastUser)
            UserDefaults.standard.set(nil, forKey: kAuthorizedUser)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func refreshCurrentUser(_ completion: (() -> Void)? = nil) {
        if let firUser = Auth.auth().currentUser {
            retrieveUser(withId: firUser.uid, completion: {
                (user, error, data) in
                if let user = user, let data = data {
                UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: data), forKey: kAuthorizedUser)
                    self.user = user
                    completion?()
                } else {
                    self.user = nil
                    completion?()
                }
            })
        } else {
            self.user = nil
            completion?()
        }
    }

    func updateUser(withData data: [String: Any], completion: @escaping (Error?) -> Void) {
        guard let user = self.user else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
            return
        }
        FIRFirestoreDB.shared.update(withData: data, from: kUsers, at: user.key ?? "") {
            (success, error) in
            if let err = error {
                completion(err)
            } else {
                self.refreshCurrentUser()
                completion(nil)
            }
        }
    }
    
    private func retrieveUser(withId id: String, completion: @escaping (User?, Error?, [String: Any]?) -> Void) {
        let parameters: [String: String] = [
            "userId": id
        ]
        apiRepo.performRequest(path: Api.Endpoint.getUser, method: .post, parameters: parameters) { (response, error) in
            if let err = error {
                print(err)
                completion(nil, err, nil)
            } else {
                if let res = response as? [String: Any], let data = res["data"] as? [String: Any], let userData = data["user"] as? [String: Any], let user = User(JSON: userData) {
                    completion(user, nil, userData)
                } else {
                    FIRAuthentication.shared.signout()
                }
            }
        }
//        FIRFirestoreDB.shared.retrieveUser(withId: id, completion: {
//            (success, document, error) in
//            if let error = error {
//                print(error)
//                completion(nil, error, nil)
//            } else {
//                if let document = document {
//                    var userData = document.data()
//                    userData["snapshotKey"] = document.documentID
//                    let user = User(JSON: userData)
//                    completion(user, nil, userData)
//                } else {
//                    FIRAuthentication.shared.signout()
//                }
//            }
//        })
    }
}

//  Using RealtimeDB
extension CurrentUser {
//    private func retrieveUser(withId id: String, completion: @escaping (User?, Error?, [String: Any]?) -> Void) {
//        FIRRealtimeDB.shared.retrieveDataOnce(atChild: kUsers, whereKey: "uid", isEqualTo: id) {
//            (success, snapshot, error) in
//            if let err = error {
//                completion(nil, err, nil)
//            } else {
//                guard let data = snapshot, data.childrenCount > 0 else {
//                    return
//                }
//                print(data)
//                if let rawItem = data.children.allObjects.first as? DataSnapshot, var item = rawItem.value as? [String: Any] {
//                    item["snapshotKey"] = String(describing: rawItem.key)
//                    completion(User(JSON: item), nil, item)
//                } else {
//                    completion(nil, Errors.EmptyAPIResponse, nil)
//                }
//            }
//        }
//     }

//    func updateUser(withData data: [String: Any], completion: @escaping (Error?) -> Void) {
//        guard let user = self.user else {
//            completion(Errors.EmptyAPIResponse)
//            return
//        }
//        FIRRealtimeDB
//            .shared
//            .update(withData: data,
//                    atChild: kUsers + "/" + user.userKey) { (success, random, error) in
//                        if let err = error {
//                            completion(err)
//                        } else {
//                            self.refreshCurrentUser()
//                            completion(nil)
//                        }
//        }
//    }
}
