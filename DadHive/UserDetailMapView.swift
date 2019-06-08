import UIKit
import SDWebImage

protocol UserDetailMapViewDelegate: class {
    func detailsRequestedForUser(person: User)
}

class UserDetailMapView: UIView {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    var user: User!
    weak var delegate: UserDetailMapViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.applyCornerRadius()
        userImageView.applyBorder(withColor: .flatForestGreen, andThickness: 1.0)
        profileButton.applyCornerRadius()
        profileButton.setBackgroundColor(.flatForestGreen)
        profileButton.setWhiteText()
        usernameLabel.font = UIFont(name: kFontBody, size: kFontSizeBody)
    }
    
    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if it hit our annotation detail view components.
        
        // details button
        if let result = profileButton.hitTest(convert(point, to: profileButton), with: event) {
            return result
        }
        // fallback to our background content view
        return nil
    }
    
    func configureWithUser(user: User) {
        self.user = user
        
        usernameLabel.text = user.name?.fullName ?? "No name available"
        
        if let mediaArray = user.media, mediaArray.count > 0 {
            let media = mediaArray[0]
            if media.url != nil {
                self.userImageView.sd_setImage(with:  media.url, placeholderImage: UIImage(named: "unknown"), options: [.continueInBackground], completed: nil)
            } else {
                self.userImageView.image = UIImage(named: "unknown")
            }
        }
    }
    
    @IBAction func profileButtonAction(_ sender: UIButton) {
        delegate?.detailsRequestedForUser(person: user)
    }
    
}
