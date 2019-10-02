//
//  SearchViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/20/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

private var topics: Posts?
private var apiRepository = APIRepository()

class SearchViewController: UIViewController {

  @IBOutlet private weak var topicsTable: UITableView!
  @IBOutlet private weak var searchBar: UISearchBar!

  private var topicsCount: Int {
    return topics?.posts?.count ?? 0
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    DispatchQueue.main.async {
      self.navigationController?.navigationBar.tintColor = .white
      self.hideNavigationBarHairline()
      self.setupSuperHUD()
      self.clearNavigationBackButtonText()
    }

    setupTopicsTable()
    searchBar.delegate = self

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    searchBar.text = ""
    topics = nil
    topicsTable.reloadData()
  }

  private func setupTopicsTable() {
    topicsTable.delegate = self
    topicsTable.dataSource = self
    topicsTable.register(TopicsCell.nib, forCellReuseIdentifier: TopicsCell.identifier)
    topicsTable.emptyDataSetView { view in
      view.titleLabelString(NSAttributedString(string: "Search for Topics"))
        .detailLabelString(NSAttributedString(string: "Search for topics containing keywords"))
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

  func loadPosts(string: String? = nil) {

    guard let text = string else { return }

    DispatchQueue.main.async {
      self.showHUD(kLoadingPosts)
    }

    retrieveData(string: text) { (psts, error) in

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

  private func retrieveData(string: String, completion: @escaping (Posts?, Error?) -> Void) {
    guard let currentuser = CurrentUser.shared.user else { return }

    let params: [String: Any] = [
      "string": string,
      "senderId": currentuser.uid ?? "",
      "excludedIds": currentuser.actions?.excludedIDs ?? [String](),
    ]
    apiRepository.performRequest(path: Api.Endpoint.searchForPost, method: .post, parameters: params) { (response, error) in
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

extension SearchViewController: TopicsCellDelegate {
  func didUpvote(_ cell: UITableViewCell, topic: Post) {
    //    guard  let senderid = CurrentUser.shared.user?.id else { return }
    guard let currentuser = CurrentUser.shared.user else { return }

    guard let c = cell as? TopicsCell, let topicid = topic.id else { return }

    DispatchQueue.main.async {
      self.showHUD(kGenericSaving)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": EngagementType.upvote.rawValue,
      "post": topicid
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

    guard let _ = cell as? TopicsCell, let topicid = topic.id else { return }

    DispatchQueue.main.async {
      self.showHUD(kGenericSaving)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": EngagementType.downvote.rawValue,
      "post": topicid
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

extension SearchViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    loadPosts(string: searchBar.text)
    searchBar.resignFirstResponder()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
  }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
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
    let sb = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = sb.instantiateViewController(withIdentifier: "TopicDetailVC") as? TopicDetailVC else { return }
    vc.set(post: topic)
    pushToView(withViewController: vc)
  }
}
