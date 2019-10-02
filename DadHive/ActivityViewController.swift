//
//  ActivityViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/19/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

private var notifications: NotificationResponse?
private var apiRepository = APIRepository()

class ActivityViewController: UIViewController {

  @IBOutlet private weak var topicsTable: UITableView!

  var parentVC: UIViewController?

  private var notificationsCount: Int {
    return notifications?.notifications?.count ?? 0
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
    topicsTable.register(NotificationCell.nib, forCellReuseIdentifier: NotificationCell.identifier)
    topicsTable.emptyDataSetView { view in
      view.titleLabelString(NSAttributedString(string: "No Activity"))
        .detailLabelString(NSAttributedString(string: "Nobody has upvoted on commented on your topic(s) yet"))
        .image(UIImage(named: "dadhive-hive-sm"))
        .dataSetBackgroundColor(UIColor.white)
        .shouldDisplay(true)
        .shouldFadeIn(true)
        .isTouchAllowed(true)
        .isScrollAllowed(true)
        .verticalOffset(-40.0)
        .verticalSpace(24.0)
    }
  }

  func loadPosts() {

    DispatchQueue.main.async {
      self.showHUD(kLoadingPosts)
    }

    retrieveAllData { (notifs, error) in
      DispatchQueue.main.async {
        self.dismissHUD()
      }
      if let _ = error {
        self.showHUD(kGenericError)
      } else {
        notifications = notifs
        self.topicsTable.reloadData()
      }
    }
  }

  private func retrieveAllData(completion: @escaping (NotificationResponse?, Error?) -> Void) {
    guard let currentuser = CurrentUser.shared.user else { return }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "excludedIds": currentuser.actions?.excludedIDs ?? [String](),
    ]
    apiRepository.performRequest(path: Api.Endpoint.getActivityForUser, method: .post, parameters: params) { (response, error) in
      guard error == nil else {
        print("There was an error at the api.")
        return completion(nil, error)
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return completion(nil, nil)
      }

      guard let data = res["data"] as? [String: Any], let notifs = NotificationResponse(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return completion(nil, nil)
      }

      completion(notifs, nil)
    }
  }

  func reloadTable() {
    self.topicsTable.reloadData()
  }
}

extension ActivityViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notificationsCount
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier) as? NotificationCell, let notifs = notifications?.notifications else { return UITableViewCell() }
    let notif = notifs[indexPath.row]
    cell.configure(notifications: notif)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let notifs = notifications?.notifications else { return }
    let notif = notifs[indexPath.row]
    guard let topics = notif.post else { return }
    let topic = topics[0]
    topic.owner = notif.owner
    let sb = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = sb.instantiateViewController(withIdentifier: "TopicDetailVC") as? TopicDetailVC else { return }
    vc.set(post: topic)
    parentVC?.pushToView(withViewController: vc)
  }
}
