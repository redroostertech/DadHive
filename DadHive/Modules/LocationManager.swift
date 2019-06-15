import Foundation
import CoreLocation
import SVProgressHUD

protocol LocationManagerDelegate {
    func didRetrieveStatus(_ manager: LocationManager, authorizationStatus: Bool)
    func willRetrieveLocation(_ manager: LocationManager, location: LocationObject, center: LocationCenter, data: Any?)
    func willShowError(_ manager: LocationManager, error: Error)
}

private var manager: CLLocationManager?
private var geoCoder: CLGeocoder?
private var isUpdatingUserLocation: Bool = false

public typealias LocationCenter = CLLocationCoordinate2D
public typealias LocationObject = CLLocation

class LocationManager: NSObject {
    var isAuthorizationGranted: Bool {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
            return false
        } else {
            return CLLocationManager.locationServicesEnabled()
        }
    }
    
    var delegate: LocationManagerDelegate?

    override init() {
        manager = CLLocationManager()
        geoCoder = CLGeocoder()
        super.init()
        print(" \(kAppName) | LocationManagerModule Handler Initialized")
        if let locationmanager = manager {
            locationmanager.delegate = self
            locationmanager.desiredAccuracy = kCLLocationAccuracyBest
            requestWhenInUserAuthorization()
        }
    }

    func checkPermissions() {
        if isAuthorizationGranted {
            delegate?.didRetrieveStatus(self, authorizationStatus: isAuthorizationGranted)
        } else {
            requestWhenInUserAuthorization()
        }
    }

    func requestLocation() {
        if let locationmanager = manager, isAuthorizationGranted {
            locationmanager.requestLocation()
        } else {
            self.delegate?.willShowError(self, error: Errors.LocationAccessDisabled)
        }
    }
    
    func start() {
        if let locationmanager = manager, isAuthorizationGranted {
            locationmanager.startUpdatingLocation()
        } else {
           self.delegate?.willShowError(self, error: Errors.LocationAccessDisabled)
        }
    }
    
    func stop() {
        if let locationmanager = manager, isAuthorizationGranted {
            locationmanager.stopUpdatingLocation()
        } else {
            self.delegate?.willShowError(self, error: Errors.LocationAccessDisabled)
        }
    }
    
    func requestWhenInUserAuthorization() {
        if let locationmanager = manager {
            locationmanager.requestWhenInUseAuthorization()
        }
    }
    
    func updateUserLocation() {
        isUpdatingUserLocation = true
        start()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            delegate?.didRetrieveStatus(self, authorizationStatus: false)
        } else {
            delegate?.didRetrieveStatus(self, authorizationStatus: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        stop()
        reverseGeocode(usingLocation: location)
    }

    func reverseGeocode(usingLocation location: CLLocation) {
        guard let geocoder = geoCoder else { return }
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let err = error {
                self.delegate?.willShowError(self, error: err)
            } else {
                if let place = placemarks?.first {
                    var data = [String: Any]()
                    data["addressLat"] = location.coordinate.latitude
                    data["addressLong"] = location.coordinate.longitude
                    data["addressCity"] = place.locality ?? ""
                    data["addressState"] = place.administrativeArea ?? ""
                    data["addressCountry"] = place.country ?? ""
                    
                    if isUpdatingUserLocation, let location = Location(JSON: data) {
                        CurrentUser.shared.user?.setLocation(location, { (error) in
                            isUpdatingUserLocation = false
                            if let err = error {
                                print(err.localizedDescription)
                            }
                        })
                    }
                    
                    self.delegate?.willRetrieveLocation(self, location: location, center: location.coordinate, data: data)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        delegate?.willShowError(self, error: error)
    }
}
