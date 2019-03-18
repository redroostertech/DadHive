//
//  RegisterViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks II on 11/20/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import ChameleonFramework
import APESuperHUD

class RegisterViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var registrationTable: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var preReg: SkyFloatingLabelTextField!
    @IBOutlet weak var fullName: SkyFloatingLabelTextField!
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    
    var networklayer: NetworkingLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preReg.delegate = self
        self.fullName.delegate = self
        self.email.delegate = self
        self.password.delegate = self
        self.registrationTable.delegate = self
        self.registrationTable.dataSource = self
        self.uploadPhotoButton.layer.cornerRadius = 10
        self.profileImage.layer.cornerRadius = 10
        self.navigationController?.hidesNavigationBarHairline = true
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 37))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "dadhive-hive")
        imageView.image = image
        self.navigationItem.titleView = imageView

        setupSuperHUD()

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
        showHUD()
    }

    func showHUD() {
        APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: 4.0), title: nil, message: "Finding Profile", completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case preReg:
            guard let text = preReg.text, text.characters.count >= 1 else {
                return self.fullName.becomeFirstResponder()
            }
            self.query(forPreregesteredUsers: text)
        case self.fullName:
            self.email.becomeFirstResponder()
        case email:
            self.password.becomeFirstResponder()
        case password:
            self.password.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    func query(forPreregesteredUsers code: String) {
        showHUD()
    
        let searchData = [
            "regcode": self.preReg.text!,
        ]
        networklayer = NetworkingLayer(httpUrl: "https://dadhive.herokuapp.com/api/json/v1/mo-lookup")
        networklayer!.query(paramsForTokenRetrieval: searchData) { (data, error) in
            if error == nil {
                print(data!)
                guard let prefill = data else {
                    print("There was an error")
                    return
                }
                DispatchQueue.main.async {
                    self.showHUD()
                }
                
                DispatchQueue.main.async {
                    self.email.text = String(describing: prefill.value(forKey: "uemail")!)
                    self.fullName.text = String(describing: prefill.value(forKey: "uname")!)
                }
            } else {
                let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                }
            }
        }
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case preReg:
            print("Do Nothing")
        case fullName:
            print("Do Nothing")
        case email:
            if let text = textField.text {
                if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                    if text.characters.count < 3 {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    }
                    
                    if !(text.contains("@")) {
                        floatingLabelTextField.errorMessage = "Invalid email format"
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
                        floatingLabelTextField.errorMessage = "Invalid password format"
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
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func create(_ sender: UIButton) {
        let loginData = [
            "email": self.email.text!,
            "password": self.password.text!
            ]
        networklayer = NetworkingLayer(httpUrl: "https://dadhive.herokuapp.com/api/json/v1/mo-register")
        networklayer!.registration(paramsForTokenRetrieval: loginData) { (data, error) in
            if error == nil {
                print(data)
            } else {
                print(error)
            }
        }
        /*
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
        }
        
        APESuperHUD.showOrUpdateHUD(icon: .email, message: "Creating Account", duration: 1000.0, particleEffectFileName: "FireFliesParticle", presentingView: self.view, completion: nil)
        
        let when = DispatchTime.now() + 10 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "home")
            UIApplication.shared.keyWindow?.rootViewController = vc
        }*/
    }
    
    @IBAction func uploadPhoto(_ sender: UIButton) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
}
