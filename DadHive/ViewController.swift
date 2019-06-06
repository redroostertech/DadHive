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

    func setupSuperHUD() {
        HUDAppearance.cornerRadius = 10
        HUDAppearance.animateInTime = 1.0
        HUDAppearance.animateOutTime = 1.0
        HUDAppearance.iconColor = UIColor.flatGreen
        HUDAppearance.titleTextColor =  UIColor.flatGreen
        HUDAppearance.loadingActivityIndicatorColor = UIColor.flatGreen
        HUDAppearance.cancelableOnTouch = true
        HUDAppearance.iconSize = CGSize(width: kIconSizeWidth, height: kIconSizeHeight)
        HUDAppearance.messageFont = UIFont(name: kFontBody, size: kFontSizeBody) ?? UIFont.systemFont(ofSize: kFontSizeBody, weight: .regular)
        HUDAppearance.titleFont = UIFont(name: kFontTitle, size: kFontSizeTitle) ?? UIFont.systemFont(ofSize: kFontSizeTitle, weight: .bold)
    }

    func showHUD(_ text: String = "Finding Users") {
        APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: 4.0), title: nil, message: text, completion: nil)
    }

    func dismissHUD() {
        APESuperHUD.dismissAll(animated: true)
    }

    func loadGDPR() {
        lblGDPR.font = UIFont(name: kFontCaption, size: kFontSizeCaption)
        lblGDPR.textColor = .flatBlack
    }

    func showErrorAlert(message: String?) {
        SVProgressHUD.showError(withStatus: message ?? "")
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }

    func showAlertErrorIfNeeded(error: Error?) {
        if let e = error {
            showErrorAlert(message: e.localizedDescription)
        } else {
            SVProgressHUD.dismiss()
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
