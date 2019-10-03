import UIKit
import SVProgressHUD
import RRoostSDK

private let notificationCenter = NotificationCenter.default
private let notificationManager = NotificationsManagerModule.shared
private let locationManager = LocationManager()

class PermissionsVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var lblTitle: UILabel!
    @IBOutlet private var btnEnableLocation: UIButton!
    @IBOutlet private var btnEnableNotification: UIButton!
    @IBOutlet private var btnContinue: UIButton!
    @IBOutlet private var lblDescription: UILabel!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLocationButton(access: locationManager.isAuthorizationGranted)
        notificationManager.getNotificationAccess { (access) in
             self.updateNotificationButton(access: access)
        }
    }

    // MARK: - Public member functions
    
    private func updateLocationButton(access: Bool) {
        DispatchQueue.main.async {
            self.btnEnableLocation.setText((access == true) ? kLocationEnabled : kLocationDisabled)
            self.btnEnableLocation.setTextColor((access == true) ? kEnabledTextColor : kDisabledTextColor)
        }
    }
    
    private func updateNotificationButton(access: Bool) {
        DispatchQueue.main.async {
            self.btnEnableNotification.setText(access ? kNotificationEnabled : kNotificationDisabled)
            self.btnEnableNotification.setTextColor(access ? kEnabledTextColor : kDisabledTextColor)
        }
        CurrentUser.shared.user?.setNotificationToggle(access)
    }
    
    // MARK: - IBActions
    @IBAction func enableLocation(_ sender: UIButton) {
        locationManager.checkPermissions()
    }

    @IBAction func enableNotification(_ sender: UIButton) {
        notificationManager.checkNotificationPermissions { access in
              self.updateNotificationButton(access: access)
              CurrentUser.shared.user?.setNotificationToggle(access)
              if let _ = DefaultsManager().retrieveIntDefault(forKey: kNotificationsAccessCheck), access == false {
                DefaultsManager().setDefault(withData: 0, forKey: kNotificationsAccessCheck)
              } else {
                DefaultsManager().setDefault(withData: 1, forKey: kNotificationsAccessCheck)
              }
        }
    }

    @IBAction func `continue`(_ sender: UIButton) {
        CurrentUser.shared.user?.setInitialState(true, {
            (error) in
            if error == nil {
                FIRAuthentication.checkSession()
            }
        })
    }
}

// MARK: - LocationManagerDelegate
extension PermissionsVC: LocationManagerDelegate {
    func didRetrieveStatus(_ manager: LocationManager, authorizationStatus: Bool) {
        self.updateLocationButton(access: authorizationStatus)
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
