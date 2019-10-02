//
//  TopicReplyCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/17/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class EngagementsCellModel {
  var engagement: Engagement
  var delegate: TopicsCellDelegate
  required init(delegate: TopicsCellDelegate, engagement: Engagement) {
    self.engagement = engagement
    self.delegate = delegate
  }
}

class TopicReplyCell: UITableViewCell {

  @IBOutlet private weak var votesCountLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var userImageView: UIImageView!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var topicMessageLabel: UILabel!
  @IBOutlet private weak var likeCountLabel: UILabel!
  @IBOutlet private weak var starImageView: UIImageView!

  private weak var delegate: TopicsCellDelegate?

  private var cellModel: EngagementsCellModel? {
    didSet {
      guard let cellmodel = self.cellModel else { return }
      engagement = cellmodel.engagement
      user = cellmodel.engagement.owner
      delegate = cellmodel.delegate
    }
  }

  private var engagement: Engagement? {
    didSet {
      guard let topic = self.engagement else { return }
      dateLabel.text = topic.createdAt
      engagementText = topic.comment
      user = topic.owner
      votesCount = topic.numberOfUpvotes
      likesCount = topic.numberOfLikes
      myLike = topic.myLike
    }
  }

  private var engagementText: String? {
    didSet {
      guard let topictext = self.engagementText else { return }
      topicMessageLabel.text = topictext
    }
  }

  private var user: [User]? {
    didSet {
      guard let user = self.user?[0] else { return }
      userName = user.name?.fullName
      userImage = user.media?.first(where: { (media) -> Bool in
        guard let order = media.order else { return false }
        return order == 1
      })?.url
    }
  }

  private var userName: String? {
    didSet {
      guard let username = self.userName else { return }
      userNameLabel.text = username
    }
  }

  private var userImage: URL? {
    didSet {
      guard let userimage = self.userImage else { return }
      userImageView.imageFromUrl(theUrl: userimage.absoluteString)
    }
  }

  private var votesCount: Int? {
    didSet {
      guard let votescount = self.votesCount else {
        votesCountLabel.text = "0"
        return
      }
      votesCountLabel.text = "\(String(describing: votescount))"
    }
  }

  private var likesCount: Int? {
    didSet {
      guard let likescount = self.likesCount else {
        likeCountLabel.text = "0"
        return
      }
      likeCountLabel.text = "\(String(describing: likescount))"
    }
  }

  private var myLike: Int? {
    didSet {
      guard let mylike = self.myLike, mylike > 0 else { return }
      updateLikeImage()
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.backgroundColor = .clear
    userImageView.applyCornerRadius()
    starImageView.isHidden = true
    likeCountLabel.isHidden = true
  }

  func configure(topics: EngagementsCellModel) {
    cellModel = topics
  }

  func updateUpvoteCount() {
    self.votesCount? += 1
  }

  func updateLikeCount() {
    self.likesCount? += 1
  }

  func updateLikeImage() {
    self.starImageView.image = UIImage(named: "star-filled")
  }

  @IBAction func upvote(_ sender: UIButton) {
    guard let topic = self.engagement else { return }
    delegate?.didUpvote(self, engagement: topic)
  }

  @IBAction func downvote(_ sender: UIButton) {
    guard let topic = self.engagement else { return }
    delegate?.didDownvote(self, engagement: topic)
  }

  @IBAction func gotoProfile(_ sender: UIButton) {
    guard let user = self.user?[0] else { return }
    delegate?.viewProfile(self, user: user)
  }
  @IBAction func star(_ sender: UIButton) {
//    guard let topic = self.engagement else { return }
//    delegate?.didStar(self, engagement: topic)
  }
}
