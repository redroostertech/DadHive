//
//  PreferencesVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK

class TitleLabel: UILabel {
    override func awakeFromNib() {
        self.font = UIFont(name: kFontMenu, size: kFontSizeCaption)
        self.makeMultipleLines()
    }
}

class ValueLabel: UILabel {
    override func awakeFromNib() {
        self.font = UIFont(name: kFontButton, size: kFontSizeButton)
        self.makeMultipleLines()
    }
}

class PreferencesVC: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var lblAgeRange: TitleLabel!
    @IBOutlet weak var lblAgeRangeValue: ValueLabel!
    @IBOutlet weak var lblMaximumDistance: TitleLabel!
    @IBOutlet weak var lblMaximumDistanceValue: ValueLabel!
    @IBOutlet weak var sliderMaximumDistanceValue: UISlider!
    @IBOutlet weak var lblPreferredMeetingLocations: TitleLabel!
    @IBOutlet weak var lblMeetingLocationOne: ValueLabel!
    @IBOutlet weak var lblMeetingLocationTwo: ValueLabel!
    var textField: UITextField!
    var maxDistancePicker: UIPickerView!

    var maxDistanceInterval: Double = 0
    var userInfo: Info?
    var pickerType = 0
    var distance = [10.0, 25.0, 50.0, 75.0, 100.0]
    var ageRange = [AgeRange]()

    override func viewDidLoad() {
        super.viewDidLoad()
      DispatchQueue.main.async {
        self.navigationController?.navigationBar.tintColor = .white
      }
        DispatchQueue.global(qos: .background).async {
            FIRFirestoreDB.shared.retrieve(from: kMaxDistance) { (success, documents, error) in
                if let err = error {
                    print("Was unable to get maxDistance")
                } else {
                    if let docs = documents, docs.count > 0, let maxDistance = MaxDistance(JSON: docs[0].data()) {
                        self.sliderMaximumDistanceValue.minimumValue = Float(maxDistance.getMin)
                        self.sliderMaximumDistanceValue.maximumValue = Float(maxDistance.getMax)
                        self.maxDistanceInterval = maxDistance.getInterval
                        self.sliderMaximumDistanceValue.value = Float(CurrentUser.shared.user?.settings?.maxDistance ?? 0)
                    }
                }
            }
        }

        DispatchQueue.global(qos: .background).async {
            FIRFirestoreDB.shared.retrieve(from: kAgeRange) { (success, documents, error) in
                if let err = error {
                    print("Was unable to get ageRanges")
                } else {
                    if let docs = documents, docs.count > 0 {
                        for doc in docs {
                            if let range = AgeRange(JSON: doc.data()) {
                                self.ageRange.append(range)
                                let sortedArray = self.ageRange.sorted { $0.min ?? 0 < $1.min ?? 0 }
                                self.ageRange = sortedArray
                            }
                        }
                    }
                }
            }
        }

        hideNavigationBarHairline()
      self.navigationController?.navigationBar.tintColor = .darkText

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
        toolBar.tintColor = .darkText
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
        setupUI()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentUser.shared.user?.preferenceSection?.count ?? 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
        if segue.identifier == "goToEdit" {
            let destination = segue.destination as! EditVC
            destination.userInfo = userInfo
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            pickerType = 0
            maxDistancePicker.reloadAllComponents()
            textField.becomeFirstResponder()
        }
//        } else {
//            userInfo = userDetailsSectionOne[indexPath.row]
//            performSegue(withIdentifier: "goToEdit", sender: self)
//        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageRange.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(ageRange[row].getAgeRange ?? "")"
    }

    @objc func pickerViewDone() {
        let row = maxDistancePicker.selectedRow(inComponent: 0)
        CurrentUser.shared.user?.setAgeRange(ageRange[row])
        textField.resignFirstResponder()
        lblAgeRangeValue.text = "\(ageRange[row].getAgeRange ?? "")"
    }

    @objc func pickerViewCancel() {
        textField.resignFirstResponder()
        viewWillAppear(true)
    }

    @IBAction func maximumDistanceSlider(_ sender: UISlider) {
        let roundedValue = round(sender.value / Float(maxDistanceInterval)) * Float(maxDistanceInterval)
        sender.value = roundedValue
        self.lblMaximumDistanceValue.text = "\(Int(roundedValue))"
        CurrentUser.shared.user?.setMaximumDistance(Double(roundedValue))
    }

}

extension PreferencesVC {
    func setupUI() {
        lblAgeRangeValue.text = String(describing: CurrentUser.shared.user?.settings?.ageRange?.getAgeRange ?? "No Response")
        lblMaximumDistanceValue.text = String(describing: Int(CurrentUser.shared.user?.settings?.maxDistance ?? 0))
    }
}
