//
//  UploadProfilePhotoVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 3/19/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import Firebase
import APESuperHUD

class UploadProfilePhotoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var imgMain: UIImageView!
    @IBOutlet var btnContinue: UIButton!

    var imagePicker: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        imgMain.applyCornerRadius()
        imgMain.makeAspectFill()

        btnContinue.isHidden = true
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = false
        imagePicker?.sourceType = .photoLibrary
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            imagePicker?.mediaTypes = mediaTypes
        }
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        guard let imagePicker = imagePicker else { return }
        present(imagePicker, animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let userId = CurrentUser.shared.user?.uid else {
            print("User ID not available")
            FIRAuthentication.shared.signout()
            return
        }

        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.showError("Image unavailable. Please try again.")
            return
        }

        let buttonTag =  1

        dismiss(animated:true, completion: {
            DispatchQueue.main.async {
                self.imgMain.image = selectedImage
            }
            let alert = UIAlertController(title: "Upload Photo", message: "You are about to upload a photo. Are you sure?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in

                self.showHUD("Updating Profile")
                let storageRef = Storage.storage().reference().child("images/\(userId)/userProfilePicture_\(buttonTag)_url")

                guard let uploadData = UIImageJPEGRepresentation(selectedImage, 0.75) else {
                    self.dismissHUD()
                    return
                }

                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    self.btnContinue.isHidden = false
                    self.dismissHUD()
                    if let err = error {
                        print("PutData error : \(err.localizedDescription)")
                        self.showError("There was an uploading image. Please try again.")
                        self.reset()
                    } else {
                        storageRef.downloadURL(completion: { (url, error) in
                            if let err = error {
                                print("Download url error : \(err.localizedDescription)")
                                self.showError("There was an uploading image. Please try again.")
                                self.reset()
                            } else {
                                if let urlString = url?.absoluteString {
                                    CurrentUser.shared.updateUser(withData: [
                                        "userProfilePicture_\(buttonTag)_url": urlString
                                        ], completion: { (erorr) in
                                            if let err = error {
                                                print("Current user upload error: \(err.localizedDescription)")
                                                self.showError("There was an uploading image. Please try again.")
                                                self.reset()
                                            } else {
                                                print("Completed uploading image")
                                            }
                                    })
                                }
                            }
                        })
                    }
                })
                DispatchQueue.main.async {
                    alert.dismissViewController()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.reset()
                alert.dismissViewController()
            }
            alert.addAction(yesAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        })
    }

    private func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true,
                completion: nil)
    }

    private func reset() {
        self.imgMain.image = UIImage(named: "unknown")
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
        APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: 300.0), title: nil, message: text, completion: nil)
    }

    func dismissHUD() {
        APESuperHUD.dismissAll(animated: true)
    }

}
