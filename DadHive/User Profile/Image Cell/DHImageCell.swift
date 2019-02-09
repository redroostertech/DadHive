//
//  DHImageCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

protocol SwipingDelegate {
    func didLikeUser()
    func didNotLikeUser()
}

class DHImageCell: UITableViewCell {

    @IBOutlet private var vwMain: UIView!
    @IBOutlet private var btnCheck: UIButton!

    var carousel: DHCarousel?
    var identifier = "DHCarouselImage"
    var delegate: SwipingDelegate?

    private var flowLayout: UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: kWidthOfScreen, height: 300.0)
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
        btnCheck.applyCornerRadius()
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        delegate?.didLikeUser()
    }

    private func updateNib() {
        carousel = DHCarousel(collectionViewLayout: flowLayout, cellID: identifier, andUserData: loadUser!)
        carousel!.view.frame = vwMain.bounds
        vwMain.addSubview(carousel!.view)
        self.awakeFromNib()
    }
}
