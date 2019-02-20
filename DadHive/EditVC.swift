//
//  EditVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/31/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditVC: UIViewController {

    @IBOutlet var lblTitle: TitleLabel!
    @IBOutlet var txtField: UITextView!
    @IBOutlet var btnSave: UIButton!
    var datePicker: UIDatePicker!
    var maxDistancePicker: UIPickerView!

    var userInfo: Info?
    var currentUser = CurrentUser.shared
    let locationManager = LocationManagerModule.shared
    let notificationCenter = NotificationCenter.default

    var ageRange = [AgeRange]()
    var type = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        btnSave.applyCornerRadius()
        btnSave.addGradientLayer(using: kAppCGColors)
        lblTitle.text = userInfo?.title ?? ""

        if let type = userInfo?.type, type == "dob" {
            showDatePicker()
        }

        if let type = userInfo?.type, type == "kidsAges" {
            showAgeRangePicker()
            DispatchQueue.global(qos: .background).async {
                FIRFirestoreDB.shared.retrieve(from: kAgeRange) { (success, documents, error) in
                    if let err = error {
                        print("Was unable to get ageRanges")
                    } else {
                        if let docs = documents, docs.count > 0 {
                            for doc in docs {
                                if let range = AgeRange(JSON: doc.data()) {
                                    self.ageRange.append(range)
                                    let sortedArray = self.ageRange.sorted { $0.min! < $1.min! }
                                    self.ageRange = sortedArray
                                }
                            }
                        }
                    }
                }
            }

        }

        if let type = userInfo?.type, type == "location" {
            self.btnSave.setText("Update Location")
            self.btnSave.addTarget(self, action: #selector(EditVC.updateLocation), for: .touchUpInside)
        } else {
            self.btnSave.setText("Update \(userInfo?.title ?? "")")
            self.btnSave.addTarget(self, action: #selector(EditVC.updateProfile), for: .touchUpInside)
        }

        notificationCenter.addObserver(self,
                                       selector: #selector(UserProfileVC.saveLocation(_:)),
                                       name: Notification.Name(rawValue: kSaveLocationObservationKey),
                                       object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self, name: Notification.Name(rawValue: kSaveLocationObservationKey), object: nil)
    }

    @objc
    func updateLocation() {
        showHUD()
        locationManager.checkLocationPermissions { (error) in
            if let error = error {
                self.showErrorAlert(error)
            } else {
                self.locationManager.requestLocation()
                print("Check location permissions finished")
            }
        }
    }

    @objc
    func updateProfile() {
        showHUD()
        if let userInfo = self.userInfo, txtField.text != "" {
            if let type = userInfo.type, type == "name" {
                self.currentUser.user?.change(name: txtField.text)
            } else {
                self.currentUser.user?.setInformation(atKey: userInfo.type ?? "", withValue: txtField.text)
            }
            userInfo.info = txtField.text
            CurrentUser.shared.refreshCurrentUser {
                self.hideHUD()
                self.popViewController()
            }
        }
    }

    @objc
    func saveLocation(_ notification: Notification) {
        LocationManagerModule.shared.getUserLocation {
            (location) in
            self.hideHUD()
            if let _ = location {
                CurrentUser.shared.refreshCurrentUser {
                    self.popViewController()
                }
            } else {
                self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
            }
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

    @objc func ageRangePickerViewDone() {
        let row = maxDistancePicker.selectedRow(inComponent: 0)
        txtField.resignFirstResponder()
        txtField.text = "\(ageRange[row].getAgeRange ?? "")"
    }

    @objc func ageRangePickerViewCancel() {
        txtField.resignFirstResponder()
        viewWillAppear(true)
    }

    @objc
    func pickerViewDone() {
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        txtField.text = formatter.string(from: datePicker.date)
        //dismiss date picker dialog
        self.view.endEditing(true)
    }

    @objc
    func pickerViewCancel() {
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }

    func showErrorAlert(_ error: DadHiveError) {
        SVProgressHUD.showError(withStatus: error.rawValue)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }

    func showHUD() {
        SVProgressHUD.show()
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.setBackgroundColor(AppColors.darkGreen)
        SVProgressHUD.setForegroundColor(UIColor.white)
    }

    func hideHUD() {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}

extension EditVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageRange.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(ageRange[row].getAgeRange ?? "")"
    }
}
