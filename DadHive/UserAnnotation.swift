import Foundation
import UIKit
import MapKit
import CoreLocation

private let kUserMapPinImage = UIImage(named: "unknown")!.resize(withWidth: 32)
private let kUserMapAnimationTime = 0.300

class UserAnnotation: NSObject, MKAnnotation {
    var user: User
    var coordinate: CLLocationCoordinate2D {
        guard let long = user.settings?.location?.addressLong, let lat = user.settings?.location?.addressLat else {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees.zero, longitude: CLLocationDegrees.zero)
        }
        guard let longDegrees = CLLocationDegrees(exactly: long), let latDegrees = CLLocationDegrees(exactly: lat) else {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees.zero, longitude: CLLocationDegrees.zero)
        }
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    var title: String? {
        return user.name?.fullName
    }
    
    var subtitle: String? {
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
        self.image = kUserMapPinImage?.circleMasked
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

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
