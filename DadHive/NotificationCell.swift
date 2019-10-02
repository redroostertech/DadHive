//
//  NotificationCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/19/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var userProfileButton: UIButton!
  @IBOutlet weak var dateLabel: UILabel!

  private var notifications: Notifications? {
    didSet {
      guard let notifs = self.notifications else { return }
      user = notifs.owner
      dateLabel.text = notifs.createdAt
      messageLabel.text = notifs.message
    }
  }
  private var userName: String?

  private var user: [User]? {
    didSet {
      guard let user = self.user?[0] else { return }
      userName = user.name?.fullName
      userImage = user.media?.first(where: { (media) -> Bool in
        guard let order = media.order else { return false }
        return order == 1
      })?.url
    }
  }

  private var userImage: URL? {
    didSet {
      guard let userimage = self.userImage else { return }
      userImageView.imageFromUrl(theUrl: userimage.absoluteString)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    userImageView.applyCornerRadius()
  }

  func configure(notifications: Notifications) {
    self.notifications = notifications

//    if notifications.type == "1" {
//      if let name = userName {
//        messageLabel.text = "\(name) liked your post."
//      } else {
//        messageLabel.text = "Someone liked your post."
//      }
//    }
//
//    if notifications.type == "2" {
//      if let name = userName {
//        messageLabel.text = "\(name) commented on your post."
//      } else {
//        messageLabel.text = "Someone commented on your post."
//      }
//    }
//
//    if notifications.type == "3" {
//      if let name = userName {
//        messageLabel.text = "\(name) upvoted your post."
//      } else {
//        messageLabel.text = "Someone upvoted on your post."
//      }
//    }
  }

}
