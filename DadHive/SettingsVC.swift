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

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
        lblFullname.font = UIFont(name: kFontBody, size: kFontSizeBody)
        lblFullname.text = CurrentUser.shared.user?.name?.userFullName ?? ""
        lblPreferences.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        lblAccount.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        btnProfilePicture.applyCornerRadius()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
    }
}
