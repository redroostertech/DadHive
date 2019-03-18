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
import SDWebImage

class ConversationCell: UITableViewCell {
    @IBOutlet weak var imgvwRecipient: UIImageView!
    @IBOutlet weak var lblRecipientName: TitleLabel!
    @IBOutlet weak var lblLastMessage: ChatMessageLabel!
    @IBOutlet weak var lblMessageSentDate: UILabel!

    var conversation: Conversation? {
        didSet {
            guard let conversation = self.conversation else { return }
            self.lblRecipientName.text = conversation.trueRecipient?.name?.fullName
            self.lblLastMessage.text = conversation.lastMessage?.message
            self.lblMessageSentDate.text = conversation.date
            self.imgvwRecipient.sd_setImage(with: conversation.trueRecipient?.imageSectionOne[0].url, placeholderImage: UIImage(named: "unknown")!, options: SDWebImageOptions.continueInBackground, completed: nil)
        }
    }

    override func awakeFromNib() {
        imgvwRecipient.applyClipsToBounds(true)
        imgvwRecipient.makeAspectFill()
        lblRecipientName.makeOneLine()
        lblLastMessage.makeOneLine()
        lblMessageSentDate.makeOneLine()
    }
}

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet var btnRefresh: UIButton!

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
            APESuperHUD.dismissAll(animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(forTable: tableView, atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        cell.conversation = item
        return cell
    }

    func getConversations(_ completion: @escaping () -> Void) {
        let parameters: [String: Any] = [
            "senderId": CurrentUser.shared.user?.uid ?? "",
        ]
        APIRepository().performRequest(path: Api.Endpoint.findConversations, method: .post, parameters: parameters) { (response, error) in
            if error != nil {
                print(error)
                //completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                completion()
            } else {
                if let res = response as? [String: Any], let data = res["data"] as? [String: Any], let conversationsData = Conversations(JSON: data)?.conversations {
                    self.conversations = conversationsData
                    completion()
                } else {
                    //completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    completion()
                }
            }
        }
    }

    func setupSuperHUD() {
        HUDAppearance.cornerRadius = 10
        HUDAppearance.animateInTime = 1.0
        HUDAppearance.animateOutTime = 1.0
        HUDAppearance.iconColor = UIColor.flatGreen
        HUDAppearance.titleTextColor =  UIColor.flatGreen
        HUDAppearance.loadingActivityIndicatorColor = UIColor.flatGreen
        HUDAppearance.cancelableOnTouch = true
        HUDAppearance.iconSize = CGSize(width: kIconSizeWidth, height: kIconSizeHeight)
        HUDAppearance.messageFont = UIFont(name: kFontBody, size: kFontSizeBody) ?? UIFont.systemFont(ofSize: kFontSizeBody, weight: .regular)
        HUDAppearance.titleFont = UIFont(name: kFontTitle, size: kFontSizeTitle) ?? UIFont.systemFont(ofSize: kFontSizeTitle, weight: .bold)
        showHUD()
    }

    func showHUD() {
        APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: 4.0), title: nil, message: "Loading Inbox", completion: nil)
    }

    @IBAction func refresh(_ sender: UIButton) {
        showHUD()
        getConversations {
            self.tblMain.reloadData()
            APESuperHUD.dismissAll(animated: true)
        }
    }
}
