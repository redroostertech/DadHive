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

        //  MARK:- Create conversation object
        let conversation: [String: String] = [
            "id": Utilities.randomString(length: 25),
            "senderId": CurrentUser.shared.user?.uid ?? "",
            "recipientId": user?.uid ?? "",
            "createdAt": Date().toString(format: CustomDateFormat.timeDate.rawValue),
            "updatedAt": Date().toString(format: CustomDateFormat.timeDate.rawValue)
        ]

        //  MARK:- Add conversation object
        FIRFirestoreDB.shared.add(data: conversation, to: kConversations, completion: { (success, docID, error) in

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            guard docID != nil else {
                return
            }

            print("Conversation created")
        })
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
