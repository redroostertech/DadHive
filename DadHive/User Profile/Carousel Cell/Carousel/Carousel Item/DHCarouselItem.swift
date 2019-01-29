//
//  DHCarouselItem.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class DHCarouselItem: UICollectionViewCell {

    @IBOutlet private var vwContent: UIView!
    @IBOutlet private var imgvwInfoType: UIImageView!
    @IBOutlet private var lblInfo: UILabel!

    var loadData: Info? {
        didSet {
            guard let info = self.loadData else { return }
            self.lblInfo.text = info.userInfo
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        imgvwInfoType.addGradientLayer(using: kAppCGColors)
        imgvwInfoType.makeAspectFill()
    }

}
