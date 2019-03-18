//
//  AccountVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import UserNotifications

class AccountVC: UITableViewController {

    @IBOutlet weak var lblEmail: TitleLabel!
    @IBOutlet weak var swPushNotifications: UISwitch!

    var userInfo: Info?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    @IBAction func toggleNotifications(_ sender: UISwitch) {
        CurrentUser.shared.user?.setNotificationToggle(sender.isOn)
    }

    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 3
        case 3: return 2
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: print("Change Email")
            default: print("Do Nothing")
            }
        case 1: print("No touches necessary")
        case 2:
            switch indexPath.row {
            case 0: print("View Privacy Policy")
            case 1: print("View Terms of Service")
            case 2: print("View Safe Meeting tips.")
            default: print("Do Nothing")
            }
        case 3:
            switch indexPath.row {
            case 0: FIRAuthentication.shared.signout()
            case 1: print("Delete Account")
            default: print("Do Nothing")
            }
        default: print("Do nothing")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
        if segue.identifier == "goToAccountEdit" {
            let destination = segue.destination as! EditAccountVC
            destination.userInfo = userInfo
            destination.type = 1
        }
    }
}

extension AccountVC {
    func setupUI() {
        lblEmail.text = String(describing: CurrentUser.shared.user?.email ?? "No Response")
        swPushNotifications.isOn = CurrentUser.shared.user?.settings?.notifications ?? false
    }
}
