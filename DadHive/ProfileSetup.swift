//
//  FinishProfileVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/26/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class ProfileSetupFlowManager {
    static let shared = ProfileSetupFlowManager()
    private var userProfile: [String: Any]!
    private init() {
        userProfile = [String: Any]()
    }
    func addData(usingKey key: String, andValue value: String) {
        userProfile[key] = value
    }
    func addData(usingKey key: String, andValue value: Int) {
        userProfile[key] = value
    }
    func addData(usingKey key: String, andValue value: Bool) {
        userProfile[key] = value
    }
    func addData(usingKey key: String, andValue value: Double) {
        userProfile[key] = value
    }
    func addData(usingKey key: String, andValue value: [String: Any]) {
        userProfile[key] = value
    }
    func addData(usingKey key: String, andValue value: [[String: Any]]) {
        userProfile[key] = value
    }
    func viewData() {
        print(userProfile)
    }
}

public class FinishProfileStep1VC: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var txtUniversity: UITextField!
    @IBOutlet var txtProfession: UITextField!
    @IBOutlet var btnUploadProfile: UIButton!
    @IBOutlet var txtvwBio: UITextView!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var txtAge: UITextField!

    var imagePicker: UIImagePickerController?

    override public func viewDidLoad() {
        super.viewDidLoad()
        txtvwBio.delegate = self
        txtUniversity.addLeftPadding(withWidth: 10.0)
        txtProfession.addLeftPadding(withWidth: 10.0)
        txtAge.addLeftPadding(withWidth: 10.0)
        btnUploadProfile.applyCornerRadius(0.10)
        btnNext.applyCornerRadius()
        btnNext.addGradientLayer(using: kAppCGColors)

        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = false
        imagePicker?.sourceType = .photoLibrary
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            imagePicker?.mediaTypes = mediaTypes
        }
    }

    @IBAction func uploadImage(_ sender: UIButton) {
        guard let imagePicker = imagePicker else { return }
        present(imagePicker,
                animated: true,
                completion: nil)
    }

    @IBAction func next(_ sender: UIButton) {
        if txtUniversity.text != "", txtProfession.text != "", txtAge.text != "", txtvwBio.text != "" {
            let userInformation: [[String: Any]] = [
                [
                    "type" : "university",
                    "info" : txtUniversity.text ?? ""
                ],[
                    "type" : "profession",
                    "info" : txtProfession.text ?? ""
                ],[
                    "type" : "age",
                    "info" : txtAge.text ?? ""
                ]
            ]
            let userDetails: [[String: Any]] = [
                [
                    "type" : "aboutMe",
                    "info" : txtvwBio.text
                ]
            ]
            ProfileSetupFlowManager.shared.addData(usingKey: "userInformation", andValue: userInformation)
            ProfileSetupFlowManager.shared.addData(usingKey: "userDetails", andValue: userDetails)

            self.pushToView(withID: "FinishProfileStep2VC")
        }
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.lowercased() == "start typing." {
            textView.text = ""
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            btnUploadProfile.setTitle("",
                                      for: .normal)
            btnUploadProfile.setBackgroundImage(selectedImage,
                                                for: .normal)
            btnUploadProfile.contentMode = .scaleAspectFill
        }
        dismiss(animated:true, completion: nil)
    }

    private func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true,
                completion: nil)
    }
}

public class FinishProfileStep2VC: UIViewController, UITextViewDelegate {

    @IBOutlet var txtBoyCount: UITextField!
    @IBOutlet var txtGirlCount: UITextField!
    @IBOutlet var txtvwKidDescription: UITextView!
    @IBOutlet var txtvwFreeTime: UITextView!
    @IBOutlet var btnNext: UIButton!

    override public func viewDidLoad() {
        super.viewDidLoad()
        txtvwKidDescription.delegate = self
        txtvwFreeTime.delegate = self
        txtBoyCount.addLeftPadding(withWidth: 10.0)
        txtGirlCount.addLeftPadding(withWidth: 10.0)
        btnNext.applyCornerRadius()
        btnNext.addGradientLayer(using: kAppCGColors)
        ProfileSetupFlowManager.shared.viewData()
    }

    @IBAction func next(_ sender: UIButton) {
        let kidsInformation: [[String: Any]] = [
            [
                "type" : "boysCount",
                "info" : Int(txtBoyCount.text ?? "0")
            ],[
                "type" : "girlsCount",
                "info" : Int(txtBoyCount.text ?? "0")
            ],[
                "type" : "kidsDescription",
                "info" : txtvwKidDescription.text
            ],[
                "type" : "spendFreeTime",
                "info" : txtvwFreeTime.text
            ]
        ]
        ProfileSetupFlowManager.shared.addData(usingKey: "kidsInformation", andValue: kidsInformation)

        self.pushToView(withID: "FinishProfileStep3VC")
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.lowercased() == "start typing." {
            textView.text = ""
        }
    }
}

public class FinishProfileStep3VC: UIViewController {
    @IBOutlet var btnDistance: UIButton!
    @IBOutlet var btnAgeRange: UIButton!
    @IBOutlet var txtLocationPreferenceOne: UITextField!
    @IBOutlet var txtLocationPreferenceTwo: UITextField!
    @IBOutlet var btnDone: UIButton!

    var distanceSelection: Double = 0.0
    var minAge: Double = 0.0
    var maxAge: Double = 0.0

    override public func viewDidLoad() {
        super.viewDidLoad()
        txtLocationPreferenceOne.addLeftPadding(withWidth: 10.0)
        txtLocationPreferenceTwo.addLeftPadding(withWidth: 10.0)
        btnDone.applyCornerRadius()
        btnDone.addGradientLayer(using: kAppCGColors)
    }

    @IBAction func done(_ sender: UIButton) {
        let userPreferences: [[String: Any]] = [
            [
                "type" : "distance",
                "info" : distanceSelection
            ],[
                "type" : "minAge",
                "info" : minAge
            ],[
                "type" : "maxAge",
                "info" : maxAge
            ]
        ]
        ProfileSetupFlowManager.shared.addData(usingKey: "userPreferences", andValue: userPreferences)
        self.navigateToView(withID: "CustomTabBar")
    }
}
