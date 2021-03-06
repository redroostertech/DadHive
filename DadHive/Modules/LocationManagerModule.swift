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
    private var locationManager: CLLocationManager?
    private var geoCoder = CLGeocoder()
    private var userLocationData: [String: Any]?
    var accessGranted = false

    private var userLocation: CLLocation? {
        didSet {
            guard let userLocation = self.userLocation else { return }
            print("Location longitude and latitude was retrieved.")
            if self.userLocationData == nil {
                self.userLocationData = [String: Any]()
            }
            self.userLocationData!["addressLat"] = userLocation.coordinate.latitude
            self.userLocationData!["addressLong"] = userLocation.coordinate.longitude
        }
    }

    private var userLocationDescription: [String: String]? {
        didSet {
            guard let userLocationDescription = self.userLocationDescription else { return }
            print("Location was reverse geocoded.")
            if self.userLocationData == nil {
                self.userLocationData = [String: Any]()
            }
            self.userLocationData!["addressCity"] = userLocationDescription["city"]
            self.userLocationData!["addressState"] = userLocationDescription["state"]
            self.userLocationData!["addressCountry"] = userLocationDescription["country"]
        }
    }

    private override init() {
        super.init()
        print(" \(kAppName) | LocationManagerModule Handler Initialized")
        createInstance()
    }

    func createInstance() {
        if locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
        getLocationAccess { (access) in
            if (access) {
                self.requestLocation()
            }
        }
    }

    func checkLocationPermissions(_ completion: @escaping(DadHiveError?)->Void) {
        locationManager?.requestWhenInUseAuthorization()
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

    private func getAccess (_ completion: ((Bool) -> Void)? = nil) {
        if CLLocationManager.authorizationStatus() == .denied {
            completion?(false)
        } else {
            completion?(CLLocationManager.locationServicesEnabled())
        }
    }

    func requestLocation(){
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager?.startUpdatingLocation()
        } else {
            self.showErrorAlert(DadHiveError.locationAccessDisabled)
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
        self.locationManager?.stopUpdatingLocation()
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
                    self.userLocationDescription!["city"] = place.locality ?? ""
                    self.userLocationDescription!["state"] = place.administrativeArea ?? ""
                    self.userLocationDescription!["country"] = place.country ?? ""
                    
                    if let data = self.userLocationData {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kSaveLocationObservationKey), object: nil, userInfo: ["access": false, "location": data])
                    }
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

//  MARK:- Observer method
extension LocationManagerModule {
    func getUserLocation(_ completion: @escaping(Location?)->Void) {
        if let data = self.userLocationData, let location = Location(JSON: data) {
            CurrentUser.shared.user?.setLocation(location, { (error) in
                if let err = error {
                    print(err.localizedDescription)
                    completion(nil)
                } else {
                    completion(location)
                }
            })
        } else {
            completion(nil)
        }
    }

    func getLocation(_ completion: @escaping(Location?)->Void) {
        if let data = self.userLocationData, let location = Location(JSON: data) {
            completion(location)
        } else {
            completion(nil)
        }
    }
}
