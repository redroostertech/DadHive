//
//  DHCarouselImage.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SDWebImage
import RRoostSDK

class DHCarouselImage: UICollectionViewCell {

    @IBOutlet private var vwContent: UIView!
    @IBOutlet private var imgvwMain: UIImageView!

    var media: URL? {
        didSet {
            guard let media = self.media else { return }
            self.imgvwMain.sd_setImage(with: media, completed: nil)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imgvwMain.applyClipsToBounds(true)
        imgvwMain.makeAspectFill()
    }

}
