import UIKit
import SVProgressHUD

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
        notificationCenter.addObserver(self,
                                       selector: #selector(PermissionsVC.observeNotificationsAccessCheck(_:)),
                                       name: Notification.Name(rawValue: kNotificationAccessCheckObservationKey),
                                       object: nil)
        locationManager.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLocationButton(access: locationManager.isAuthorizationGranted)

        notificationManager.getNotificationAccess { (access) in
            self.updateNotificationButton(access: access)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationCenter.removeObserver(self, name: Notification.Name(rawValue: kNotificationAccessCheckObservationKey), object: nil)
    }
    
    // MARK: - Public member functions
    @objc
    func observeNotificationsAccessCheck(_ notification: Notification) {
        if let access = notification.userInfo?["access"] as? Bool {
            self.updateNotificationButton(access: access)
        } else {
            self.updateNotificationButton(access: false)
        }
    }
    
    func updateLocationButton(access: Bool) {
        DispatchQueue.main.async {
            self.btnEnableLocation.setText((access == true) ? kLocationEnabled : kLocationDisabled)
            self.btnEnableLocation.setTextColor((access == true) ? kEnabledTextColor : kDisabledTextColor)
        }
    }
    
    func updateNotificationButton(access: Bool) {
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
        notificationManager.checkNotificationPermissions { (error) in
            if let error = error {
                self.showErrorAlert(error)
            } else {
                print("Check notifications permissions finished")
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
