//
//  PermissionsVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 2/10/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

class PermissionsVC: UIViewController {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnEnableLocation: UIButton!
    @IBOutlet var btnEnableNotification: UIButton!
    @IBOutlet var btnContinue: UIButton!
    @IBOutlet var lblDescription: UILabel!

    let notificationCenter = NotificationCenter.default
    let locationManager = LocationManagerModule.shared
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
        locationManager.getLocationAccess { (access) in
            self.updateLocationButton(access: access)
        }

        notificationManager.getNotificationAccess { (access) in
            self.updateNotificationButton(access: access)
        }
    }

    @IBAction func enableLocation(_ sender: UIButton) {
        locationManager.checkLocationPermissions { (error) in
            if let error = error {
                self.showErrorAlert(error)
            } else {
                self.locationManager.requestLocation()
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
                FIRAuthentication.shared.sessionCheck()
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
        locationManager.getUserLocation { (location) in
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

    func showErrorAlert(_ error: DadHiveError) {
        SVProgressHUD.showError(withStatus: error.rawValue)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }
}
