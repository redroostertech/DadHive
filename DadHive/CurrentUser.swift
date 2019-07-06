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
    
    fileprivate func updateUser(_ data: [String: Any],  completion: @escaping (User?, Error?, [String: Any]?) -> Void) {
        guard let convertedData = data as? [String: String] else {
            return completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]), nil)
        }
        let parameters: [String: String] = convertedData
        apiRepo.performRequest(path: Api.Endpoint.editUserProfile, method: .post, parameters: parameters) { (response, error) in
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

    func updateProfile(withData data: [String: Any?], completion: @escaping (Error?) -> Void) {
        guard let user = self.user else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
            return
        }
        var params = data
        params["userId"] = user.uid ?? ""
        updateUser(params) { (user, error, userDict) in
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
