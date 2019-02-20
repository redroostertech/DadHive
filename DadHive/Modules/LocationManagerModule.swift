//
//  LocationManagerModule.swift
//  DadHive
//
//  Created by Michael Westbrooks on 2/8/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import CoreLocation
import SVProgressHUD

class LocationManagerModule: NSObject {
    static let shared = LocationManagerModule()
    private var locationManager: CLLocationManager!
    private var geoCoder = CLGeocoder()
    private var userLocationData: [String: Any]?
    var accessGranted = false

    private var userLocation: CLLocation? {
        didSet {
            guard let userLocation = self.userLocation else { return }
            if self.userLocationData == nil {
                self.userLocationData = [String: Any]()
            }
            //  self.userLocationData!["dateString"] = Date().toString(.timeDate)
            self.userLocationData!["addressLat"] = userLocation.coordinate.latitude
            self.userLocationData!["addressLong"] = userLocation.coordinate.longitude
        }
    }

    private var userLocationDescription: [String: String]? {
        didSet {
            guard let userLocationDescription = self.userLocationDescription else { return }
            if self.userLocationData == nil {
                self.userLocationData = [String: Any]()
            }
            self.userLocationData!["addressCity"] = userLocationDescription["city"]
            self.userLocationData!["addressState"] = userLocationDescription["state"]
            self.userLocationData!["addressCountry"] = userLocationDescription["country"]
        }
    }

    private override init() {
        locationManager = CLLocationManager()
    }

    func checkLocationPermissions(_ completion: @escaping(DadHiveError?)->Void) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        getAccess { (access) in
            if access == false {
                completion(DadHiveError.locationAccessDisabled)
            } else {
                completion(nil)
            }
        }
    }

    func getLocationAccess (_ completion: ((Bool) -> Void)? = nil) {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
            completion?(false)
        } else {
            completion?(CLLocationManager.locationServicesEnabled())
        }
    }

    func getAccess (_ completion: ((Bool) -> Void)? = nil) {
        if CLLocationManager.authorizationStatus() == .denied {
            completion?(false)
        } else {
            completion?(CLLocationManager.locationServicesEnabled())
        }
    }

    func requestLocation(){
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        } else {
            self.showErrorAlert(DadHiveError.locationAccessDisabled)
        }
    }

    func getUserLocation(_ completion: @escaping(Location?)->Void) {
        if let data = self.userLocationData, let location = Location(JSON: data) {
            CurrentUser.shared.user?.setLocation(location, { (error) in
                if let error = error {
                    completion(nil)
                } else {
                    completion(location)
                }
            })
        } else {
            completion(nil)
        }
    }
}

extension LocationManagerModule: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
         NotificationCenter.default.post(name: Notification.Name(rawValue: kLocationAccessCheckObservationKey), object: nil, userInfo: ["access": false])
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kLocationAccessCheckObservationKey), object: nil, userInfo: ["access": CLLocationManager.locationServicesEnabled()])
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {
            return
        }
        if self.userLocation == nil {
            self.userLocation = CLLocation()
        }
        self.userLocation! = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        manager.stopUpdatingLocation()
        reverseGeocode(usingLocation: userLocation!)
    }

    func reverseGeocode(usingLocation location: CLLocation) {
        self.geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let _ = error {
                print("Error reverse geocoding location")
            } else {
                if let place = placemarks?.first {
                    if self.userLocationDescription == nil {
                        self.userLocationDescription = [String: String]()
                    }
                    self.userLocationDescription!["city"] = place.subLocality ?? ""
                    self.userLocationDescription!["state"] = place.administrativeArea ?? ""
                    self.userLocationDescription!["country"] = place.country ?? ""
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kSaveLocationObservationKey), object: nil, userInfo: ["access": false])
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension LocationManagerModule {
    func showErrorAlert(_ error: DadHiveError) {
        SVProgressHUD.showError(withStatus: error.rawValue)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }
}
