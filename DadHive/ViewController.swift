import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var btnAuthenticate: UIButton!
    @IBOutlet private var lblGDPR: UILabel!
    @IBOutlet private var txtPassword: UITextField!
    @IBOutlet private var txtEmail: UITextField!
    @IBOutlet private var imageLogo: UIImageView!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        view.bringSubview(toFront: imageLogo)
        view.bringSubview(toFront: btnAuthenticate)
        view.bringSubview(toFront: lblGDPR)
        view.bringSubview(toFront: txtEmail)
        view.bringSubview(toFront: txtPassword)

        setupSuperHUD()
        loadGDPR()

        DispatchQueue.main.async {
            for view in self.view.subviews {
                if let textField = view as? UITextField {
                    textField.delegate = self
                    textField.addLeftPadding(withWidth: kTextFieldPadding)
                    textField.clearsOnBeginEditing = true
                }
            }
        }
        
        btnAuthenticate.setText(kLoginText)
    }
    
    // MARK: - Private member functions
    private func loadGDPR() {
        lblGDPR.font = UIFont(name: kFontCaption, size: kFontSizeCaption)
        lblGDPR.textColor = .flatBlack
    }
    
    private func login(withCredentials credentials: AuthCredentials) {
        FIRAuthentication.login(credentials: credentials) { (error) in
            if let err = error {
                self.hideHUD()
                self.showAlertErrorIfNeeded(error: err)
            } else {
                FIRAuthentication.checkSession()
            }
        }
    }

    // MARK: - IBActions
    @IBAction func authenticate(_ sender: UIButton) {
        guard let email = txtEmail.text,
            let password = txtPassword.text else {
            return showErrorAlert(message: DadHiveError.signInCredentialsError.rawValue)
        }
      let credentials = AuthCredentials(email: email, password: password)
      guard credentials.isValid() else { return showErrorAlert(message: DadHiveError.signInCredentialsError.rawValue) }
      login(withCredentials: credentials)
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
