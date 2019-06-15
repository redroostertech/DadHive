import UIKit
import MapKit
import LGButton

private let kUserAnnotationName = "kUserAnnotationName"

class MapViewController: UIViewController {
    
    @IBOutlet private weak var toggleButton: LGButton!
    @IBOutlet private weak var actionSectionContainer: UIView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var recenterButton: UIButton!
    
    var apiRepository = APIRepository()
    var users = [User]()
    var annotations = [MKAnnotation]()
    let locationManager = LocationManager()
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.checkPermissions()
        recenterButton.applyCornerRadius()
    }
    
    @IBAction func toogleButtonAction(_ sender: LGButton) {
        let destination = ActivitySelectorVC(nibName: "ActivitySelectorVC", bundle: nil)
        destination.activitySelectorDelegate = self
        destination.modalPresentationStyle = .overFullScreen
        destination.modalTransitionStyle = .coverVertical
        self.present(destination, animated: true, completion: nil)
    }
    
    @IBAction func recenterButtonAction(_ sender: UIButton) {
        mapView(mapView, didUpdate: mapView.userLocation)
    }
}

// MARK: - Class methods
extension MapViewController {
    func retrieveUsers(_ sender: LGButton) {
        showHUD("Finding Users", withDuration: 30.0)
        loadUsers { (error, results) in
            self.dismissHUD()
            sender.isLoading = false
            if let err = error {
                print(err.localizedDescription)
                self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
            } else {
                if
                    let res = results,
                    let objs = res.users
                {
                    for user in objs {
                        let annotation = UserAnnotation(user: user)
                        self.annotations.append(annotation)
                    }
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotations(self.annotations)
                } else {
                    self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
                }
            }
        }
    }
    
    func loadUsers(_ completion: @escaping(Error?, Users?) -> Void) {
        guard let currentUser = CurrentUser.shared.user else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
            return
        }
        if
            let userId = currentUser.uid,
            let lat = currentUser.settings?.location?.addressLat,
            let long = currentUser.settings?.location?.addressLong,
            let radius = currentUser.settings?.maxDistance,
            let pageNo = (currentUser.currentPage != nil) ? currentUser.currentPage : 1,
            let lastId = (currentUser.lastId != nil) ? currentUser.lastId : ""
        {
            let parameters: [String: Any] = [
                "userId": userId,
                "latitude": Double(lat),
                "longitude": Double(long),
                "maxDistance": Double(25.0) /*Double(radius)*/,
                "pageNo": pageNo,
                "lastId": lastId,
                "ageRangeId": currentUser.settings?.ageRange?.id,
                "perPage": 1
            ]
            self.apiRepository.performRequest(path: Api.Endpoint.getNearbyUsers, method: .post, parameters: parameters) { (response, error) in
                guard error == nil else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                
                guard let res = response as? [String: Any] else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                
                guard let data = res["data"] as? [String: Any] else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                
                guard let usersData = Users(JSON: data) else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                completion(nil, usersData)
            }
        }
    }
}

// MARK: - ActivitySelectorDelegate
extension MapViewController: ActivitySelectorDelegate {
    func didStartHive(_ viewController: UIViewController, button: LGButton) {
        print("didStartHive")
        toggleButton.titleString = button.titleString
    }
    
    func didFindHive(_ viewController: UIViewController, button: LGButton) {
        print("didFindHive")
        retrieveUsers(button)
        toggleButton.titleString = button.titleString
    }
    
    func didCancel(_ viewController: UIViewController, button: LGButton) {
        print("didCancel")
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let currentUser = CurrentUser.shared.user else { return }
        let visibleRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 5000, 5000)
        mapView.setRegion(mapView.regionThatFits(visibleRegion), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var annotationView: MKAnnotationView?
            
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: kUserAnnotationName) as? UserAnnotationView {
            view.annotation = annotation
            annotationView = view
        } else {
            let view = UserAnnotationView(annotation: annotation, reuseIdentifier: kUserAnnotationName) as! UserAnnotationView
            view.userDetailDelegate = self
            annotationView = view
        }
        
        return annotationView
        
    }
}

// MARK: - UserDetailMapViewDelegate
extension MapViewController: UserDetailMapViewDelegate {
    func detailsRequestedForUser(person: User) {
        print("User selected")
    }
}

// MARK: - LocationManagerDelegate
extension MapViewController: LocationManagerDelegate {
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
