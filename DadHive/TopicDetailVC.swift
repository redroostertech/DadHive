//
//  TopicDetailVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/17/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RSKGrowingTextView

private var topic: Post?
private var apiRepository = APIRepository()
private var engagements: Engagements?

class TopicDetailVC: UIViewController {

  @IBOutlet private weak var topicDetailTable: UITableView!
  @IBOutlet weak var messageTextView: RSKGrowingTextView!

  var message: String?
  private var topicViewModel: TopicsCellModel?

  private var engagementCount: Int {
    return engagements?.engagements?.count ?? 0
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    DispatchQueue.main.async {
      self.hideNavigationBarHairline()
    }

    setupTable()

    if let post = topic {
      topicViewModel = configureTopicCellModel(post)
    }

    DispatchQueue.global(qos: .background).async {
      self.loadComments()
    }

    messageTextView.delegate = self

    let moreButton = UIButton(type: .system)
    moreButton.frame = CGRect(x: .zero, y: .zero, width: 35.0, height: 35.0)
    moreButton.tintColor = .white
    moreButton.setImage(UIImage(named: "more"), for: .normal)
    moreButton.addTarget(self, action: #selector(viewMore), for: .touchUpInside)
    updateNavigationBar(withButton: moreButton)
  }

  private func setupTable() {
    topicDetailTable.delegate = self
    topicDetailTable.dataSource = self
    topicDetailTable.register(TopicReplyCell.nib, forCellReuseIdentifier: TopicReplyCell.identifier)
    topicDetailTable.register(TopicActivityCell.nib, forCellReuseIdentifier: TopicActivityCell.identifier)
    topicDetailTable.register(TopicDescriptionCell.nib, forCellReuseIdentifier: TopicDescriptionCell.identifier)
    topicDetailTable.register(HeaderCell.nib, forCellReuseIdentifier: HeaderCell.identifier)
    topicDetailTable.register(BannerCell.nib, forCellReuseIdentifier: BannerCell.identifier)
  }

  private func configureTopicCellModel(_ topic: Post) -> TopicsCellModel {
    return TopicsCellModel(delegate: self, topic: topic)
  }

  private func configureEngagementCellModel(_ engagement: Engagement) -> EngagementsCellModel {
    return EngagementsCellModel(delegate: self, engagement: engagement)
  }

  func loadComments() {
    DispatchQueue.main.async {
      self.showHUD(kLoadingPost)
    }
    guard let post = topic?.id else { return }
    retrieveComments(forPost: post, completion: { (egmts, error) in
      DispatchQueue.main.async {
        self.dismissHUD()
      }
      if let _ = error {
        self.showHUD(kGenericError)
      } else {
        engagements = egmts
        self.topicDetailTable.reloadData()
      }
    })
  }

  private func retrieveComments(forPost post: String, completion: @escaping (Engagements?, Error?) -> Void) {
    let params: [String: Any] = ["post": post]
    apiRepository.performRequest(path: Api.Endpoint.getCommentsForPost, method: .post, parameters: params) { (response, error) in
      guard error == nil else {
        print("There was an error at the api.")
        return completion(nil, error)
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return completion(nil, DadHiveError.jsonResponseError as? Error)
      }

      guard let data = res["data"] as? [String: Any], let engagements = Engagements(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return completion(nil, DadHiveError.jsonResponseError as? Error)
      }

      completion(engagements, nil)
    }
  }

  func set(post: Post) {
    topic = post
  }

  @objc func viewMore() {
    let actionSheet = UIAlertController(title: "More actions", message: nil, preferredStyle: .actionSheet)
    let reportAction = UIAlertAction(title: "Report Inappropriate Activity", style: .default) { action in
      actionSheet.dismissHUD()
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
      actionSheet.dismissHUD()
    }

    actionSheet.addAction(reportAction)
    actionSheet.addAction(cancelAction)
    present(actionSheet, animated: true, completion: nil)
  }

  @IBAction func sendMessage(_ sender: UIButton) {
    guard let currentuser = CurrentUser.shared.user else { return }

    guard messageTextView.text.isEmpty == false, messageTextView.text != "Say something..." else {
      self.showHUD("You forgot something.")
      return
    }

    guard let post = topic, let topicid = post.id, let owner = post.owner?[0], let ownerId = owner.uid else {
      self.showHUD("You forgot something.")
      return
    }

    DispatchQueue.main.async {
      self.showHUD(kGenericSaving)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": EngagementType.comment.rawValue,
      "post": topicid,
      "ownerId": ownerId,
      "comment": messageTextView.text!
    ]
    apiRepository.performRequest(path: Api.Endpoint.addEngagement, method: .post, parameters: params) { (response, error) in

      DispatchQueue.main.async {
        self.dismissHUD()
      }

      guard error == nil else {
        print("There was an error at the api.")
        return self.showHUD(kGenericError)
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return self.showHUD(kGenericError)
      }

      guard let data = res["data"] as? [String: Any], let _ = Engagement(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return self.showHUD(kGenericError)
      }

      DispatchQueue.main.async {
        self.messageTextView.text = "Say something..."
      }
      self.loadComments()

    }
  }
}

// MARK: - UITextViewDelegate
extension TopicDetailVC: UITextViewDelegate {

  func textViewDidEndEditing(_ textView: UITextView) {
    handleTextViewValues(textView)
  }

  func handleTextViewValues(_ textView: UITextView) {
    guard textView.text.isEmpty == false, messageTextView.text != "Say something..." else {
      textView.text = ""
      return
    }
    message = textView.text
  }
}


extension TopicDetailVC: UITableViewDelegate, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return 1
    case 2: return 1
    case 3: return 1
    case 4: return engagementCount
    default: return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: TopicDescriptionCell.identifier) as? TopicDescriptionCell, let tpc = topic else { return UITableViewCell() }
      let model = configureTopicCellModel(tpc)
      cell.configure(topics: model)
      return cell
    case 1:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: TopicActivityCell.identifier) as? TopicActivityCell, let tpc = topic else { return UITableViewCell() }
      let model = configureTopicCellModel(tpc)
      cell.configure(topics: model)
      return cell
    case 2:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: BannerCell.identifier) as? BannerCell else { return UITableViewCell() }
      cell.configure()
      return cell
    case 3:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.identifier) as? HeaderCell else { return UITableViewCell() }
      let headerText = engagementCount == 1 ? "\(engagementCount) Answer" : "\(engagementCount) Answers"
      cell.configure(withHeader: headerText)
      return cell
    case 4:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: TopicReplyCell.identifier) as? TopicReplyCell, let engagements = engagements?.engagements else { return UITableViewCell() }
      let engagement = engagements[indexPath.row]
      let model = configureEngagementCellModel(engagement)
      cell.configure(topics: model)
      return cell
    default: return UITableViewCell()
    }
  }
}

extension TopicDetailVC: TopicsCellDelegate {
  
  func didUpvote(_ cell: UITableViewCell, engagement: Engagement) {
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let c = cell as? TopicReplyCell, let topicid = engagement.id, let owner = engagement.owner?[0], let ownerId = owner.uid  else { return }

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
      engagement.numberOfUpvotes? += 1
      c.updateUpvoteCount()
    }
  }

  func didDownvote(_ cell: UITableViewCell, engagement: Engagement) {

    guard let currentuser = CurrentUser.shared.user else { return }

    guard let c = cell as? TopicReplyCell, let topicid = engagement.id, let owner = engagement.owner?[0], let ownerId = owner.uid  else { return }

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

      engagement.numberOfDownvotes? += 1

    }
  }

  func didUpvote(_ cell: UITableViewCell, topic: Post) {
    //    guard  let senderid = CurrentUser.shared.user?.id else { return }
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let c = cell as? TopicActivityCell, let topicid = topic.id, let owner = topic.owner?[0], let ownerId = owner.uid else { return }

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

      topic.numberOfUpvotes? += 1
      c.updateUpvoteCount()

    }
  }

  func didDownvote(_ cell: UITableViewCell, topic: Post) {
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let _ = cell as? TopicActivityCell, let topicid = topic.id, let owner = topic.owner?[0], let ownerId = owner.uid else { return }

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

      topic.numberOfDownvotes? += 1

    }
  }

  func didStar(_ cell: UITableViewCell, engagement: Engagement) {
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let c = cell as? TopicReplyCell, let topicid = engagement.id, let owner = engagement.owner?[0], let ownerId = owner.uid  else { return }

    DispatchQueue.main.async {
      self.showHUD(kGenericSaving)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": EngagementType.like.rawValue,
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
      engagement.numberOfLikes? += 1
      c.updateLikeCount()
      c.updateLikeImage()
    }
  }

  func didStar(_ cell: UITableViewCell, topic: Post) {
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let c = cell as? TopicActivityCell, let topicid = topic.id, let owner = topic.owner?[0], let ownerId = owner.uid else { return }

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

      topic.numberOfLikes? += 1
      c.updateLikeCount()
      c.updateLikeImage()
    }
  }
}
