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

    private init() {
        self.defaults = DefaultsManager()
    }

    func signout(_ completion: @escaping(Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            user = nil
            UserDefaults.standard.set(nil, forKey: "authorizedUser")
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
                    UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: data), forKey: "authorizedUser")
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
            completion(Errors.EmptyAPIResponse)
            return
        }
        FIRFirestoreDB.shared.update(withData: data, from: kUsers, at: user.userKey) {
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
        FIRFirestoreDB.shared.retrieveUser(withId: id, completion: {
            (success, snapshot, error) in
            if let error = error {
                print(error)
                completion(nil, error, nil)
            } else {
                if snapshot?.count ?? 0 > 0 {
                    if var userData = snapshot?[0].data() {
                        userData["snapshotKey"] = snapshot![0].documentID
                        let user = User(JSON: userData)
                        completion(user, nil, userData)
                    } else {
                        completion(nil, Errors.EmptyAPIResponse, nil)
                    }
                } else {
                    FIRAuthentication.shared.signout()
                }
            }
        })
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
