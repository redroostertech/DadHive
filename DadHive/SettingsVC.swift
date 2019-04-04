//
//  SettingsVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {

    @IBOutlet weak var btnProfilePicture: UIButton!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var lblPreferences: UILabel!
    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
        hideNavigationBar()
        lblFullname.font = UIFont(name: kFontBody, size: kFontSizeBody)
        lblFullname.text = CurrentUser.shared.user?.name?.fullName ?? ""
        lblPreferences.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        lblAccount.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        btnProfilePicture.applyCornerRadius()
        btnRefresh.isHidden = true

        if let mediaArray = CurrentUser.shared.user?.media, mediaArray.count > 0 {
            let media = mediaArray[0]
            self.btnProfilePicture.imageView?.contentMode = .scaleAspectFill
            if media.url != nil {
                self.btnProfilePicture.sd_setImage(with: media.url, for: .normal, completed: nil)
            } else {
                self.btnProfilePicture.setImage(UIImage(named: "unknown"), for: .normal)
            }
        }
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unHideNavigationBar()
        clearNavigationBackButtonText()
    }

    @IBAction func refreshProfile(_ sender: UIButton) {
    }
}
