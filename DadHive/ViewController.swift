//
//  ViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks II on 11/20/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth
import APESuperHUD
import SVProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var btnAuthenticate: UIButton!
    @IBOutlet weak var lblGDPR: UILabel!
    @IBOutlet weak var vwAuthenticationTypeContainer: UIView!
    @IBOutlet weak var txtFullname: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPasswordConfirm: UITextField!
    @IBOutlet var btnGenerate: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet weak var txtEmail: UITextField!

    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    var authenticationSwitch: AnimatedSegmentSwitch?

    override func viewDidLoad() {
        super.viewDidLoad()

        btnGenerate.isHidden = true
        btnDelete.isHidden = true

        loadVideoBG()
        setupSuperHUD()
        setupSwitch()
        loadGDPR()

        DispatchQueue.main.async {
            for view in self.view.subviews {
                if let textField = view as? UITextField {
                    textField.delegate = self
                    textField.addLeftPadding(withWidth: kTextFieldPadding)
                }
            }

            self.btnAuthenticate.applyCornerRadius()
            self.btnAuthenticate.addGradientLayer(using: kAppCGColors)

            if self.authenticationSwitch!.selectedIndex == 0 {
                self.txtPasswordConfirm.isHidden = true
                self.txtFullname.isHidden = true
                self.btnAuthenticate.setText(kLoginText)
            } else {
                self.txtPasswordConfirm.isHidden = false
                self.txtFullname.isHidden = false
                self.btnAuthenticate.setText(kSignUpText)
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appWillEnterForegroundNotification() {
        self.player?.play()
    }
    
    @objc func loopVideo(){
        DispatchQueue.main.async {
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
    }

    @objc
    func switchAuthenticationType() {
        if authenticationSwitch!.selectedIndex == 0 {
            txtPasswordConfirm.isHidden = true
            txtFullname.isHidden = true
            btnAuthenticate.setText(kLoginText)
        } else {
            txtPasswordConfirm.isHidden = false
            txtFullname.isHidden = false
            btnAuthenticate.setText(kSignUpText)
        }
    }

    @IBAction func authenticate(_ sender: UIButton) {
        if authenticationSwitch!.selectedIndex == 0 {
            if let credentials = AuthCredentials(JSON: [
                "email": txtEmail.text ?? "",
                "password": txtPassword.text ?? ""
                ]),
                credentials.isValid() {
                login(withCredentials: credentials)
            } else {
                showErrorAlert(message: DadHiveError.signInCredentialsError.rawValue)
            }
        } else {
            if let credentials = AuthCredentials(JSON: ["email": txtEmail.text ?? "",
                                                         "password": txtPassword.text ?? "",
                                                         "confirmPassword": txtPasswordConfirm.text ?? "",
                                                         "fullname": txtFullname.text ?? ""]),
                credentials.isValid() == true {
                signup(withCredentials: credentials)
            } else {
                showErrorAlert(message: DadHiveError.signUpCredentialsError.rawValue)
            }
        }
    }

    @IBAction func generate(_ sender: UIButton) {
        FakeDataGenerator().generateFakeUserAccounts(20)
    }

    @IBAction func deleteAllUsers(_ sender: UIButton) {
        FakeDataGenerator().deleteFakeUsers()
    }


    func login(withCredentials credentials: AuthCredentials) {
        showHUD("Logging In")
        FIRRepository.shared.auth.performLogin(credentials: credentials) { (error) in
            if let err = error {
                self.dismissHUD()
                self.showAlertErrorIfNeeded(error: err)
            } else {
                FIRRepository.shared.auth.checkSession(nil)
            }
        }
    }

    func signup(withCredentials credentials: AuthCredentials) {
        showHUD("Creating Account")
        FIRRepository.shared.auth.performRegisteration(usingCredentials: credentials) { (error) in
            if let err = error {
                self.dismissHUD()
                self.showAlertErrorIfNeeded(error: err)
            } else {
                CurrentUser.shared.refreshCurrentUser {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "UploadProfilePhotoVC")
                    self.goTo(vc: vc, forWindow: nil)
                }
            }
        }
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

}

extension ViewController {
    func loadVideoBG() {
        let path = Bundle.main.url(forResource: "DadHiveBG-Vid",
                                   withExtension: "mp4")
        self.player = AVPlayer(url: path!)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.videoGravity = .resizeAspectFill
        self.playerLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(self.playerLayer!,
                                       at: 0)

        let colorOverlay = UIView()
        colorOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        colorOverlay.frame = self.view.frame
        self.view.insertSubview(colorOverlay,
                                at: 1)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loopVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForegroundNotification),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
    }
}

extension ViewController {

    func setupSwitch() {
        vwAuthenticationTypeContainer.backgroundColor = .clear
        authenticationSwitch = AnimatedSegmentSwitch()
        authenticationSwitch!.frame = vwAuthenticationTypeContainer.bounds
        authenticationSwitch!.autoresizingMask = [.flexibleWidth]
        authenticationSwitch!.backgroundColor = .white
        authenticationSwitch!.selectedTitleColor = .white
        authenticationSwitch!.titleColor = AppColors.lightGreen
        authenticationSwitch!.font = UIFont(name: kFontButton, size: kFontSizeButton)
        authenticationSwitch!.thumbColor = AppColors.lightGreen
        authenticationSwitch!.items = [kLoginSwitchText, kSignUpSwitchText]
        authenticationSwitch!.addTarget(self, action: #selector(switchAuthenticationType), for: .valueChanged)
        vwAuthenticationTypeContainer.addSubview(authenticationSwitch!)
    }

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
