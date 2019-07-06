import UIKit

private var videoBackground: VideoBackground?
private var authenticationSwitch: AnimatedSegmentSwitch?

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var btnAuthenticate: UIButton!
    @IBOutlet private var lblGDPR: UILabel!
    @IBOutlet private var txtPassword: UITextField!
    @IBOutlet private var txtEmail: UITextField!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoBackground = VideoBackground(withPathFromBundle: "DadHiveBG-Vid", ofFileType: "mp4", forView: self.view)
        if let videobackground = videoBackground {
            videobackground.isLoopingEnabled = true
            videobackground.videoOverlayColor = .white
        }

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
        
        btnAuthenticate.applyCornerRadius()
        btnAuthenticate.addGradientLayer(using: kAppCGColors)
        btnAuthenticate.setText(kLoginText)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let videobackground = videoBackground {
            videobackground.show()
            videobackground.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let videobackground = videoBackground {
            videobackground.destroy()
        }
    }
    
    // MARK: - Private member functions
    private func loadGDPR() {
        lblGDPR.font = UIFont(name: kFontCaption, size: kFontSizeCaption)
        lblGDPR.textColor = .flatBlack
    }
    
    private func login(withCredentials credentials: AuthCredentials) {
        showHUD("Logging In")
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
            let password = txtPassword.text,
            let credentials = AuthCredentials(JSON: ["email": email, "password": password]),
            credentials.isValid()else {
            return showErrorAlert(message: DadHiveError.signInCredentialsError.rawValue)
        }
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
