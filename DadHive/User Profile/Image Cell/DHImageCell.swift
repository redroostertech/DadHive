//
//  DHImageCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK

protocol SwipingDelegate {
    func didLike(user: User)
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

    var mediaArray: [Media]? {
        didSet {
            guard let _ = self.mediaArray else { return }
            updateNib()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        btnCheck.applyCornerRadius()
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        delegate?.didLike(user: loadUser!)
    }

    private func updateNib() {
        guard let mediaArray = self.mediaArray, mediaArray.count > 0 else {
            self.awakeFromNib()
            return
        }
        carousel = DHCarousel(collectionViewLayout: flowLayout, cellID: identifier, andMedia: mediaArray)
        carousel!.view.frame = vwMain.bounds
        vwMain.addSubview(carousel!.view)
        self.awakeFromNib()
    }

    func hideCheckButton() {
        self.btnCheck.isHidden = true
    }
}
