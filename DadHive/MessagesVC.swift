//
//  MessagesVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import APESuperHUD

class ConversationCell: UITableViewCell {
    @IBOutlet var imgvwRecipient: UIImageView!
    @IBOutlet var lblRecipientName: TitleLabel!
    @IBOutlet var lblLastMessage: ChatMessageLabel!
    @IBOutlet var lblMessageSentDate: UILabel!

    override func awakeFromNib() {
        imgvwRecipient.applyClipsToBounds(true)
        imgvwRecipient.makeAspectFill()
        lblRecipientName.makeOneLine()
        lblLastMessage.makeOneLine()
        lblMessageSentDate.makeOneLine()
    }
}

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblMain: UITableView!
    
    var conversations = [Conversation]()

    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "No Data"
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupSuperHUD()

        tblMain.delegate = self
        tblMain.dataSource = self

        showHUD()
    }

    override func viewWillAppear(_ animated: Bool) {
        conversations.removeAll()
        getConversations {
            self.tblMain.reloadData()
            APESuperHUD.removeHUD(animated: true, presentingView: self.view, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(forTable: tableView, atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = self.conversations[indexPath.row]
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.conversation = conversation
        self.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
    }

    func configureCell(forTable tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell") as! ConversationCell
        let item = conversations[indexPath.row]
        cell.lblLastMessage.text = item.lastMessage?.message as? String ?? "Empty"
        cell.lblRecipientName.text = item.otherUser?.name?.userFullName ?? "Empty"
        cell.lblMessageSentDate.text = item.lastMessage?.date ?? "ago"
        return cell
    }

    func getConversations(_ completion: @escaping () -> Void) {
        var queue = 0
        DispatchQueue.main.async {
            FIRRepository.shared.db.retrieveDataOnce(atChild: kConversation, whereKey: "senderId", isEqualTo: CurrentUser.shared.user!.userId) {
                (success, data, error) in
                if error != nil {
                    print("getConversations() | Sender Error " + String(describing: error?.localizedDescription))
                } else {
                    print("getConversations() | Sender success")
                    guard let data = data else { return }
                    print(data)
                    for i in data.children {
                        if
                            let snapshot = (i as? DataSnapshot),
                            var rawConversation = snapshot.value as? [String : Any] {
                            rawConversation["snapshotKey"] = String(describing: snapshot.key)
                            let conversation = Conversation(JSON: rawConversation)
                            self.conversations.append(conversation!)
                        }
                    }
                }
                queue += 1
                queuCheck()
            }
        }
        DispatchQueue.main.async {
            FIRRepository.shared.db.retrieveDataOnce(atChild: kConversation, whereKey: "recipientId", isEqualTo: CurrentUser.shared.user!.userId) {
                (success, data, error) in
                if error != nil {
                    print("getConversations() | Recipient Error " + String(describing: error?.localizedDescription))
                } else {
                    print("getConversations() | Recipient success")
                    guard let data = data else { return }
                    for i in data.children {
                        if
                            let snapshot = (i as? DataSnapshot),
                            var rawConversation = snapshot.value as? [String : Any] {
                            rawConversation["snapshotKey"] = String(describing: snapshot.key)
                            let conversation = Conversation(JSON: rawConversation)
                            self.conversations.append(conversation!)
                        }
                    }
                }
                queue += 1
                queuCheck()
            }
        }

        func queuCheck() {
            if queue == 2 {
                completion()
            }
        }
    }

    func setupSuperHUD() {
        APESuperHUD.appearance.cornerRadius = 10
        APESuperHUD.appearance.animateInTime = 1.0
        APESuperHUD.appearance.animateOutTime = 1.0
        APESuperHUD.appearance.backgroundBlurEffect = .light
        APESuperHUD.appearance.iconColor = UIColor.flatGreen
        APESuperHUD.appearance.textColor =  UIColor.flatGreen
        APESuperHUD.appearance.loadingActivityIndicatorColor = UIColor.flatGreen
        APESuperHUD.appearance.defaultDurationTime = 4.0
        APESuperHUD.appearance.cancelableOnTouch = true
        APESuperHUD.appearance.iconWidth = kIconSizeWidth
        APESuperHUD.appearance.iconHeight = kIconSizeHeight
        APESuperHUD.appearance.messageFontName = kFontBody
        APESuperHUD.appearance.titleFontName = kFontTitle
        APESuperHUD.appearance.titleFontSize = kFontSizeTitle
        APESuperHUD.appearance.messageFontSize = kFontSizeBody
    }

    func showHUD() {
        APESuperHUD.showOrUpdateHUD(icon: .info,
                                    message: "Loading Inbox",
                                    duration: 2000.0,
                                    particleEffectFileName: "FireFliesParticle",
                                    presentingView: self.view,
                                    completion: nil)
    }
}
