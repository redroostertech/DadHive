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

    @IBOutlet var btnAuthenticate: UIButton!
    @IBOutlet var lblGDPR: UILabel!
    @IBOutlet var vwAuthenticationTypeContainer: UIView!
    @IBOutlet var txtFullname: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtPasswordConfirm: UITextField!
    @IBOutlet var txtEmail: UITextField!

    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    var authenticationSwitch: AnimatedSegmentSwitch?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadVideoBG()
        setupSuperHUD()
        setupSwitch()
        loadGDPR()

        txtFullname.addLeftPadding(withWidth: 10.0)
        txtPassword.addLeftPadding(withWidth: 10.0)
        txtPasswordConfirm.addLeftPadding(withWidth: 10.0)
        txtEmail.addLeftPadding(withWidth: 10.0)
        btnAuthenticate.applyCornerRadius()
        btnAuthenticate.addGradientLayer(using: kAppCGColors)

        if authenticationSwitch!.selectedIndex == 0 {
            txtPasswordConfirm.isHidden = true
            txtFullname.isHidden = true
            btnAuthenticate.setText("Login")
        } else {
            txtPasswordConfirm.isHidden = false
            txtFullname.isHidden = false
            btnAuthenticate.setText("Sign Up")
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
            btnAuthenticate.setText("Login")
        } else {
            txtPasswordConfirm.isHidden = false
            txtFullname.isHidden = false
            btnAuthenticate.setText("Sign Up")
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
                showErrorAlert(message: Errors.SignInCredentialsError.localizedDescription)
            }
        } else {
            if let credentials = AuthCredentials(JSON: ["email": txtEmail.text ?? "",
                                                         "password": txtPassword.text ?? "",
                                                         "confirmPassword": txtPasswordConfirm.text ?? "",
                                                         "fullname": txtFullname.text ?? ""]),
                credentials.isValid() == true {
                signup(withCredentials: credentials)
            } else {
                showErrorAlert(message: Errors.SignUpCredentialsError.localizedDescription)
            }
        }
    }

    @IBAction func generate(_ sender: UIButton) {
        generateFakeAccounts()
    }

    func login(withCredentials credentials: AuthCredentials) {
        APESuperHUD.showOrUpdateHUD(icon: .email,
                                    message: "Logging In",
                                    duration: 1000.0,
                                    particleEffectFileName: "FireFliesParticle",
                                    presentingView: self.view,
                                    completion: nil)
        ModuleHandler.shared.firebaseRepository.auth.performLogin(credentials: credentials) { (error) in
            if let err = error {
                APESuperHUD.removeHUD(animated: true, presentingView: self.view)
                self.showAlertErrorIfNeeded(error: err)
            } else {
                ModuleHandler.shared.firebaseRepository.auth.sessionCheck()
            }
        }
    }

    func signup(withCredentials credentials: AuthCredentials) {
        APESuperHUD.showOrUpdateHUD(icon: .email,
                                    message: "Creating Account",
                                    duration: 1000.0,
                                    particleEffectFileName: "FireFliesParticle",
                                    presentingView: self.view,
                                    completion: nil)
        ModuleHandler.shared.firebaseRepository.auth.performRegisteration(usingCredentials: credentials) { (error) in
            if let err = error {
                APESuperHUD.removeHUD(animated: true, presentingView: self.view)
                self.showAlertErrorIfNeeded(error: err)
            } else {
                ModuleHandler.shared.firebaseRepository.auth.sessionCheck()
            }
        }
    }

    var x = 1

    func generateFakeAccounts(){
        let userData: [String: Any] = [
            "email": "test\(x)@gmail.com",
            "name": [
                "fullName" : "Test User \(x)"
            ],
            "uid": Utilities.randomString(length: 25),
            "createdAt": Date().toString(format: CustomDateFormat.timeDate.rawValue),
            "type": 1,
            "settings": [
                "notifications" : false,
                "location" : nil,
                "maxDistance" : 25
            ],
            "profileCreation" : false,
            "userInformation" : [
                "age" : [
                    "info": Int.random(in: 22...42),
                    "title": "Age",
                    "type": "age"
                ],
                "bio" : [
                    "info": "Random bio",
                    "title": "About Me",
                    "type": "bio"
                ],
                "jobTitle" : [
                    "info": "Random Job Title",
                    "title": "Job Title",
                    "type": "jobTitle"
                ],
                "kidsNames" : [
                    "info": "Christian and Jack",
                    "title": "Kids Names",
                    "type": "kidsNames"
                ],
                "location" : [
                    "info": "Random City, State",
                    "title": "Location",
                    "type": "location"
                ]
            ]
        ]
        if let user = User(JSON: userData) {
            FIRFirestoreDB.shared.add(data: user.toJSON(), to: kUsers) {
                (success, results, error) in
                if let error = error {
                    print("Couldn't create user \(self.x)")
                    self.x += 1
                } else {
                    print("Created user \(self.x)")
                    self.x += 1
                }
            }
        } else {
            x += 1
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
        authenticationSwitch!.items = ["Login", "Sign Up"]
        authenticationSwitch!.addTarget(self, action: #selector(switchAuthenticationType), for: .valueChanged)
        vwAuthenticationTypeContainer.addSubview(authenticationSwitch!)
    }

    func setupSuperHUD() {
        APESuperHUD.appearance.cornerRadius = 10
        APESuperHUD.appearance.animateInTime = 1.0
        APESuperHUD.appearance.animateOutTime = 1.0
        APESuperHUD.appearance.backgroundBlurEffect = .light
        APESuperHUD.appearance.iconColor = UIColor.flatGreen
        APESuperHUD.appearance.textColor =  UIColor.flatGreen
        APESuperHUD.appearance.loadingActivityIndicatorColor = UIColor.flatGreen
        APESuperHUD.appearance.defaultDurationTime = 4.0
        APESuperHUD.appearance.cancelableOnTouch = true
        APESuperHUD.appearance.iconWidth = kIconSizeWidth
        APESuperHUD.appearance.iconHeight = kIconSizeHeight
        APESuperHUD.appearance.messageFontName = kFontBody
        APESuperHUD.appearance.titleFontName = kFontTitle
        APESuperHUD.appearance.titleFontSize = kFontSizeTitle
        APESuperHUD.appearance.messageFontSize = kFontSizeBody
    }

    func showHUD() {
        APESuperHUD.showOrUpdateHUD(icon: .email,
                                    message: "Logging In",
                                    duration: 1000.0,
                                    particleEffectFileName: "FireFliesParticle",
                                    presentingView: self.view,
                                    completion: nil)
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
