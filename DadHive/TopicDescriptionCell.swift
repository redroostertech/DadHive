//
//  TopicDescriptionCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/17/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class TopicDescriptionCell: UITableViewCell {

  @IBOutlet private weak var descriptionLabel: UILabel!

  private var cellModel: TopicsCellModel? {
    didSet {
      guard let cellmodel = self.cellModel else { return }
      topic = cellmodel.topic
    }
  }

  private var topicWrapper: PostWrapper? {
    didSet {
      guard let topicwrapper = self.topicWrapper else { return }
      topic = topicwrapper.post
    }
  }

  private var topic: Post? {
    didSet {
      guard let topic = self.topic else { return }
      topicText = topic.description
    }
  }

  private var topicText: String? {
    didSet {
      guard let topictext = self.topicText else { return }
      descriptionLabel.text = topictext
    }
  }

  func configure(topics: TopicsCellModel) {
    cellModel = topics
  }

}
