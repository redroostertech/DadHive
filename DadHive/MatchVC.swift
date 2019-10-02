//
//  MatchVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 3/16/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SDWebImage
import RRoostSDK

protocol MatchVCDelegate: class {
  func goBack(_ viewController: UIViewController)
}

class MatchVC: UIViewController {

    @IBOutlet var imgMain: UIImageView!
    @IBOutlet var btnContinue: UIButton!

    weak var delegate: MatchVCDelegate?
    var user: User?

    init(user: User) {
        self.user = user
        super.init(nibName: MatchVC.identifier, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imgMain.applyCornerRadius()
        imgMain.makeAspectFill()
        if let mediaArray = user?.media, mediaArray.count > 0 {
            let media = mediaArray[0]
            if media.url != nil {
                self.imgMain.sd_setImage(with: media.url!, placeholderImage: UIImage(named: "unknown")!, options: SDWebImageOptions.continueInBackground, completed: nil)
            } else {
                self.imgMain.image = UIImage(named: "unknown")
            }
        }
    }

    @IBAction func continueSwiping(_ sender: UIButton) {
        self.dismissViewController()
        self.delegate?.goBack(self)
    }
}

extension MatchVC {
    static var identifier: String = "MatchVC"
}
