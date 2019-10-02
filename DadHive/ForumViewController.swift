//
//  ForumViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/8/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK
import SVProgressHUD
import Sheeeeeeeeet

public enum EngagementType: Int {
  case like = 1
  case comment = 2
  case upvote = 3
  case downvote = 4
}

private var layout: UICollectionViewLayout {
  let layout = UICollectionViewFlowLayout()
  layout.scrollDirection = .horizontal
  layout.itemSize = CGSize(width: (kWidthOfScreen / 2) - 16,
                           height: 42)
  layout.minimumLineSpacing = 8.0
  layout.minimumInteritemSpacing = 8.0
  layout.sectionInset = UIEdgeInsets(top: 8,
                                     left: 8.0,
                                     bottom: 8.0,
                                     right: 8.0)
  return layout
}

private var categories: Categories?
private var topics: Posts?
private var apiRepository = APIRepository()
private var selectedCategory: Category?
private var currentSelection: CategoryCell?

class ForumViewController: UIViewController {

  @IBOutlet private weak var topicsTable: UITableView!
  @IBOutlet private weak var sortButton: UIBarButtonItem!

  private var categoriesCount: Int {
    return categories?.categories?.count ?? 0
  }

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

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DispatchQueue.global(qos: .background).async {
      self.loadCategories()
      self.loadPosts()
    }
  }

  private func setupTopicsTable() {
    topicsTable.delegate = self
    topicsTable.dataSource = self
    topicsTable.register(TopicsCell.nib, forCellReuseIdentifier: TopicsCell.identifier)
    topicsTable.emptyDataSetView { view in
      view.titleLabelString(NSAttributedString(string: "Welcome to DadHive"))
        .detailLabelString(NSAttributedString(string: "Currently, there are no topics. Be the first to share today!"))
        .image(UIImage(named: "dadhive-hive-sm"))
        .dataSetBackgroundColor(UIColor.white)
        .shouldDisplay(true)
        .shouldFadeIn(true)
        .isTouchAllowed(true)
        .isScrollAllowed(true)
        .verticalOffset(-40.0)
        .verticalSpace(24.0)
        .buttonTitle(NSAttributedString(string: "Share a Topic"), for: .normal)
        .didTapDataButton {
          self.performSegue(withIdentifier: "presentCreateTopic", sender: self)
      }
    }
  }

  func loadCategories() {
    retrieveCategories { (cats, error) in
      if let _ = error {
        self.showHUD(kGenericError)
      } else {
        if let allCategory = Category(JSON: ["label": "All"]) {
          cats?.categories?.insert(allCategory, at: 0)
        }
        categories = cats
      }
    }
  }

  private func retrieveCategories(completion: @escaping (Categories?, Error?) -> Void) {
    apiRepository.performRequest(path: Api.Endpoint.getCategories, method: .get, parameters: [:]) { (response, error) in
      guard error == nil else {
        print("There was an error at the api.")
        return completion(nil, error)
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return completion(nil, DadHiveError.jsonResponseError as? Error)
      }

      guard let data = res["data"] as? [String: Any], let categories = Categories(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return completion(nil, DadHiveError.jsonResponseError as? Error)
      }
      
      completion(categories, nil)
    }
  }

  func loadPosts(by category: String? = nil) {

    DispatchQueue.main.async {
      self.showHUD(kLoadingPosts)
    }

    if let cat = category {
      retrieveData(byCategory: cat) { (psts, error) in

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
    } else {
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
  }

  private func retrieveAllData(completion: @escaping (Posts?, Error?) -> Void) {
    guard let currentuser = CurrentUser.shared.user else { return }

    let params: [String: Any] = [
      "type": 1,
      "senderId": currentuser.uid ?? "",
      "excludedIds": currentuser.actions?.excludedIDs ?? [String]()
    ]
    apiRepository.performRequest(path: Api.Endpoint.getPosts, method: .post, parameters: params) { (response, error) in
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

  private func retrieveData(byCategory category: String, completion: @escaping (Posts?, Error?) -> Void) {
    guard let currentuser = CurrentUser.shared.user else { return }

    let params: [String: Any] = [
      "type": 1,
      "senderId": currentuser.uid ?? "",
      "excludedIds": currentuser.actions?.excludedIDs ?? [String](),
      "categories": [category]
    ]
    apiRepository.performRequest(path: Api.Endpoint.getPostsByCategory, method: .post, parameters: params) { (response, error) in
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

  @IBAction private func refresh(_ sender: UIButton) {
    guard let selectedcategory = selectedCategory else {
      loadPosts()
      return
    }
    loadPosts(by: selectedcategory.id)
  }

  @IBAction func showFilter(_ sender: UIButton) {
    var items = [ActionSheetItem]()

    let title = ActionSheetTitle(title: "Filter by")
    items.append(title)

    if let categories = categories?.categories {
      for category in categories {
        let item = ActionSheetSingleSelectItem(title: category.label ?? "", subtitle: nil, isSelected: false, group: "categories", value: category.id, tapBehavior: .none)
        items.append(item)
      }
    }

    let ok = ActionSheetOkButton(title: "Update")
    items.append(ok)

    let cancel = ActionSheetCancelButton(title: "Cancel")
    items.append(cancel)

    let sheet = ActionSheet(items: items) { sheet, item in
      guard item.isOkButton else { return }
      let categories = sheet.items.compactMap { $0 as? ActionSheetSingleSelectItem }
      if let selectedCat = categories.first(where: { $0.isSelected }), let catId = selectedCat.value as? String {
        self.loadPosts(by: catId)
      } else {
        sheet.dismiss()
      }
    }
    sheet.present(in: self, from: sortButton)
  }
}

extension ForumViewController: TopicsCellDelegate {
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

extension ForumViewController: UITableViewDelegate, UITableViewDataSource {
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

    GoogleAdMobManager.shared.showInterstitialAd(on: self)
    
    guard let vc = sb.instantiateViewController(withIdentifier: "TopicDetailVC") as? TopicDetailVC else { return }
    vc.set(post: topic)
    pushToView(withViewController: vc)
  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    guard let topics = topics?.posts else { return nil }
    let topic = topics[indexPath.row]

    let whitespace = whitespaceString(width: 100)

    let blockContent = UITableViewRowAction(style: .normal, title: whitespace) { action, index in
      let alertController = UIAlertController(title: "Block Content", message: "Performing this action will block this post from view. You will still see posts from that user.", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in

        guard let currentuser = CurrentUser.shared.user else { return }

        let parameters: [String: Any] = [
          "senderId": currentuser.uid ?? "",
          "objectId": topic.id ?? "",
        ]

        APIRepository().performRequest(path: Api.Endpoint.blockPost, method: .post, parameters: parameters) { (response, error) in
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
                self.loadPosts(by: selectedCategory?.id)
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
    let blockContentImage = customImageAction("block-post-red",
                                  forCell: tableView.cellForRow(at: indexPath))
    blockContent.backgroundColor = UIColor(patternImage: blockContentImage)

    let blockUser = UITableViewRowAction(style: .normal, title: whitespace) { action, index in
      let alertController = UIAlertController(title: "Block User", message: "Performing this action will block all posts from this user from your view.", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
        guard let currentuser = CurrentUser.shared.user else { return }

        let parameters: [String: Any] = [
          "senderId": currentuser.uid ?? "",
          "recipientId": topic.owner?[0].uid ?? "",
        ]

        APIRepository().performRequest(path: Api.Endpoint.blockUser, method: .post, parameters: parameters) { (response, error) in
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
                self.loadPosts(by: selectedCategory?.id)
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
    let blockUserImage = customImageAction("block-user-red",
                                              forCell: tableView.cellForRow(at: indexPath))
    blockUser.backgroundColor = UIColor(patternImage: blockUserImage)

    let reportContent = UITableViewRowAction(style: .normal, title: whitespace) { action, index in
      let alertController = UIAlertController(title: "Report Content", message: "You are about to report this post for review by our admin team.", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action in

        guard let currentuser = CurrentUser.shared.user else { return }

        let parameters: [String: Any] = [
          "senderId": currentuser.uid ?? "",
          "senderEmail": currentuser.email ?? "",
          "reportPostId": topic.id ?? "",
          "reportPostOwner": topic.owner?[0].uid ?? ""
        ]

        APIRepository().performRequest(path: Api.Endpoint.reportPost, method: .post, parameters: parameters) { (response, error) in
          if let err = error {
            print(err.localizedDescription)
            self.showError("There was an error reporting content. Please try again.")
            alertController.dismissViewController()
          } else {
            if
              let res = response as? [String: Any],
              let data = res["success"] as? [String: Any],
              let success = Success(JSON: data),
              let result = success.result,
              (result) {
              self.loadPosts(by: selectedCategory?.id)
              alertController.dismissViewController()
            } else {
              self.showError("There was an error reporting content. Please try again.")
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
    let reportContentImage = customImageAction("report-post",
                                           forCell: tableView.cellForRow(at: indexPath))
    reportContent.backgroundColor = UIColor(patternImage: reportContentImage)

    return [blockContent, blockUser, reportContent]
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

extension UIView {
  func image() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    guard let context = UIGraphicsGetCurrentContext() else {
      return UIImage()
    }
    layer.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
}
