import Foundation
import FirebaseCore
import FirebaseAuth

private let storyBoard = UIStoryboard(name: "Main", bundle: nil)
private let locationManager = LocationManager()

private var errorInvalidCredentials: DadHiveError {
    return DadHiveError.invalidCredentials
}
private var errorJsonResponse: DadHiveError {
    return DadHiveError.jsonResponseError
}
private func generateError(fromError error: DadHiveError) -> NSError {
    return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : error.rawValue])
}
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

    static var uid: String? {
        return Auth.auth().currentUser == nil ? nil: Auth.auth().currentUser!.uid
    }
    
    static func login(credentials: AuthCredentials, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: credentials.email, password: credentials.password) { (results, error) in
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

  static func forgotPassword(email: String, completion: @escaping (Error?) -> Void) {
    Auth.auth().sendPasswordReset(withEmail: email) { error in
      if let err = error {
        completion(error)
      } else {
        completion(nil)
      }
    }
  }

    static func signout() {
        CurrentUser.shared.signout { (isSignedOut) in
          if isSignedOut {
            let vc = storyBoard.instantiateViewController(withIdentifier: "GetStarted")
            UIApplication.shared.keyWindow?.rootViewController = vc
          }
      }
    }

    static func checkSession(_ window: UIWindow? = nil, goToVC vcID: String = kPermissionsVC) {

        if Auth.auth().currentUser != nil {

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

        } else {

            FIRAuthentication.signout()

        }
    }

}
