//
//  MatchVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 3/16/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SDWebImage

class MatchVC: UIViewController {

    @IBOutlet var imgMain: UIImageView!
    @IBOutlet var btnMessage: UIButton!
    @IBOutlet var btnContinue: UIButton!
    
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
        
    }

    @IBAction func sendMessage(_ sender: UIButton) {
    }

    @IBAction func continueSwiping(_ sender: UIButton) {
        self.dismissViewController()
    }
}

extension MatchVC {
    static var identifier: String = "MatchVC"
}
