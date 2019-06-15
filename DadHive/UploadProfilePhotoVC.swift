import UIKit
import Firebase

private var imagePicker: UIImagePickerController?

class UploadProfilePhotoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet private weak var imgMain: UIImageView!
    @IBOutlet private weak var btnContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgMain.applyCornerRadius()
        imgMain.makeAspectFill()

        btnContinue.isHidden = true
        
        imagePicker = UIImagePickerController()
        if let imagepicker = imagePicker {
            imagepicker.delegate = self
            imagepicker.allowsEditing = false
            imagepicker.sourceType = .photoLibrary
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                imagepicker.mediaTypes = mediaTypes
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        guard let imagepicker = imagePicker else { return }
        present(imagepicker, animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let userId = CurrentUser.shared.user?.uid else {
            FIRAuthentication.signout()
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
                                    CurrentUser.shared.updateProfile(withData: [
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
}
