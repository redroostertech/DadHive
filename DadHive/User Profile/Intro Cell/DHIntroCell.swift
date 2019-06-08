import UIKit

class DHIntroCell: UITableViewCell {

    @IBOutlet private var lblName: UILabel!
    @IBOutlet private var lblKids: UILabel!
    @IBOutlet private var imgKids: UIImageView!

    var loadUser: User? {
        didSet {
            guard let user = self.loadUser else { return }

            if let name = user.name?.fullName {
                self.lblName.text = "\(name)"
            }

            if let age = user.age {
                self.lblName.text?.append(", \(age)")
            }

            if user.name?.fullName == nil && user.age == nil {
                self.lblName.text = "No Name"
            }
            
            self.lblKids.text = user.kidsNames ?? "No Kids"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        imgKids.makeAspectFill()
        imgKids.applyCornerRadius(0.25)
    }
}
