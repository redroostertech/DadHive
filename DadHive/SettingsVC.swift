//
//  SettingsVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {

    @IBOutlet var btnProfilePicture: UIButton!
    @IBOutlet var lblFullname: UILabel!
    @IBOutlet var lblPreferences: UILabel!
    @IBOutlet var lblAccount: UILabel!

    var currentUser = CurrentUser.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
        lblFullname.font = UIFont(name: kFontBody, size: kFontSizeBody)
        lblFullname.text = currentUser.user?.name?.fullName ?? ""
        lblPreferences.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        lblAccount.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        btnProfilePicture.applyCornerRadius()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
    }
}
