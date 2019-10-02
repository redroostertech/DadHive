//
//  ViewMyPostsViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/24/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK
import SVProgressHUD
import Sheeeeeeeeet

private var topics: Posts?
private var apiRepository = APIRepository()

class ViewMyPostsViewController: UIViewController {

  @IBOutlet private weak var topicsTable: UITableView!

  private var topicsCount: Int {
    return topics?.posts?.count ?? 0
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
    topicsTable.register(TopicsCell.nib, forCellReuseIdentifier: TopicsCell.identifier)
  }

  func loadPosts() {

    DispatchQueue.main.async {
      self.showHUD(kLoadingPosts)
    }

    retrieveAllData { (psts, error) in
      DispatchQueue.main.async {
        self.dismissHUD()
      }
      if let _ = error {
        self.showHUD(kGenericError)
      } else {
        topics = psts
        self.topicsTable.reloadData()
      }
    }

  }

  private func retrieveAllData(completion: @escaping (Posts?, Error?) -> Void) {
    guard let currentuser = CurrentUser.shared.user else { return }

    let params: [String: Any] = [
      "type": 1,
      "senderId": currentuser.uid ?? "",
      "excludedIds": currentuser.actions?.excludedIDs ?? [String](),
    ]
    apiRepository.performRequest(path: Api.Endpoint.getPostsByUser, method: .post, parameters: params) { (response, error) in
      guard error == nil else {
        print("There was an error at the api.")
        return completion(nil, error)
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return completion(nil, nil)
      }

      guard let data = res["data"] as? [String: Any], let posts = Posts(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return completion(nil, nil)
      }

      completion(posts, nil)
    }
  }

  private func configureTopicCellModel(_ topic: Post) -> TopicsCellModel {
    return TopicsCellModel(delegate: self, topic: topic)
  }
}

extension ViewMyPostsViewController: TopicsCellDelegate {
  func didUpvote(_ cell: UITableViewCell, topic: Post) {
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let c = cell as? TopicsCell, let topicid = topic.id, let owner = topic.owner?[0], let ownerId = owner.uid else { return }

    DispatchQueue.main.async {
      self.showHUD(kGenericSaving)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": EngagementType.upvote.rawValue,
      "post": topicid,
      "ownerId": ownerId
    ]
    apiRepository.performRequest(path: Api.Endpoint.addEngagement, method: .post, parameters: params) { (response, error) in

      DispatchQueue.main.async {
        self.dismissHUD()
      }

      guard error == nil else {
        print("There was an error at the api.")
        return
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return
      }

      guard let data = res["data"] as? [String: Any], let _ = Engagement(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return
      }

      c.updateUpvoteCount()

    }
  }

  func didDownvote(_ cell: UITableViewCell, topic: Post) {
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let _ = cell as? TopicsCell, let topicid = topic.id, let owner = topic.owner?[0], let ownerId = owner.uid else { return }

    DispatchQueue.main.async {
      self.showHUD(kGenericSaving)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": EngagementType.downvote.rawValue,
      "post": topicid,
      "ownerId": ownerId
    ]

    apiRepository.performRequest(path: Api.Endpoint.addEngagement, method: .post, parameters: params) { (response, error) in

      DispatchQueue.main.async {
        self.dismissHUD()
      }

      guard error == nil else {
        print("There was an error at the api.")
        return
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return
      }

      guard let data = res["data"] as? [String: Any], let _ = Engagement(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return
      }
    }
  }
}

extension ViewMyPostsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return topicsCount
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: TopicsCell.identifier) as? TopicsCell, let topics = topics?.posts else { return UITableViewCell() }
    let topic = topics[indexPath.row]
    let model = configureTopicCellModel(topic)
    cell.configure(topics: model)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let topics = topics?.posts else { return }
    let topic = topics[indexPath.row]
    let sb = UIStoryboard(name: kMainStoryboard, bundle: nil)
    guard let vc = sb.instantiateViewController(withIdentifier: "TopicDetailVC") as? TopicDetailVC else { return }
    vc.set(post: topic)
    pushToView(withViewController: vc)
  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    guard let topics = topics?.posts else { return nil }
    let topic = topics[indexPath.row]

    let whitespace = whitespaceString(width: 100)

    let blockContent = UITableViewRowAction(style: .normal, title: whitespace) { action, index in
      let alertController = UIAlertController(title: "Delete Post", message: "Performing this action will delete this post.", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in

        guard let currentuser = CurrentUser.shared.user else { return }

        let parameters: [String: Any] = [
          "senderId": currentuser.uid ?? "",
          "objectId": topic.id ?? "",
        ]

        APIRepository().performRequest(path: Api.Endpoint.deletePost, method: .post, parameters: parameters) { (response, error) in
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
