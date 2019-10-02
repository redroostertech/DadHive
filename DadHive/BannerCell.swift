//
//  BannerCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/27/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class BannerCell: UITableViewCell {
  func configure() {
    GoogleAdMobManager.shared.showBannerView(in: UIApplication.shared.keyWindow!.rootViewController!, on: self.contentView)
  }
}
