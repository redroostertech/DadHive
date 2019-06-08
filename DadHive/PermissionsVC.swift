import UIKit
import SVProgressHUD

class PermissionsVC: UIViewController {

    @IBOutlet private var lblTitle: UILabel!
    @IBOutlet private var btnEnableLocation: UIButton!
    @IBOutlet private var btnEnableNotification: UIButton!
    @IBOutlet private var btnContinue: UIButton!
    @IBOutlet private var lblDescription: UILabel!

    let notificationCenter = NotificationCenter.default
    let notificationManager = NotificationsManagerModule.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self,
                                       selector: #selector(PermissionsVC.observeLocationAccessCheck(_:)),
                                       name: Notification.Name(rawValue: kLocationAccessCheckObservationKey),
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(PermissionsVC.saveLocation(_:)),
                                       name: Notification.Name(rawValue: kSaveLocationObservationKey),
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(PermissionsVC.observeNotificationsAccessCheck(_:)),
                                       name: Notification.Name(rawValue: kNotificationAccessCheckObservationKey),
                                       object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        LocationManagerModule.shared.getLocationAccess { (access) in
            self.updateLocationButton(access: access)
        }

        notificationManager.getNotificationAccess { (access) in
            self.updateNotificationButton(access: access)
        }
    }

    @IBAction func enableLocation(_ sender: UIButton) {
        LocationManagerModule.shared.checkLocationPermissions { (error) in
            if let error = error {
                self.showErrorAlert(error)
            } else {
                LocationManagerModule.shared.requestLocation()
                print("Check location permissions finished")
            }
        }
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
                FIRAuthentication.checkIsSessionActive()
            }
        })
    }

    @objc
    func observeLocationAccessCheck(_ notification: Notification) {
        if let access = notification.userInfo?["access"] as? Bool {
            self.updateLocationButton(access: access)
        } else {
            self.updateLocationButton(access: false)
        }
    }

    @objc
    func saveLocation(_ notification: Notification) {
        LocationManagerModule.shared.getUserLocation { (location) in
           print("Location is \(location)")
        }
    }

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
}
