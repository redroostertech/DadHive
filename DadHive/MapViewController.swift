import UIKit
import MapKit

private let kUserMapPinImage = UIImage(named: "unknown")!.resize(withWidth: 32)
private let kUserMapAnimationTime = 0.300
private let kUserAnnotationName = "kUserAnnotationName"

class MapViewController: UIViewController {
    
    @IBOutlet weak var toggleButton: UIButton!
    
    var map: MKMapView!
    var users: Users?
    var apiRepository = APIRepository()
    var annotations = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map = MKMapView(frame: view.frame)
        view.addSubview(map)
        map.delegate = self
        map.showsUserLocation = true
        map.showsPointsOfInterest = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveUsers()
    }
    
    @IBAction func toggleButtonAction(_ sender: UIButton) {
        toggleAction(sender)
    }
}

// MARK: - Methods
extension MapViewController {
    func toggleAction(_ sender: UIButton) {
        
    }
    
    func retrieveUsers() {
        showHUD("Finding Users", withDuration: 30.0)
        loadUsers { (error, results) in
            self.dismissHUD()
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
                    //self.map.removeAnnotations(self.map.annotations)
                    self.map.addAnnotations(self.annotations)
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

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let currentUser = CurrentUser.shared.user else {
            return
        }
        
        guard let long = currentUser.settings?.location?.addressLong, let lat = currentUser.settings?.location?.addressLat else {
            return
        }
        guard let longDegrees = CLLocationDegrees(exactly: long), let latDegrees = CLLocationDegrees(exactly: lat) else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
        let visibleRegion = MKCoordinateRegionMakeWithDistance(center, 1000, 1000)
        self.map.setRegion(self.map.regionThatFits(visibleRegion), animated: true)
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

class UserAnnotation: NSObject, MKAnnotation {
    var user: User
    var coordinate: CLLocationCoordinate2D {
        guard let long = user.settings?.location?.addressLong, let lat = user.settings?.location?.addressLat else {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees.zero, longitude: CLLocationDegrees.zero)
        }
        guard let longDegrees = CLLocationDegrees(exactly: long), let latDegrees = CLLocationDegrees(exactly: lat) else {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees.zero, longitude: CLLocationDegrees.zero)
        }
        return CLLocationCoordinate2D(latitude: longDegrees, longitude: latDegrees)
    }
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    var title: String? {
        return user.name?.fullName
    }
    
    var subTitle: String? {
        return user.kidsNames
    }
}

class UserAnnotationView: MKAnnotationView {
    weak var userDetailDelegate: UserDetailMapViewDelegate?
    weak var customCalloutView: UserDetailMapView?
    override var annotation: MKAnnotation? {
        willSet { customCalloutView?.removeFromSuperview() }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = kUserMapPinImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false // This is important: Don't show default callout.
        self.image = kUserMapPinImage
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.customCalloutView?.removeFromSuperview() // remove old custom callout (if any)
            
            if let newCustomCalloutView = loadUserDetailMapView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: kUserMapAnimationTime, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: kUserMapAnimationTime, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { (success) in
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else { self.customCalloutView!.removeFromSuperview() } // just remove it.
            }
        }
    }
    
    func loadUserDetailMapView() -> UserDetailMapView? {
        if let views = Bundle.main.loadNibNamed("UserDetailMapView", owner: self, options: nil) as? [UserDetailMapView], views.count > 0 {
            let userDetailMapView = views.first!
            userDetailMapView.delegate = self.userDetailDelegate
            if let userAnnotation = annotation as? UserAnnotation {
                let user = userAnnotation.user
                userDetailMapView.configureWithUser(user: user)
            }
            return userDetailMapView
        }
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    
    // MARK: - Detecting and reaction to taps on custom callout.
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else { return nil }
        }
    }
}
