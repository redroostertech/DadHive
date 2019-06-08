import UIKit
import FirebaseAuth
import APESuperHUD
import SVProgressHUD

class ViewController: UIViewController {

    @IBOutlet private var btnAuthenticate: UIButton!
    @IBOutlet private var lblGDPR: UILabel!
    @IBOutlet private var txtPassword: UITextField!
    @IBOutlet private var btnGenerate: UIButton!
    @IBOutlet private var btnDelete: UIButton!
    @IBOutlet private var txtEmail: UITextField!

    var videobackground: VideoBackground?
    
    var authenticationSwitch: AnimatedSegmentSwitch?

    override func viewDidLoad() {
        super.viewDidLoad()

        btnGenerate.isHidden = true
        btnDelete.isHidden = true

        videobackground = VideoBackground(withPathFromBundle: "DadHiveBG-Vid", ofFileType: "mp4", forView: self.view)
        videobackground?.isLoopingEnabled = true
        videobackground?.videoOverlayColor = .white

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

            self.btnAuthenticate.applyCornerRadius()
            self.btnAuthenticate.addGradientLayer(using: kAppCGColors)
            self.btnAuthenticate.setText(kLoginText)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videobackground?.displayVideo()
        videobackground?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videobackground?.destroy()
    }

    @IBAction func authenticate(_ sender: UIButton) {
        guard let email = txtEmail.text, let password = txtPassword.text, let credentials = AuthCredentials(JSON: ["email": email, "password": password]), credentials.isValid() == true else {
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
                self.dismissHUD()
                self.showAlertErrorIfNeeded(error: err)
            } else {
                FIRAuthentication.checkIsSessionActive()
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
