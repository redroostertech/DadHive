//
//  HomeCellCollectionViewCell.swift
//  DadHive
//
//  Created by Michael Westbrooks II on 11/20/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK

class HomeCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainHighlightCell: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var userAvi: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mainHighlightCell.numberOfLines = 1
        mainHighlightCell.lineBreakMode = .byTruncatingTail
        
        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        userAvi.layer.cornerRadius = userAvi.frame.height / 2
        userAvi.clipsToBounds = true
    }

}
