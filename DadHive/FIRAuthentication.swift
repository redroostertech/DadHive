import Foundation
import Firebase

private var errorInvalidCredentials: DadHiveError {
    return DadHiveError.invalidCredentials
}
private var errorJsonResponse: DadHiveError {
    return DadHiveError.jsonResponseError
}
private func generateError(fromError error: DadHiveError) -> NSError {
    return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : error.rawValue])
}
private let storyBoard = UIStoryboard(name: "Main", bundle: nil)

private func goTo(vc: UIViewController, forWindow window: UIWindow? = nil) {
    if window == nil {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
    } else {
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

private func createUser(email: String, name: String, uid: String, _ completion: @escaping (Error?) -> Void) {
    let parameters: [String: Any] = [
        "email": email,
        "name": name,
        "uid": uid,
        "type": 1
    ]
    APIRepository().performRequest(path: Api.Endpoint.createUser, method: .post, parameters: parameters) { (response, error) in
        if let err = error {
            print(err)
            completion(generateError(fromError: errorJsonResponse))
        } else {
            if let res = response as? [String: Any], let _ = res["data"] as? [String: Any] {
                completion(nil)
            } else {
                completion(generateError(fromError: errorJsonResponse))
            }
        }
    }
}

private let locationManager = LocationManager()

typealias SessionIsActive = Bool

// MARK: - Primary Authentication
class FIRAuthentication {
    
    static func login(credentials: AuthCredentials?, completion: @escaping (Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(generateError(fromError: errorInvalidCredentials))
        }
        Auth.auth().signIn(withEmail: credentials.email ?? "", password: credentials.password ?? "") { (results, error) in
            if let error = error {
                completion(error)
            } else {
                guard let _ = results else {
                    return completion(generateError(fromError: DadHiveError.jsonResponseError))
                }
                completion(nil)
            }
        }
    }

    static func register(usingCredentials credentials: AuthCredentials?, completion: @escaping (Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(generateError(fromError: errorInvalidCredentials))
        }
        Auth.auth().createUser(withEmail: credentials.email ?? "",
                               password: credentials.password ?? "")
        { (results, error) in
            if let error = error {
                completion(error)
            } else {
                guard let results = results, let email = credentials.email, let name = credentials.fullname else {
                    return completion(generateError(fromError: errorJsonResponse))
                }
                createUser(email: email, name: name, uid: results.user.uid) {
                    (error) in
                    completion(error)
                }
            }
        }
    }
}

// MARK: - Session management
extension FIRAuthentication {
    
    // TODO: Refactor navigation from class/method
    static func checkSession(_ window: UIWindow? = nil, goToVC vcID: String = "PermissionsVC") {
        CurrentUser.shared.refresh {
            
            // MARK: - Update user location
            locationManager.updateUserLocation()
            
            if let initialSetup = CurrentUser.shared.user?.settings?.initialSetup, initialSetup == false {
                let vc = storyBoard.instantiateViewController(withIdentifier: vcID)
                goTo(vc: vc, forWindow: window)
            } else {
                let vc = storyBoard.instantiateViewController(withIdentifier: "CustomTabBar")
                goTo(vc: vc, forWindow: window)
            }
        }
    }

    static func signout(_ window: UIWindow? = nil, goToVC vcID: String = "ViewController") {
        CurrentUser.shared.signout { (success) in
            let vc = storyBoard.instantiateViewController(withIdentifier: vcID)
            goTo(vc: vc, forWindow: window)
        }
    }
}
