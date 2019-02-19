//
//  EditAccountVC.swift
//  Alamofire
//
//  Created by Michael Westbrooks on 12/31/18.
//

import UIKit

class EditAccountVC: UIViewController {

    @IBOutlet var lblTitle: TitleLabel!
    @IBOutlet var txtField: UITextView!
    @IBOutlet var btnSave: UIButton!

    var userInfo: Info?
    var currentUser = CurrentUser.shared
    var type = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        btnSave.applyCornerRadius()
        btnSave.addGradientLayer(using: kAppCGColors)
        lblTitle.text = userInfo?.title ?? ""
    }

    @IBAction func save(_ sender: UIButton) {
        if let userInfo = self.userInfo, txtField.text != "" {
            if let type = userInfo.type, type == "name" {
                self.currentUser.user?.change(name: txtField.text)
            } else {
                self.currentUser.user?.setInformation(atKey: userInfo.type ?? "", withValue: txtField.text)
            }
            userInfo.info = txtField.text
            self.popViewController()
        }
    }
}
