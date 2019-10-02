import UIKit
import RRoostSDK

class ThoughtCell: UITableViewCell {
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var thoughtLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!

  var post: Post?

  override func awakeFromNib() {
    super.awakeFromNib()
    userImageView.makeCircular()
  }

  func configureCell(post: Post) {
    self.post = post
  }
    
}
