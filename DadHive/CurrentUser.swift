import Foundation
import Firebase

class CurrentUser {
    static let shared = CurrentUser()
    
    private var defaults = DefaultsManager()
    private var apiRepo = APIRepository()

    var user: User?

    private init() { }

    fileprivate func setUser(_ user: User) {
        self.user = user
    }
    
    fileprivate func setNilUser() {
        self.user = nil
    }
    
    fileprivate func retrieveUser(withId id: String, completion: @escaping (User?, Error?, [String: Any]?) -> Void) {
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
                    FIRAuthentication.signout()
                }
            }
        }
    }
}

// MARK: - Class methods
extension CurrentUser {
    func signout(_ completion: ((Bool) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            self.setNilUser()
            self.defaults.setNilDefault(forKey: kLastUser)
            self.defaults.setNilDefault(forKey: kAuthorizedUser)
            completion?(true)
        } catch {
            completion?(false)
        }
    }
    
    func refresh(_ completion: (() -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            signout()
            completion?()
            return
        }
        retrieveUser(withId: user.uid, completion: { (user, error, data) in
            if let user = user, let data = data {
                self.defaults.setDefault(withData: data, forKey: kAuthorizedUser)
                self.setUser(user)
                completion?()
            } else {
                self.signout()
                completion?()
            }
        })
    }

    func updateProfile(withData data: [String: Any], completion: @escaping (Error?) -> Void) {
        guard let user = self.user else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
            return
        }
        FIRFirestoreDB.shared.update(withData: data, from: kUsers, at: user.key ?? "") { (success, error) in
            if let err = error {
                completion(err)
            } else {
                self.refresh({
                    completion(nil)
                })
            }
        }
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
    //                    FIRAuthentication.signout()
    //                }
    //            }
    //        })
}
