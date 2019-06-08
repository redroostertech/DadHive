import UIKit
import Firebase

class MyProfileVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var btnProfileImages: [UIButton]!
    @IBOutlet weak var lblName: TitleLabel!
    @IBOutlet weak var lblNameValue: ValueLabel!
    @IBOutlet weak var lblAge: TitleLabel!
    @IBOutlet weak var lblAgeValue: ValueLabel!
    @IBOutlet weak var lblLocation: TitleLabel!
    @IBOutlet weak var lblLocationValue: ValueLabel!
    @IBOutlet weak var lblBioValue: ValueLabel!
    @IBOutlet weak var lblBio: TitleLabel!
    @IBOutlet weak var lblWork: TitleLabel!
    @IBOutlet weak var lblWorkValue: ValueLabel!
    @IBOutlet weak var lblJobTitle: TitleLabel!
    @IBOutlet weak var lblJobTitleValue: ValueLabel!
    @IBOutlet weak var lblSchool: TitleLabel!
    @IBOutlet weak var lblSchoolValue: ValueLabel!
    @IBOutlet weak var lblKidsNamesValue: ValueLabel!
    @IBOutlet weak var lblKidsNames: TitleLabel!
    @IBOutlet weak var lblKidsAges: TitleLabel!
    @IBOutlet weak var lblKidsAgesValue: ValueLabel!
    @IBOutlet weak var lblKidsBio: TitleLabel!
    @IBOutlet weak var lblKidsBioValue: ValueLabel!
    @IBOutlet weak var lblKidsCount: TitleLabel!
    @IBOutlet weak var lblKidsCountValue: ValueLabel!
    @IBOutlet weak var lblQuestionOne: TitleLabel!
    @IBOutlet weak var lblQuestionOneValue: ValueLabel!
    @IBOutlet weak var lblQuestionTwo: TitleLabel!
    @IBOutlet weak var lblQuestionTwoValue: ValueLabel!
    @IBOutlet weak var lblQuestionThree: TitleLabel!
    @IBOutlet weak var lblQuestionThreeValue: ValueLabel!

    var x = 0

    var userInfo: Info?
    var imagePicker: UIImagePickerController?
    var selectedBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationBarHairline()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension

        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = false
        imagePicker?.sourceType = .photoLibrary
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            imagePicker?.mediaTypes = mediaTypes
        }

        for button in btnProfileImages {
            button.tag = x
            button.contentMode = .scaleAspectFill
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(MyProfileVC.uploadPhoto(_:)), for: .touchUpInside)
            x += 1
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 7
        case 2: return 4
        case 3: return 0
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                userInfo = Info(JSON: ["title": "Name", "type": "name"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 1:
                userInfo = Info(JSON: ["title": "Age", "type": "dob"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 2:
                userInfo = Info(JSON: ["title": "Location", "type": "location"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 3:
                userInfo = Info(JSON: ["title": "About Me", "type": "bio"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 4:
                userInfo = Info(JSON: ["title": "Employer", "type": "companyName"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 5:
                userInfo = Info(JSON: ["title": "Job Title", "type": "jobTitle"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 6:
                userInfo = Info(JSON: ["title": "College/University", "type": "schoolName"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            default:
                return
            }
        case 2:
            switch indexPath.row {
            case 0:
                userInfo = Info(JSON: ["title": "Kid(s) Name(s)", "type": "kidsNames"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 1:
                userInfo = Info(JSON: ["title": "Kid(s) Age", "type": "kidsAges"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            case 2:
                userInfo = Info(JSON: ["title": "Describe your kids", "type": "kidsBio"])
                performSegue(withIdentifier: "goToEdit", sender: self)
            default:
                return
            }
        case 3:
            guard let data = CurrentUser.shared.user?.infoSectionThree else {
                return
            }
            userInfo = data[indexPath.row]
            performSegue(withIdentifier: "goToEdit", sender: self)
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
        if segue.identifier == "goToEdit" {
            let destination = segue.destination as! EditVC
            destination.userInfo = userInfo
        }
    }

    @objc func uploadPhoto(_ sender: UIButton) {
        print(sender.tag)
        guard let imagePicker = imagePicker else { return }
        if selectedBtn == nil {
            self.selectedBtn = UIButton()
        }
        selectedBtn = btnProfileImages[sender.tag]
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func deletePhoto(_ sender: UIButton) {
        guard let userId = CurrentUser.shared.user?.uid else {
            print("User ID not available")
            return
        }
        print(sender.tag)
        print("Deleting profile")
        if selectedBtn == nil {
            self.selectedBtn = UIButton()
        }
        let buttonTag = sender.tag + 1
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let replaceAction = UIAlertAction(title: "Replace Photo", style: .default) { (action) in
            self.uploadPhoto(sender)
        }
        let deleteAction = UIAlertAction(title: "Delete Photo", style: .default) { (action) in
            self.showHUD("")
            let storageRef = Storage.storage().reference().child("images/\(userId)/userProfilePicture_\(buttonTag)_url")
            storageRef.delete { error in
                if let error = error {
                    self.dismissHUD()
                } else {
                    CurrentUser.shared.updateProfileToNil(withData: [
                        "userProfilePicture_\(buttonTag)_url": nil
                        ], completion: { (erorr) in
                            self.dismissHUD()
                            if let err = error {
                                print("Current photo delete error: \(err.localizedDescription)")
                            } else {
                                print("Completed deleting image")
                                self.popViewController()
                            }
                    })

                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.reset(self.selectedBtn!)
            alert.dismissViewController()
        }
        alert.addAction(replaceAction)
        if sender.tag != 0 {
            alert.addAction(deleteAction)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let userId = CurrentUser.shared.user?.uid else {
            print("User ID not available")
            FIRAuthentication.signout()
            return
        }

        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let scaledImage = selectedImage.resize(withWidth: 300) else {
            self.showError("Image unavailable. Please try again.")
            return
        }
        
        guard let selectedBtn = self.selectedBtn else {
            self.showError("Image unavailable. Please try again.")
            return
        }
        
        let buttonTag = selectedBtn.tag + 1

        dismiss(animated:true, completion: {
            DispatchQueue.main.async {
                selectedBtn.removeImages()
                selectedBtn.imageView?.contentMode = .scaleAspectFill
                selectedBtn.imageView?.clipsToBounds = true
                selectedBtn.setImage(selectedImage, for: .normal)
            }
            let alert = UIAlertController(title: "Upload Photo", message: "You are about to upload a photo. Are you sure?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in

                let storageRef = Storage.storage().reference().child("images/\(userId)/userProfilePicture_\(buttonTag)_url")

                guard let uploadData = UIImageJPEGRepresentation(scaledImage, 1.0) else {
                    return
                }

                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let err = error {
                        print("PutData error : \(err.localizedDescription)")
                        self.showError("There was an uploading image. Please try again.")
                        self.reset(self.selectedBtn!)
                    } else {
                        storageRef.downloadURL(completion: { (url, error) in
                            if let err = error {
                                print("Download url error : \(err.localizedDescription)")
                                self.showError("There was an uploading image. Please try again.")
                                self.reset(self.selectedBtn!)
                            } else {
                                if let urlString = url?.absoluteString {
                                    CurrentUser.shared.updateProfile(withData: [
                                        "userProfilePicture_\(buttonTag)_url": urlString
                                        ], completion: { (erorr) in
                                            if let err = error {
                                                print("Current user upload error: \(err.localizedDescription)")
                                                self.showError("There was an uploading image. Please try again.")
                                                self.reset(self.selectedBtn!)
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
                self.reset(self.selectedBtn!)
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

    private func reset(_ btn: UIButton) {
        btn.removeImages()
        setImages()
    }

}

extension MyProfileVC {
    func setupUI() {
        DispatchQueue.main.async {
            self.lblNameValue.text = String(describing: CurrentUser.shared.user?.name?.fullName ?? "No Response")
            self.lblAgeValue.text = String(describing: CurrentUser.shared.user?.age ?? 0)
            self.lblLocationValue.text = String(describing: CurrentUser.shared.user?.settings?.location?.getString ?? "No Response")
            self.lblBioValue.text = String(describing: CurrentUser.shared.user?.bio ?? "No Response")
            self.lblWorkValue.text = String(describing: CurrentUser.shared.user?.companyName ?? "No Response")
            self.lblJobTitleValue.text = String(describing: CurrentUser.shared.user?.jobTitle ?? "No Response")
            self.lblSchoolValue.text = String(describing: CurrentUser.shared.user?.schoolName ?? "No Response")
            self.lblKidsNamesValue.text = String(describing: CurrentUser.shared.user?.kidsNames ?? "No Response")
            self.lblKidsAgesValue.text = String(describing: CurrentUser.shared.user?.kidsAges ?? "No Response")
            self.lblKidsCountValue.text = String(describing: CurrentUser.shared.user?.kidsCount ?? "No Response")
            self.lblKidsBioValue.text = String(describing: CurrentUser.shared.user?.kidsBio ?? "No Response")
            self.lblQuestionOne.text = String(describing: CurrentUser.shared.user?.questionOneTitle ?? "Select a question")
            self.lblQuestionOneValue.text = String(describing: CurrentUser.shared.user?.questionOneResponse ?? "No Response")
            self.lblQuestionTwo.text = String(describing: CurrentUser.shared.user?.questionTwoTitle ?? "Select a question")
            self.lblQuestionTwoValue.text = String(describing: CurrentUser.shared.user?.questionTwoResponse ?? "No Response")
            self.lblQuestionThree.text = String(describing: CurrentUser.shared.user?.questionThreeTitle ?? "Select a question")
            self.lblQuestionThreeValue.text = String(describing: CurrentUser.shared.user?.questionThreeResponse ?? "No Response")
            self.setImages()
        }
        tableView.reloadData()
    }

    func setImages() {
        if let mediaArray = CurrentUser.shared.user?.media {
            let mediaCount = mediaArray.count
            var i = 0
            while i < mediaCount {
                let btn = btnProfileImages[i]
                let media = mediaArray[i]
                btn.imageView?.contentMode = .scaleAspectFill
                btn.imageView?.clipsToBounds = true
                if media.url != nil {
                    btn.sd_setImage(with: media.url, for: .normal, completed: nil)
                    btn.removeTarget(self, action: #selector(MyProfileVC.uploadPhoto(_:)), for: .touchUpInside)
                    btn.addTarget(self, action: #selector(MyProfileVC.deletePhoto(_:)), for: .touchUpInside)
                } else {
                    btn.setImage(UIImage(named: "placeholder"), for: .normal)
                }
                i += 1
            }
        }
    }
}
