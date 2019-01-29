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
            let info = Info(JSON: userInfo!)

            if type == 1 {
                if CurrentUser.shared.user?.userInformation == nil {
                    CurrentUser.shared.user?.userInformation = [Info]()
                }
                CurrentUser.shared.user?.userInformation?.append(info!)
            }

            if type == 2 {
                if CurrentUser.shared.user?.userDetails == nil {
                    CurrentUser.shared.user?.userDetails = [Info]()
                }
                CurrentUser.shared.user?.userDetails?.append(info!)
            }

            self.popViewController()
        }
    }
}
