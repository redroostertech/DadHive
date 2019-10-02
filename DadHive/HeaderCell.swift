//
//  HeaderCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/18/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {

  @IBOutlet private weak var headerLabel: UILabel!
  private var header: String? {
    didSet {
      guard let header = self.header else { return }
      headerLabel.text = header
    }
  }

  func configure(withHeader headerText: String) {
    header = headerText
  }
    
}
