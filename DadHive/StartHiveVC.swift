import UIKit
import CoreLocation
import MapKit
import DateTimePicker
import RRoostSDK

class StartHiveVC: UIViewController {
    
    @IBOutlet private weak var introLabel: UILabel!
    @IBOutlet private weak var locationSearchTextField: UITextField!
    @IBOutlet private weak var timeSelectorButton: UIButton!
    @IBOutlet private weak var startHiveButton: UIButton!
    @IBOutlet private weak var timeLabel: UILabel!
    
    let locationManager = LocationManager()
    var dateTimePicker: DateTimePicker?
    var selectedTime: String?
    var selectedLocation: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentuser = CurrentUser.shared.user, let name = currentuser.name?.fullName {
            self.introLabel.text = introLabel.text! + ", \(name)"
        }
        locationSearchTextField.addLeftPadding(withWidth: 10.0)
        locationSearchTextField.placeHolderColor = UIColor.black
        locationSearchTextField.delegate = self
        
        setupDateTimePicker()
        
        locationManager.delegate = self
        locationManager.checkPermissions()
    }
    
    private func setupDateTimePicker() {
        let min = Date()
        let max = Calendar.current.date(byAdding: .day, value: 1, to: min)
        dateTimePicker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        if let datetimepicker = dateTimePicker {
            datetimepicker.delegate = self
            datetimepicker.is12HourFormat = true
            datetimepicker.highlightColor = .black
        }
    }

    @IBAction func timeSelectorAction(_ sender: UIButton) {
        dateTimePicker?.show()
    }
    
    @IBAction func startHiveAction(_ sender: UIButton) {
        
    }
}

extension StartHiveVC: DateTimePickerDelegate {
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
        selectedTime = didSelectDate.toString()
        timeLabel.text = " \(didSelectDate.toString(.new)) on \(didSelectDate.toString(.normal))"
    }
}

// MARK: - UITextField delegate
extension StartHiveVC: LocationSearchDelegate {
    func selectLocation(_ searchVC: LocationSearchVC, selectedLocation location: (MKMapItem, MKPlacemark)) {
        var locationText = ""
        if let name = location.1.name {
            locationText += "\(name) "
        }
        if let addressDictionary = location.1.addressDictionary {
            if let addressLines = addressDictionary["FormattedAddressLines"] as? NSArray {
                locationText += addressLines.componentsJoined(by: ", ") as! String
            }
//            if let city = addressDictionary["City"] {
//                locationText += "\(city), "
//            }
//            if let state = addressDictionary["State"] {
//                locationText += "\(state) "
//            }
//            if let zip = addressDictionary["Zip"] {
//                locationText += "\(zip) "
//            }
        }
        
        locationSearchTextField.text = "\(locationText)"
    }
}

// MARK: - UITextField delegate
extension StartHiveVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == locationSearchTextField {
            if locationManager.isAuthorizationGranted {
                let destinationVC = LocationSearchVC(nibName: "LocationSearchVC", bundle: nil)
                destinationVC.locSearchDelegate = self
                self.present(destinationVC, animated: true, completion: nil)
            } else {
                self.showAlertErrorIfNeeded(error: Errors.LocationAccessDisabled)
            }
        }
        return true
    }
}

// MARK: - LocationManagerDelegate
extension StartHiveVC: LocationManagerDelegate {
    func didRetrieveStatus(_ manager: LocationManager, authorizationStatus: Bool) {
        print("Authorization Status: \(authorizationStatus)")
        manager.start()
    }
    
    func willRetrieveLocation(_ manager: LocationManager, location: LocationObject, center: LocationCenter, data: Any?) {
        if let _data = data as? [String: Any], let location = Location(JSON: _data) {
            CurrentUser.shared.user?.setLocation(location, { (error) in
                if let err = error {
                    print(err.localizedDescription)
                }
            })
        }
    }
    
    func willShowError(_ manager: LocationManager, error: Error) {
        self.showAlertErrorIfNeeded(error: error)
    }
}
