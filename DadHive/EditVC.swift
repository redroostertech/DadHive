//
//  EditVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/31/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class EditVC: UIViewController {

    @IBOutlet var lblTitle: TitleLabel!
    @IBOutlet var txtField: UITextView!
    @IBOutlet var btnSave: UIButton!

    var userInfo: [String: Any]?
    var type = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        btnSave.applyCornerRadius()
        btnSave.addGradientLayer(using: kAppCGColors)
        lblTitle.text = userInfo?["title"] as? String ?? ""
    }

    @IBAction func save(_ sender: UIButton) {
        if txtField.text != "" {
            userInfo!["info"] = txtField.text
            if type == 1 {
                CurrentUser.shared.user?.setInformation(self.userInfo!)
            }
            if type == 2 {
                CurrentUser.shared.user?.setDetails(self.userInfo!)
            }
            self.popViewController()
        }
    }

}
