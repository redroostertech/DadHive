//
//  ChatVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/30/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import APESuperHUD
import Firebase
import ChameleonFramework

class DHButton: UIButton {
    override func awakeFromNib() {
        self.titleLabel?.font = UIFont(name: kFontButton, size: kFontSizeButton)
        self.setTextColor(.flatBlack)
    }
}

class ChatMessageLabel: UILabel {
    override func awakeFromNib() {
        self.font = UIFont(name: kFontButton, size: kFontSizeButton)
        self.makeMultipleLines()
    }
}

class SenderCell: UITableViewCell {
    @IBOutlet var lblMessage: ValueLabel!
}

class ReceiverCell: UITableViewCell {
    @IBOutlet var lblMessage: ValueLabel!
}

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblMain: UITableView!
    @IBOutlet var txtField: UITextView!
    @IBOutlet var btnSend: DHButton!
    @IBOutlet var lblUserName: TitleLabel!

    var conversation: Conversation?
    var messagesToDisplay = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tblMain.delegate = self
        tblMain.dataSource = self
        showHUD()
        lblUserName.text = conversation?.otherUser?.name?.fullName ?? ""
        getMessages(conversationId: self.conversation?.id as? String ?? "")
    }

    func getMessages(conversationId id: String) {
        FIRRealtimeDB.shared.retrieveData(atChild: "messages", whereKey: "conversationId", isEqualTo: id) { (success, snapshot, error) in
            if error == nil {
                guard let data = snapshot else { return }
                self.messagesToDisplay.removeAll()
                for i in data.children {
                    if
                        let snapshot = (i as? DataSnapshot),
                        var rawMessage = snapshot.value as? [String : Any] {
                        rawMessage["snapshotKey"] = String(describing: snapshot.key)
                        let message = Message(JSON: rawMessage)
                        self.messagesToDisplay.append(message!)
                    }
                }
                self.tblMain.reloadData()
                self.scrollToBottom(of: self.tblMain, completion: {
                    //
                })
            } else {
                print(error)
            }
            APESuperHUD.removeHUD(animated: true, presentingView: self.view, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesToDisplay.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = messagesToDisplay[indexPath.row]
        if item.senderId as? String ?? "" == CurrentUser.shared.user?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell") as! SenderCell
            cell.lblMessage.text = item.message as? String ?? "No Message"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell") as! ReceiverCell
            cell.lblMessage.text = item.message as? String ?? "No Message"
            return cell
        }
    }

    @IBAction func close(_ sender: UIButton) {
        FIRRealtimeDB.shared.closeConnections()
        self.dismissViewController()
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        let message = [
            "conversationId": self.conversation?.id ?? "",
            "createdAt": Date().toString(format: CustomDateFormat.timeDate.rawValue),
            "id": Utilities.randomString(length: 25),
            "message": txtField.text,
            "senderId": CurrentUser.shared.user?.uid ?? "",
            "sender": [
                "email": CurrentUser.shared.user?.email ?? "",
                "name": [
                    "fullName": CurrentUser.shared.user?.name?.fullName ?? ""
                ]
            ]
        ] as [String: Any]
        FIRRealtimeDB.shared.add(data: message, atChild: "messages", completion: {
            (success, results, error) in
            if error == nil {
                let updateMessage = [
                    "createdAt": self.conversation?.createdAt as? String ?? "",
                    "id": self.conversation?.id as? String ?? "",
                    "recipient": [
                        "email": self.conversation?.recipient?.email as? String ?? "",
                        "name": [
                            "fullName": self.conversation?.recipient?.name?.fullName as? String ?? ""
                            ]
                    ],
                    "recipientId": self.conversation?.recipientId as? String ?? "",
                    "senderId": self.conversation?.senderId as? String ?? "",
                    "sender": [
                        "email": self.conversation?.sender?.email as? String ?? "",
                        "name": [
                            "fullName": self.conversation?.sender?.name?.fullName as? String ?? ""
                            ]
                        ],
                    "lastMessage" : message,
                    "updatedAt": Date().toString(format: CustomDateFormat.timeDate.rawValue)
                ] as [String: Any]
                FIRRealtimeDB.shared.update(withData: updateMessage, atChild: "conversations/\(self.conversation?.key as? String ?? "")", completion: {
                    (success, results, error) in
                    if error == nil {
                        self.scrollToBottom(of: self.tblMain, completion: {
                            print("Done")
                            self.txtField.text = ""
                        })
                    } else {
                        print(error)
                    }
                })
            } else {
                print(error)
            }
        })
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
