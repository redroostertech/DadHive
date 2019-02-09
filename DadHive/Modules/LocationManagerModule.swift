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
    private var locationManager = CLLocationManager()
    private var geoCoder = CLGeocoder()
    private var userLocationData: [String: Any]?
    var accessGranted: Bool!

    private var userLocation: CLLocation? {
        didSet {
            guard let userLocation = self.userLocation else { return }
            if self.userLocationData == nil {
                self.userLocationData = [String: Any]()
            }
            self.userLocationData!["dateString"] = Date().toString(.timeDate)
            self.userLocationData!["latitude"] = userLocation.coordinate.latitude
            self.userLocationData!["longitude"] = userLocation.coordinate.longitude
        }
    }

    private var userLocationDescription: [String: String]? {
        didSet {
            guard let userLocationDescription = self.userLocationDescription else { return }
            if self.userLocationData == nil {
                self.userLocationData = [String: Any]()
            }
            self.userLocationData!["city"] = userLocationDescription["city"]
            self.userLocationData!["state"] = userLocationDescription["state"]
            self.userLocationData!["country"] = userLocationDescription["country"]
        }
    }

    override init() {
        super.init()
        checkLocationPermissions { (access) in
            self.locationManager.startMonitoringVisits()
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = 35
            self.accessGranted = access
        }
    }

    func requestLocation() {
        if (self.accessGranted) {
            self.locationManager.requestLocation()
        } else {
            self.showErrorAlert(DadHiveError.locationAccessDisabled)
        }
    }

    func checkLocationPermissions(_ completion: @escaping (Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorized: completion(true)
        case .denied: completion(false)
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
            completion(true)
        default: completion(false)
        }
    }

    func getUserLocation(_ completion: @escaping(Location?)->Void) {
        if let data = self.userLocationData, let location = Location(JSON: data) {
            completion(location)
        } else {
            completion(nil)
        }
    }
}

extension LocationManagerModule: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locationManager.startMonitoringVisits()
        }
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // create CLLocation from the coordinates of CLVisit
        let location = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        reverseGeocode(usingLocation: location)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            return
        }
        let location = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        reverseGeocode(usingLocation: location)
    }

    func reverseGeocode(usingLocation location: CLLocation) {
        self.userLocation = location
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
                }
            }
        }
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
