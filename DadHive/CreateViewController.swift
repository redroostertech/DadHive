//
//  CreateViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/20/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

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

  @IBOutlet private weak var categoriesCollection: UICollectionView!
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
    categoriesCollection.setCollectionViewLayout(layout, animated: true)
    categoriesCollection.delegate = self
    categoriesCollection.dataSource = self
    categoriesCollection.register(CategoryCell.nib, forCellWithReuseIdentifier: CategoryCell.identifier)
  }

  func loadCategories() {
    retrieveCategories { (cats, error) in
      if let _ = error {
        self.showHUD(kGenericError)
      } else {
        categories = cats
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

extension CreateViewController: UICollectionViewDelegate, UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return categoriesCount
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell, let categories = categories?.categories else { return UICollectionViewCell() }
    let category = categories[indexPath.row]
    cell.configure(category: category)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let categories = categories?.categories, let selectedCell = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return }

    let category = categories[indexPath.row]

    currentSelection?.showSelectionIndicator = false
    currentSelection = selectedCell

    selectedCell.showSelectionIndicator = true

    for unselectedCell in collectionView.visibleCells {
      guard let unselectedcell = unselectedCell as? CategoryCell else { return }
      if unselectedcell != selectedCell {
        unselectedcell.showSelectionIndicator = false
      }
    }

    selectedCategory = category
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
