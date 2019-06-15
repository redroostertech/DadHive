import UIKit

private var videoBackground: VideoBackground?
private var authenticationSwitch: AnimatedSegmentSwitch?

class ViewController: UIViewController {

    @IBOutlet private var btnAuthenticate: UIButton!
    @IBOutlet private var lblGDPR: UILabel!
    @IBOutlet private var txtPassword: UITextField!
    @IBOutlet private var btnGenerate: UIButton!
    @IBOutlet private var btnDelete: UIButton!
    @IBOutlet private var txtEmail: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        btnGenerate.isHidden = true
        btnDelete.isHidden = true

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

    @IBAction func authenticate(_ sender: UIButton) {
        guard let email = txtEmail.text,
            let password = txtPassword.text,
            let credentials = AuthCredentials(JSON: ["email": email, "password": password]),
            credentials.isValid()else {
            return showErrorAlert(message: DadHiveError.signInCredentialsError.rawValue)
        }
        login(withCredentials: credentials)
    }

    @IBAction func generate(_ sender: UIButton) {
        FakeDataGenerator().generateFakeUserAccounts(20)
    }

    @IBAction func deleteAllUsers(_ sender: UIButton) {
        FakeDataGenerator().deleteFakeUsers()
    }

    func login(withCredentials credentials: AuthCredentials) {
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
}

extension ViewController {
    func loadGDPR() {
        lblGDPR.font = UIFont(name: kFontCaption, size: kFontSizeCaption)
        lblGDPR.textColor = .flatBlack
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
