//
//  TopicActivityCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/17/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class TopicActivityCell: UITableViewCell {

  @IBOutlet private weak var votesCountLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var repliesCountLabel: UILabel!
  @IBOutlet private weak var userImageView: UIImageView!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var likeCountLabel: UILabel!
  @IBOutlet private weak var starImageView: UIImageView!

  private weak var delegate: TopicsCellDelegate?

  private var cellModel: TopicsCellModel? {
    didSet {
      guard let cellmodel = self.cellModel else { return }
      topic = cellmodel.topic
      user = cellmodel.topic.owner
      delegate = cellmodel.delegate
    }
  }

  private var topic: Post? {
    didSet {
      guard let topic = self.topic else { return }
      dateLabel.text = topic.createdAt
      user = topic.owner
      votesCount = topic.numberOfUpvotes
      commentsCount = topic.numberOfComments
      likesCount = topic.numberOfLikes
      myLike = topic.myLike
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

  private var commentsCount: Int? {
    didSet {
      guard let commentscount = self.commentsCount else {
        repliesCountLabel.text = "0 Replies"
        return
      }
      repliesCountLabel.text = "\(commentscount) Replies"
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
    userImageView.applyCornerRadius()
    likeCountLabel.isHidden = true
    starImageView.isHidden = true
    repliesCountLabel.isHidden = true
  }

  func configure(topics: TopicsCellModel) {
    cellModel = topics
  }

  func updateUpvoteCount() {
    self.votesCount? += 1
  }

  func updateCommentCount() {
    self.commentsCount? += 1
  }

  func updateLikeCount() {
    self.likesCount? += 1
  }

  func updateLikeImage() {
    self.starImageView.image = UIImage(named: "star-filled")
  }

  @IBAction func upvote(_ sender: UIButton) {
    guard let topic = self.topic else { return }
    delegate?.didUpvote(self, topic: topic)
  }

  @IBAction func downvote(_ sender: UIButton) {
    guard let topic = self.topic else { return }
    delegate?.didDownvote(self, topic: topic)
  }

  @IBAction func gotoProfile(_ sender: UIButton) {
    guard let user = self.user?[0] else { return }
    delegate?.viewProfile(self, user: user)
  }

  @IBAction func star(_ sender: UIButton) {
//    guard let topic = self.topic else { return }
//    delegate?.didStar(self, topic: topic)
  }
    
}
