//
//  CreateViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/20/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import HTagView

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
private var apiRepository = APIRepository()
private var selectedCategory: Category?
private var currentSelection: CategoryCell?

class CreateViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var categoriesCollection: HTagView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var lblSelectCategory: TitleLabel!

  private var categoriesCount: Int {
    return categories?.categories?.count ?? 0
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    textView.delegate = self
    lblSelectCategory.font = UIFont(name: kFontMenu, size: kFontSizeMenu)

    DispatchQueue.main.async {
      self.navigationController?.navigationBar.tintColor = .white
      self.hideNavigationBarHairline()
      self.setupSuperHUD()
    }

    setupCategoriesCollection()

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DispatchQueue.global(qos: .background).async {
      self.loadCategories()
    }
  }

  private func setupCategoriesCollection() {
    DispatchQueue.main.async {
      self.categoriesCollection.delegate = self
      self.categoriesCollection.dataSource = self
    }
  }

  func loadCategories() {
    retrieveCategories { (cats, error) in
      if let _ = error {
        self.showHUD(kGenericError)
      } else {
        guard let container = cats else { return }
        categories = container
        self.categoriesCollection.reloadData()
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

  @IBAction private func cancel(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction private func post(_ sender: UIButton) {

    guard let currentuser = CurrentUser.shared.user else { return }

    guard let selectedcategory = selectedCategory, let categoryId = selectedcategory.id, textView.text != "Start typing", textView.text != "" else {
      self.showHUD("You forgot something.")
      return
    }

    DispatchQueue.main.async {
      self.showHUD(kCreatingPost)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": "1",
      "description": textView.text!,
      "categories": [categoryId]
    ]
    apiRepository.performRequest(path: Api.Endpoint.addPost, method: .post, parameters: params) { (response, error) in

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

      guard let data = res["data"] as? [String: Any], let notifs = NotificationResponse(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return self.showHUD(kGenericError)
      }

      self.showHUD("Done")
      self.dismiss(animated: true, completion: nil)
    }
  }

}

extension CreateViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Start typing" {
      textView.text = ""
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "Start typing" || textView.text == "" {
      textView.text = ""
    }
  }
}

extension CreateViewController: HTagViewDelegate, HTagViewDataSource {
  // MARK: - HTagViewDataSource
  func numberOfTags(_ tagView: HTagView) -> Int {
    guard let cats = categories?.categories else { return 0 }
    return cats.count
  }

  func tagView(_ tagView: HTagView, titleOfTagAtIndex index: Int) -> String {
    guard let cats = categories?.categories else { return "" }
    let item = cats[index]
    return item.label ?? ""
  }

  func tagView(_ tagView: HTagView, tagTypeAtIndex index: Int) -> HTagType {
    return .select
    // return .cancel
  }

  func tagView(_ tagView: HTagView, tagWidthAtIndex index: Int) -> CGFloat {
    return .HTagAutoWidth
    // return 150
  }

  func tagView(_ tagView: HTagView, tagSelectionDidChange selectedIndices: [Int]) {
    guard let cats = categories?.categories, let selectedIndex = selectedIndices.first else { return }
    selectedCategory = cats[selectedIndex]
  }

  func tagView(_ tagView: HTagView, didReceiveNewFrame frame: CGRect) {
    if self.scrollView.contentSize != frame.size {
      self.scrollView.contentSize != frame.size
    }
  }
  
}
