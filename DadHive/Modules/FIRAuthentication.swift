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

private let locationManager = LocationManager()

private func goTo(vc: UIViewController, forWindow window: UIWindow? = nil) {
    if window == nil {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
    } else {
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

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
}

// MARK: - Session management
extension FIRAuthentication {
    
    // TODO: Refactor navigation from class/method
    static func checkSession(_ window: UIWindow? = nil, goToVC vcID: String = kPermissionsVC) {
        CurrentUser.shared.refresh {
            
            // MARK: - Update user location
            locationManager.updateUserLocation()
            
            // MARK: - Check if `initial setup` for user profile has been completed
            if let initialSetup = CurrentUser.shared.user?.settings?.initialSetup, initialSetup == false {
                let vc = storyBoard.instantiateViewController(withIdentifier: vcID)
                goTo(vc: vc, forWindow: window)
            } else {
                let vc = storyBoard.instantiateViewController(withIdentifier: kCustomTabBar)
                goTo(vc: vc, forWindow: window)
            }
        }
    }

    static func signout(_ window: UIWindow? = nil, goToVC vcID: String = kViewController) {
        CurrentUser.shared.signout { (success) in
            let vc = storyBoard.instantiateViewController(withIdentifier: vcID)
            goTo(vc: vc, forWindow: window)
        }
    }
}
