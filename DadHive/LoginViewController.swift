//
//  LoginViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks II on 11/20/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import APESuperHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccount: UIButton!
    
    var networklayer: NetworkingLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email.delegate = self
        self.password.delegate = self
        self.loginButton.layer.cornerRadius = 10
        
        APESuperHUD.appearance.cornerRadius = 10
        APESuperHUD.appearance.animateInTime = 1.0
        APESuperHUD.appearance.animateOutTime = 1.0
        APESuperHUD.appearance.backgroundBlurEffect = .light
        APESuperHUD.appearance.iconColor = UIColor.flatGreen
        APESuperHUD.appearance.textColor =  UIColor.flatGreen
        APESuperHUD.appearance.loadingActivityIndicatorColor = UIColor.flatGreen
        APESuperHUD.appearance.defaultDurationTime = 4.0
        APESuperHUD.appearance.cancelableOnTouch = true
        APESuperHUD.appearance.iconWidth = 48
        APESuperHUD.appearance.iconHeight = 48
        APESuperHUD.appearance.messageFontName = "Avenir Next Demi Bold "
        APESuperHUD.appearance.titleFontName = "Avenir Next Demi Bold "
        APESuperHUD.appearance.titleFontSize = 22
        APESuperHUD.appearance.messageFontSize = 14
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case email:
            self.password.becomeFirstResponder()
        case password:
            self.password.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case email:
            if let text = textField.text {
                if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                    if text.characters.count < 3 {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    }
                    
                    if !(text.contains("@")) {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    }
                    
                    if text.characters.count >= 3 && text.contains("@") {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        case password:
            if let text = textField.text {
                if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                    if text.characters.count < 6 {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    } else {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        default:
            break
        }
        return true
    }
    
    @IBAction func login(_ sender: UIButton) {
        DispatchQueue.main.async {
            APESuperHUD.showOrUpdateHUD(icon: .email,
                                        message: "Logging In",
                                        duration: 1000.0,
                                        particleEffectFileName: "FireFliesParticle",
                                        presentingView: self.view,
                                        completion: nil)
        }
        
        let loginData = [
            "email": self.email.text!,
            "password": self.password.text!
            ] as [String : Any]
        networklayer = NetworkingLayer(httpUrl: "https://dadhive.herokuapp.com/api/json/v1/mo-login")
        networklayer!.registration(paramsForTokenRetrieval: loginData) { (data, error) in
            if error == nil {
                print(data)
                /*DispatchQueue.main.asyncAfter(deadline: when) {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "home")
                    UIApplication.shared.keyWindow?.rootViewController = vc
                }*/
            } else {
                print(error)
            }
        }
        
        
        APESuperHUD.showOrUpdateHUD(icon: .email,
                                    message: "Logging In",
                                    duration: 1000.0,
                                    particleEffectFileName: "FireFliesParticle",
                                    presentingView: self.view,
                                    completion: nil)
        
        let when = DispatchTime.now() + 10 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "home")
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
    
}
