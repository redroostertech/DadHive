import UIKit
import SVProgressHUD
import RRoostSDK

enum EditVCPickerViewTypesString: String {
    case AgeRange = "AgeRange"
    case KidsCount = "kidCount"
}

class EditVC: UIViewController {

    @IBOutlet weak var lblTitle: TitleLabel!
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var btnSave: UIButton!
    var datePicker: UIDatePicker!
    var maxDistancePicker: UIPickerView!

    var userInfo: Info?
    var currentUser = CurrentUser.shared
    let notificationCenter = NotificationCenter.default

    var ageRange = [AgeRange]()
    var kidsCount = [1, 2, 3, 4, 5, 6, 7, 8]
    var selectedKidsCount = 0
    var type: EditVCPickerViewTypesString?
    
    let locationManager = LocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

      self.navigationController?.navigationBar.tintColor = .darkText
      
        lblTitle.text = "Edit \(userInfo?.title ?? "")"

        if let type = userInfo?.type, type == "dob" {
            showDatePicker()
        }

        if let type = userInfo?.type, type == "kidsAges" {
            self.type = EditVCPickerViewTypesString.AgeRange
            showAgeRangePicker()
            DispatchQueue.global(qos: .background).async {
                FIRFirestoreDB.shared.retrieve(from: kAgeRange) { (success, documents, error) in
                    if let _ = error {
                        print("Was unable to get ageRanges")
                    } else {
                        if let docs = documents, docs.count > 0 {
                            for doc in docs {
                                if let range = AgeRange(JSON: doc.data()) {
                                    self.ageRange.append(range)
                                }
                            }
                            let sortedArray = self.ageRange.sorted { $0.min ?? 0 < $1.min ?? 0}
                            self.ageRange = sortedArray
                        }
                    }
                }
            }
        }

        if let type = userInfo?.type, type == "kidsCount" {
            self.type = EditVCPickerViewTypesString.KidsCount
            showAgeRangePicker()
        }

        if let type = userInfo?.type, type == "location" {
            locationManager.delegate = self
            self.btnSave.setText("Update Location")
            self.btnSave.addTarget(self, action: #selector(EditVC.updateLocation), for: .touchUpInside)
        } else {
            self.btnSave.setText("Update \(userInfo?.title ?? "")")
            self.btnSave.addTarget(self, action: #selector(EditVC.updateProfile), for: .touchUpInside)
        }
    }
    
    @objc
    func updateProfile() {
        showHUD()
        if let userInfo = self.userInfo, txtField.text != "" {
            if let type = userInfo.type, type == "name" {
                self.currentUser.user?.change(name: txtField.text, {
                    (error) in
                    if let err = error {
                        print(err)
                        DispatchQueue.main.async {
                          self.showError("There was an error. Please try again.")
                          self.hideHUD()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.hideHUD()
                            self.popViewController()
                        }
                    }
                })
            }

            if let type = userInfo.type, type == "dob" {
              self.currentUser.user?.change(dob: txtField.text, {
                (error) in
                if let err = error {
                  print(err)
                  DispatchQueue.main.async {
                    self.showError("There was an error. Please try again.")
                    self.hideHUD()
                  }
                } else {
                  DispatchQueue.main.async {
                    self.hideHUD()
                    self.popViewController()
                  }
                }
              })
            }

            if let type = userInfo.type, type == "bio" {
              self.currentUser.user?.change(bio: txtField.text, {
                (error) in
                if let err = error {
                  print(err)
                  DispatchQueue.main.async {
                    self.showError("There was an error. Please try again.")
                    self.hideHUD()
                  }
                } else {
                  DispatchQueue.main.async {
                    self.hideHUD()
                    self.popViewController()
                  }
                }
              })
            }

            if let type = userInfo.type, type == "companyName" {
              self.currentUser.user?.change(companyName: txtField.text, {
                (error) in
                if let err = error {
                  print(err)
                  DispatchQueue.main.async {
                    self.showError("There was an error. Please try again.")
                    self.hideHUD()
                  }
                } else {
                  DispatchQueue.main.async {
                    self.hideHUD()
                    self.popViewController()
                  }
                }
              })
            }

            if let type = userInfo.type, type == "kidsCount" {
              self.currentUser.user?.change(type: type, value: selectedKidsCount, {
                (error) in
                if let err = error {
                  print(err)
                  DispatchQueue.main.async {
                    self.showError("There was an error. Please try again.")
                    self.hideHUD()
                  }
                } else {
                  DispatchQueue.main.async {
                    self.hideHUD()
                    self.popViewController()
                  }
                }
              })
            }

            if let type = userInfo.type {
              self.currentUser.user?.change(type: type, value: txtField.text, {
                (error) in
                if let err = error {
                  print(err)
                  DispatchQueue.main.async {
                    self.showError("There was an error. Please try again.")
                    self.hideHUD()
                  }
                } else {
                  DispatchQueue.main.async {
                    self.hideHUD()
                    self.popViewController()
                  }
                }
              })
            }

        } else {
            self.showError("Field cannot be empty.")
        }
    }

    func showDatePicker() {
        //Formate Date
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date

        //ToolBar
        let toolBar = UIToolbar();
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .lightGray
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditVC.pickerViewDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(EditVC.pickerViewCancel))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        // add toolbar to textField
        txtField.inputAccessoryView = toolBar
        // add datepicker to textField
        txtField.inputView = datePicker
    }

    func showAgeRangePicker() {
        maxDistancePicker = UIPickerView(frame: CGRect(x: 0, y: 200, width: self.view.bounds.width, height: 150))
        maxDistancePicker.delegate = self
        maxDistancePicker.dataSource = self
        maxDistancePicker.backgroundColor = .white
        maxDistancePicker.showsSelectionIndicator = true

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .lightGray
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditVC.ageRangePickerViewDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(EditVC.ageRangePickerViewCancel))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        txtField.inputView = maxDistancePicker
        txtField.inputAccessoryView = toolBar
    }

    func showKidCountPicker() {
        maxDistancePicker = UIPickerView(frame: CGRect(x: 0, y: 200, width: self.view.bounds.width, height: 150))
        maxDistancePicker.delegate = self
        maxDistancePicker.dataSource = self
        maxDistancePicker.backgroundColor = .white
        maxDistancePicker.showsSelectionIndicator = true

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .lightGray
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditVC.kidCountPickerViewDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(EditVC.kidCountPickerViewCancel))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        txtField.inputView = maxDistancePicker
        txtField.inputAccessoryView = toolBar
    }

    @objc
    func kidCountPickerViewDone() {
        let row = maxDistancePicker.selectedRow(inComponent: 0)
        txtField.resignFirstResponder()
        selectedKidsCount = kidsCount[row]
        txtField.text = "\(String(describing: kidsCount[row]) == "8" ? "7+": String(describing: kidsCount[row]))"
    }

    @objc
    func kidCountPickerViewCancel() {
        txtField.resignFirstResponder()
        viewWillAppear(true)
    }

    @objc
    func ageRangePickerViewDone() {
        let row = maxDistancePicker.selectedRow(inComponent: 0)
        txtField.resignFirstResponder()
        txtField.text = "\(ageRange[row].getAgeRange ?? "")"
    }

    @objc
    func ageRangePickerViewCancel() {
        txtField.resignFirstResponder()
        viewWillAppear(true)
    }

    @objc
    func pickerViewDone() {
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        txtField.text = formatter.string(from: datePicker.date)
        //dismiss date picker dialog
        self.view.endEditing(true)
    }

    @objc
    func pickerViewCancel() {
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }

}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension EditVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let type = self.type else { return 0 }
        switch type {
        case .AgeRange:
            return ageRange.count
        case .KidsCount:
            return 8
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let type = self.type else { return "" }
        switch type {
        case .AgeRange:
            return "\(ageRange[row].getAgeRange ?? "")"
        case .KidsCount:
            return "\(String(describing: kidsCount[row]) == "8" ? "7+": String(describing: kidsCount[row]))"
        }
    }
}

// MARK: - LocationManagerDelegate
extension EditVC: LocationManagerDelegate {
    
    @objc
    func updateLocation() {
        showHUD()
        locationManager.checkPermissions()
    }

    func didRetrieveStatus(_ manager: LocationManager, authorizationStatus: Bool) {
        manager.start()
    }
    
    func willRetrieveLocation(_ manager: LocationManager, location: LocationObject, center: LocationCenter, data: Any?) {
        if let _data = data as? [String: Any], let location = Location(JSON: _data) {
            CurrentUser.shared.user?.setLocation(location, { (error) in
                if let err = error {
                    print(err.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        self.hideHUD()
                        self.popViewController()
                    }
                }
            })
        }
    }
    
    func willShowError(_ manager: LocationManager, error: Error) {
        self.showAlertErrorIfNeeded(error: error)
    }
}
