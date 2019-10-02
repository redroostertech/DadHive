//
//  AccountVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import UserNotifications
import RRoostSDK
import Freedom

private let baseURL = (isLocal) ? kLocalBaseURL : (isLive) ? kLiveBaseURL : kTestBaseURL

class AccountVC: UITableViewController {

    @IBOutlet weak var lblEmail: TitleLabel!
    @IBOutlet weak var swPushNotifications: UISwitch!

    var userInfo: Info?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
      self.navigationController?.navigationBar.tintColor = .white
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
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 2
        case 3: return 2
        case 4: return 2
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "goToAccountEdit", sender: self)
            default: break
            }
        case 1: break
        case 2:
            switch indexPath.row {
            case 0:
              guard let url = URL(string: baseURL + "privacy"), UIApplication.shared.canOpenURL(url) else { return }
              // Enable Debug Logs (disabled by default)
              Freedom.debugEnabled = true
              // Fetch activities for Safari and all third-party browsers supported by Freedom (see screenshot).
              let activities = Freedom.browsers()
              // Alternatively, one could select a specific browser (or browsers).
              // let activities = Freedom.browsers([.chrome])
              let vc = UIActivityViewController(activityItems: [url], applicationActivities: activities)
              present(vc, animated: true, completion: nil)
            case 1:
              guard let url = URL(string: baseURL + "terms"), UIApplication.shared.canOpenURL(url) else { return }
              // Enable Debug Logs (disabled by default)
              Freedom.debugEnabled = true
              // Fetch activities for Safari and all third-party browsers supported by Freedom (see screenshot).
              let activities = Freedom.browsers()
              // Alternatively, one could select a specific browser (or browsers).
              // let activities = Freedom.browsers([.chrome])
              let vc = UIActivityViewController(activityItems: [url], applicationActivities: activities)
              present(vc, animated: true, completion: nil)
            default: break
            }
        case 3:
          switch indexPath.row {
          case 0: print("View Safe Meeting Tips.")
          case 1:
            performSegue(withIdentifier: "goToViewBlockedUsers", sender: self)
          default: break
          }
        case 4:
            switch indexPath.row {
            case 0:
              let alertController = UIAlertController(title: "Signout", message: "Are you sure?", preferredStyle: .alert)
              let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                  FIRAuthentication.signout()
              })
              let noAction = UIAlertAction(title: "No", style: .cancel, handler: { action in
                alertController.dismiss(animated: true, completion: nil)
              })
              alertController.addAction(yesAction)
              alertController.addAction(noAction)
              self.present(alertController, animated: true, completion: nil)
            case 1:
              let alertController = UIAlertController(title: "Delete Profile", message: "Performing this action will let us know that you are looking to delete your profile. Are you sure?", preferredStyle: .alert)
              let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in

                guard let currentuser = CurrentUser.shared.user else { return }

                let parameters: [String: Any] = [
                  "senderId": currentuser.uid ?? "",
                  "senderEmail": currentuser.email ?? ""
                ]

                APIRepository().performRequest(path: Api.Endpoint.requestForDelete, method: .post, parameters: parameters) { (response, error) in
                  if let err = error {
                    print(err.localizedDescription)
                    self.showError("There was an error blocking content. Please try again.")
                    alertController.dismissViewController()
                  } else {
                    if
                      let res = response as? [String: Any],
                      let data = res["success"] as? [String: Any],
                      let success = Success(JSON: data),
                      let result = success.result,
                      (result) {
                        FIRAuthentication.signout()
                    } else {
                      self.showError("There was an error blocking content. Please try again.")
                      alertController.dismissViewController()
                    }
                  }
                }
              })
              let noAction = UIAlertAction(title: "No", style: .cancel, handler: { action in
                alertController.dismiss(animated: true, completion: nil)
              })
              alertController.addAction(yesAction)
              alertController.addAction(noAction)
              self.present(alertController, animated: true, completion: nil)
            default: break
            }
        default: break
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
