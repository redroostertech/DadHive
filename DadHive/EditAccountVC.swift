//
//  EditAccountVC.swift
//  Alamofire
//
//  Created by Michael Westbrooks on 12/31/18.
//

import UIKit

class EditAccountVC: UIViewController {

    @IBOutlet weak var lblTitle: TitleLabel!
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var btnSave: UIButton!

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
                self.currentUser.user?.change(name: txtField.text, {
                    (error) in
                    if let err = error {
                        print(err)
                    } else {
                        DispatchQueue.main.async {
                            self.popViewController()
                        }
                    }
                })
            } else {
                self.currentUser.user?.setInformation(atKey: userInfo.type ?? "", withValue: txtField.text, {
                    (error) in
                    if let err = error {
                        print(err)
                    } else {
                        DispatchQueue.main.async {
                            self.popViewController()
                        }
                    }
                })
            }
            userInfo.info = txtField.text
        }
    }
}
