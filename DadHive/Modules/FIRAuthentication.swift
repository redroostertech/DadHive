import Foundation
import Firebase

class FIRAuthentication: NSObject {
    static var errorInvalidCredentials: DadHiveError {
        return DadHiveError.invalidCredentials
    }
    
    static var errorJsonResponse: DadHiveError {
        return DadHiveError.jsonResponseError
    }
    
    static func login(credentials: AuthCredentials?, completion: @escaping (Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(FIRAuthentication.generateError(fromError: errorInvalidCredentials))
        }
        Auth.auth().signIn(withEmail: credentials.email ?? "", password: credentials.password ?? "") { (results, error) in
            if let error = error {
                completion(error)
            } else {
                guard let _ = results else {
                    return completion(FIRAuthentication.generateError(fromError: DadHiveError.jsonResponseError))
                }
                completion(nil)
            }
        }
    }

    static func register(usingCredentials credentials: AuthCredentials?, completion: @escaping (Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(FIRAuthentication.generateError(fromError: errorInvalidCredentials))
        }
        Auth.auth().createUser(withEmail: credentials.email ?? "", password: credentials.password ?? "") { (results, error) in
            if let error = error {
                completion(error)
            } else {
                guard let results = results, let email = credentials.email, let name = credentials.fullname else {
                    return completion(FIRAuthentication.generateError(fromError: errorJsonResponse))
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
                        completion(FIRAuthentication.generateError(fromError: errorJsonResponse))
                    } else {
                        if let res = response as? [String: Any], let data = res["data"] as? [String: Any] {
                            completion(nil)
                        } else {
                            completion(FIRAuthentication.generateError(fromError: errorJsonResponse))
                        }
                    }
                }
            }
        }
    }
    
    static func checkIsSessionActive(_ window: UIWindow? = nil) {
        CurrentUser.shared.refresh {
            if let initialSetup = CurrentUser.shared.user?.settings?.initialSetup, initialSetup == false {
                FIRAuthentication.sessionCheck(window, goToVC: "PermissionsVC")
            } else {
                FIRAuthentication.sessionCheck(window)
            }
        }
    }
    
    private static func sessionCheck(_ window: UIWindow? = nil, goToVC vcID: String = "CustomTabBar") {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let _ = Auth.auth().currentUser {
            let vc = sb.instantiateViewController(withIdentifier: vcID)
            self.goTo(vc: vc, forWindow: window)
        } else {
            FIRAuthentication.signout(window)
        }
    }
    
    private static func checkInitialSetup() {
        
    }
    
    static func signout(_ window: UIWindow? = nil, goToVC vcID: String = "ViewController") {
        CurrentUser.shared.signout { (success) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcID)
            FIRAuthentication.goTo(vc: vc, forWindow: window)
        }
    }
}

extension FIRAuthentication {
    fileprivate static func generateError(fromError error: DadHiveError) -> NSError {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : error.rawValue])
    }

    fileprivate static func goTo(vc: UIViewController, forWindow window: UIWindow? = nil) {
        if window == nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        } else {
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        }
    }
}
