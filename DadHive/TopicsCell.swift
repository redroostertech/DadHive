//
//  TopicsCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/11/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class TopicsCellModel {
  var topic: Post
  var delegate: TopicsCellDelegate
  required init(delegate: TopicsCellDelegate, topic: Post) {
    self.topic = topic
    self.delegate = delegate
  }
}

protocol TopicsCellDelegate: class {
  func viewProfile(_ cell: UITableViewCell, user: User)
  func didUpvote(_ cell: UITableViewCell, topic: Post)
  func didDownvote(_ cell: UITableViewCell, topic: Post)
  func didStar(_ cell: UITableViewCell, topic: Post)
  func didUpvote(_ cell: UITableViewCell, engagement: Engagement)
  func didDownvote(_ cell: UITableViewCell, engagement: Engagement)
  func didStar(_ cell: UITableViewCell, engagement: Engagement)
}

extension TopicsCellDelegate {
  func viewProfile(_ cell: UITableViewCell, user: User) { }
  func didUpvote(_ cell: UITableViewCell, topic: Post) { }
  func didDownvote(_ cell: UITableViewCell, topic: Post) { }
  func didStar(_ cell: UITableViewCell, topic: Post) { }
  func didUpvote(_ cell: UITableViewCell, engagement: Engagement) { }
  func didDownvote(_ cell: UITableViewCell, engagement: Engagement) { }
  func didStar(_ cell: UITableViewCell, engagement: Engagement) { }
}

class TopicsCell: UITableViewCell {

  @IBOutlet private weak var contentContainer: UIView!
  @IBOutlet private weak var votesCountLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var repliesCountLabel: UILabel!
  @IBOutlet private weak var userImageView: UIImageView!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var topicMessageLabel: UILabel!
  @IBOutlet private weak var likeCountLabel: UILabel!

  private weak var delegate: TopicsCellDelegate?

  private var cellModel: TopicsCellModel? {
    didSet {
      guard let cellmodel = self.cellModel else { return }
      topic = cellmodel.topic
      user = cellmodel.topic.owner
      delegate = cellmodel.delegate
    }
  }

  private var topicWrapper: PostWrapper? {
    didSet {
      guard let topicwrapper = self.topicWrapper else { return }
      votesCount = topicwrapper.numberOfLikes
      topic = topicwrapper.post
    }
  }

  private var topic: Post? {
    didSet {
      guard let topic = self.topic else { return }
      dateLabel.text = topic.createdAt
      topicText = topic.description
      user = topic.owner
      votesCount = topic.numberOfUpvotes
      commentsCount = topic.numberOfComments
      likesCount = topic.numberOfLikes
    }
  }

  private var topicText: String? {
    didSet {
      guard let topictext = self.topicText else { return }
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
        likeCountLabel.text = "0 Likes"
        return
      }
      likeCountLabel.text = "\(String(describing: likescount)) Likes"
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

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.backgroundColor = .clear
    userImageView.applyCornerRadius()
    contentContainer.applyCornerRadius(0.10)
  }

  func configure(topics: TopicsCellModel) {
    cellModel = topics
  }

  func updateUpvoteCount() {
    self.votesCount? += 1
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
}
