//
//  ViewBlockedUsersViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/24/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK
import SVProgressHUD
import Sheeeeeeeeet

private var users: Users?
private var apiRepository = APIRepository()

class ViewBlockedUsersViewController: UIViewController {

  @IBOutlet private weak var topicsTable: UITableView!

  private var topicsCount: Int {
    return users?.users?.count ?? 0
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    DispatchQueue.main.async {
      self.navigationController?.navigationBar.tintColor = .white
      self.hideNavigationBarHairline()
      self.setupSuperHUD()
    }

    setupTopicsTable()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DispatchQueue.global(qos: .background).async {
      self.loadPosts()
    }
  }

  private func setupTopicsTable() {
    topicsTable.delegate = self
    topicsTable.dataSource = self
    topicsTable.register(UsersViewCell.nib, forCellReuseIdentifier: UsersViewCell.identifier)
  }

  func loadPosts() {

    DispatchQueue.main.async {
      self.showHUD(kLoadingPosts)
    }

    retrieveAllData { (usrs, error) in
      DispatchQueue.main.async {
        self.dismissHUD()
      }
      if let _ = error {
        self.showHUD(kGenericError)
      } else {
        users = usrs
        self.topicsTable.reloadData()
      }
    }
  }

  private func retrieveAllData(completion: @escaping (Users?, Error?) -> Void) {
    guard let currentuser = CurrentUser.shared.user else { return }

    let params: [String: Any] = [
      "type": 1,
      "senderId": currentuser.uid ?? "",
      "excludedIds": currentuser.actions?.excludedIDs ?? [String](),
    ]
    apiRepository.performRequest(path: Api.Endpoint.getBlockedUsers, method: .post, parameters: params) { (response, error) in
      guard error == nil else {
        print("There was an error at the api.")
        return completion(nil, error)
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return completion(nil, nil)
      }

      guard let data = res["data"] as? [String: Any], let users = Users(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return completion(nil, nil)
      }

      completion(users, nil)
    }
  }
}

extension ViewBlockedUsersViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return topicsCount
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersViewCell.identifier) as? UsersViewCell, let users = users?.users else { return UITableViewCell() }
    let user = users[indexPath.row]
    cell.configure(user: user)
    return cell
  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    guard let users = users?.users else { return nil }
    let user = users[indexPath.row]

    let whitespace = whitespaceString(width: 100)

    let blockContent = UITableViewRowAction(style: .normal, title: whitespace) { action, index in
      let alertController = UIAlertController(title: "Unblock User", message: "Performing this action will unblock the user and you will begin to see their posts.", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in

        guard let currentuser = CurrentUser.shared.user else { return }

        let parameters: [String: Any] = [
          "senderId": currentuser.uid ?? "",
          "recipientId": user.uid ?? "",
        ]

        APIRepository().performRequest(path: Api.Endpoint.unblockUser, method: .post, parameters: parameters) { (response, error) in
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
              CurrentUser.shared.refresh {
                self.loadPosts()
                alertController.dismissViewController()
              }
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
    }
    let blockContentImage = customImageAction("dismiss_butt",
                                              forCell: tableView.cellForRow(at: indexPath))
    blockContent.backgroundColor = UIColor(patternImage: blockContentImage)

    return [blockContent]
  }

  fileprivate func whitespaceString(font: UIFont = UIFont.systemFont(ofSize: 15), width: CGFloat) -> String {
    let kPadding: CGFloat = 20
    let mutable = NSMutableString(string: "")
    let attribute = [NSAttributedStringKey.font: font]
    while mutable.size(withAttributes: attribute).width < width - (2 * kPadding) {
      mutable.append(" ")
    }
    return mutable as String
  }

  func customImageAction(_ named: String, forCell cell: UITableViewCell?) -> UIImage {
    let cellHeight = cell?.frame.size.height ?? 0.0
    let kActionImageSize: CGFloat = 34
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: cellHeight))
    view.backgroundColor = UIColor.white
    let imageView = UIImageView(frame: CGRect(x: (100 - kActionImageSize) / 2,
                                              y: (cellHeight - kActionImageSize) / 2,
                                              width: 34,
                                              height: 34))
    imageView.image = UIImage(named: named)
    view.addSubview(imageView)
    let image = view.image()
    return image
  }
}
