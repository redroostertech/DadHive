//
//  UsersViewCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/24/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class UsersViewCell: UITableViewCell {

  @IBOutlet private weak var userImageView: UIImageView!
  @IBOutlet private weak var userNameLabel: UILabel!

  private var user: User? {
    didSet {
      guard let user = self.user else { return }
      userName = user.name?.fullName
      userImage = user.media?.first(where: { (media) -> Bool in
        guard let order = media.order else { return false }
        return order == 1
      })?.url
    }
  }

  private var userName: String? {
    didSet {
      guard let username = self.userName else { return }
      userNameLabel.text = username
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

  func configure(user: User) {
    self.user = user
  }

}
