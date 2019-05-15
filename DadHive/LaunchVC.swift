import UIKit

class LaunchVC: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FIRAuthentication.checkIsSessionActive()
    }
}
