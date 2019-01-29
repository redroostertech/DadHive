//
//  PreferencesVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class TitleLabel: UILabel {
    override func awakeFromNib() {
        self.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        self.makeMultipleLines()
    }
}

class ValueLabel: UILabel {
    override func awakeFromNib() {
        self.font = UIFont(name: kFontCaption, size: kFontSizeCaption)
        self.makeMultipleLines()
    }
}

class PreferencesVC: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet var lblAgeRange: TitleLabel!
    @IBOutlet var lblAgeRangeValue: ValueLabel!
    @IBOutlet var lblMaximumDistance: TitleLabel!
    @IBOutlet var lblMaximumDistanceValue: ValueLabel!
    @IBOutlet var lblPreferredMeetingLocations: TitleLabel!
    @IBOutlet var lblMeetingLocationOne: ValueLabel!
    @IBOutlet var lblMeetingLocationTwo: ValueLabel!

    var textField: UITextField!
    var userInfo: [String: Any]?
    var userDetailsSectionOne: [[String: Any]] = [
        [
            "type": "ageRange",
            "title": "Age Range",
            "info": ""
        ],[
            "type": "maxDistance",
            "title": "Maximum Distance",
            "info": ""
        ]
    ]
    var pickerType = 0
    var maxDistancePicker: UIPickerView!
    var distance = [10, 25, 50]
    var ageRange = [
        [
            "id": 0,
            "min": 1,
            "max": 2
        ],[
            "id": 1,
            "min": 2,
            "max": 4
        ],[
            "id": 2,
            "min": 4,
            "max": 7
        ],[
            "id": 3,
            "min": 7,
            "max": 10
        ],[
            "id": 4,
            "min": 10,
            "max": 13
        ],[
            "id": 5,
            "min": 13,
            "max": 20
        ],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        textField = UITextField(frame: CGRect.zero)
        view.addSubview(textField)

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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PreferencesVC.pickerViewDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(PreferencesVC.pickerViewCancel))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        textField.inputView = maxDistancePicker
        textField.inputAccessoryView = toolBar

    }

    override func viewWillAppear(_ animated: Bool) {
        print(CurrentUser.shared.user)
        setupUI()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetailsSectionOne.count
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
        if segue.identifier == "goToEdit" {
            let destination = segue.destination as! EditVC
            destination.userInfo = userInfo
            destination.type = 2
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            pickerType = 0
            maxDistancePicker.reloadAllComponents()
            textField.becomeFirstResponder()
        } else if indexPath.row == 1 {
            pickerType = 1
            maxDistancePicker.reloadAllComponents()
            textField.becomeFirstResponder()
        } else {
            userInfo = userDetailsSectionOne[indexPath.row]
            performSegue(withIdentifier: "goToEdit", sender: self)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerType == 0 {
            return ageRange.count
        } else {
            return distance.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerType == 0 {
            return "\(ageRange[row]["min"] ?? 0) to \(ageRange[row]["max"] ?? 0) years old"
        } else {
            return String(describing: distance[row])
        }
    }

    @objc func pickerViewDone() {
        let row = maxDistancePicker.selectedRow(inComponent: 0)
        if pickerType == 0 {
            CurrentUser.shared.user?.userSettings?.setAgeRange(ageRange[row])
        } else {
            CurrentUser.shared.user?.userSettings?.setMaximumDistance(distance[row])
        }
        textField.resignFirstResponder()
        viewWillAppear(true)
    }

    @objc func pickerViewCancel() {
        textField.resignFirstResponder()
        viewWillAppear(true)
    }

}

extension PreferencesVC {
    func setupUI() {
        lblAgeRangeValue.text = String(describing: CurrentUser.shared.user?.userSettings?.userAgeRangePreferences ?? "No Response")
        lblMaximumDistanceValue.text = String(describing: CurrentUser.shared.user?.userSettings?.userMaximumDistancePreferences ?? 0)
//        lblMeetingLocationOne.text = String(describing: CurrentUser.shared.user?.userMeetingLocationPreferences ?? "No Response")
//        lblMeetingLocationTwo.text = String(describing: CurrentUser.shared.user?.userMeetingLocationPreferences ?? "No Response")
    }
}
