import UIKit
import RRoostSDK

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var btnAuthenticate: UIButton!
    @IBOutlet private var lblGDPR: UILabel!
    @IBOutlet private var txtPassword: UITextField!
    @IBOutlet private var txtEmail: UITextField!
    @IBOutlet private var imageLogo: UIImageView!
    @IBOutlet weak var btnForgotPassword: UIButton!

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
  @IBAction func forgotPassword(_ sender: UIButton) {
    let alert = UIAlertController(style: .alert, title: "Forgot Password")

    var email: String?

    let config: TextField.Config = { textField in
      textField.becomeFirstResponder()
      textField.textColor = .black
      textField.placeholder = "Email Address"
      textField.left(image: UIImage(named: "ic_account"), color: .black)
      textField.leftViewPadding = 12
      textField.borderWidth = 1
      textField.cornerRadius = 8
      textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
      textField.backgroundColor = nil
      textField.keyboardAppearance = .default
      textField.keyboardType = .default
      textField.isSecureTextEntry = false
      textField.returnKeyType = .done
      textField.action { textField in
        guard let text = textField.text else { return }
        email = text
      }
    }
    alert.addOneTextField(configuration: config)
    alert.addAction(image: nil, title: "OK", color: nil, style: .default, isEnabled: true) { action in
      guard let text = email else { return }
      FIRAuthentication.forgotPassword(email: text, completion: { error in
        DispatchQueue.main.async {
          alert.dismiss(animated: true, completion: nil)
        }
        if let _ = error {
          self.showError("Something went wrong trying to reset your password. Please try again.")
        } else {
          self.showHUD("Success! Check your email for the password reset link.")
        }
      })
    }
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
