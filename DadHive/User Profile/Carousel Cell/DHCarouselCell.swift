//
//  DHCarouselCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class DHCarouselCell: UITableViewCell {

    @IBOutlet var vwMain: UIView!

    var carousel: DHCarousel?
    var identifier = "DHCarouselItem"
    private var flowLayout: UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100.0, height: 66.0)
        return flowLayout
    }

    var loadUser: User? {
        didSet {
            guard let _ = self.loadUser else { return }
            updateNib()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func updateNib() {
        carousel = DHCarousel(collectionViewLayout: flowLayout, cellID: identifier, andUserData: loadUser!)
        carousel!.view.frame = vwMain.bounds
        vwMain.addSubview(carousel!.view)
        self.awakeFromNib()
    }
    
}
