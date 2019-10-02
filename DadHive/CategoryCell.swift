//
//  CategoryCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/8/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK

public var DadHiveGreen: UIColor {
  return UIColor(red: 149/255, green: 207/255, blue: 125/255, alpha: 1.0)
}
class CategoryCell: UICollectionViewCell {

  @IBOutlet weak var mainContentView: UIView!
  @IBOutlet weak var categoryLabel: UILabel!

  private var category: Category? {
    didSet {
      guard let category = self.category else { return }
      categoryLabel.text = category.label
    }
  }

  public var showSelectionIndicator: Bool = false {
    didSet {
      mainContentView.backgroundColor = self.showSelectionIndicator ? DadHiveGreen : .white
      categoryLabel.textColor = self.showSelectionIndicator ? .white : .darkGray
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.applyCornerRadius()
    showSelectionIndicator = false
  }
  
  func configure(category: Category) {
    self.category = category
  }

}
