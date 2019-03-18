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
    @IBOutlet weak var lblMessage: ValueLabel!
}

class ReceiverCell: UITableViewCell {
    @IBOutlet weak var lblMessage: ValueLabel!
}

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var btnSend: DHButton!
    @IBOutlet weak var lblUserName: TitleLabel!

    var conversation: Conversation?
    var messagesToDisplay = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tblMain.delegate = self
        tblMain.dataSource = self
        showHUD()
        lblUserName.text = conversation?.trueRecipient?.name?.fullName ?? ""
    }

    override func viewWillAppear(_ animated: Bool) {
        getMessages(conversationId: self.conversation?.id as? String ?? "")
    }

    func getMessages(conversationId id: String) {
        let parameters: [String: Any] = [
            "conversationId": id,
            ]
        APIRepository().performRequest(path: Api.Endpoint.getMessages, method: .post, parameters: parameters) { (response, error) in
            if error != nil {
                print(error)
                //completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                self.tblMain.reloadData()
                self.scrollToBottom(of: self.tblMain, completion: {
                    self.dismissHUD()
                })
            } else {
                if let res = response as? [String: Any], let data = res["data"] as? [String: Any], let messagesData = Messages(JSON: data)?.messages {
                    self.messagesToDisplay = messagesData
                    self.tblMain.reloadData()
                    self.scrollToBottom(of: self.tblMain, completion: {
                        self.dismissHUD()
                    })
                } else {
                    //completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    self.tblMain.reloadData()
                    self.scrollToBottom(of: self.tblMain, completion: {
                        self.dismissHUD()
                    })
                }
            }
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
        let parameters: [String: Any] = [
            "conversationKey": self.conversation?.key ?? "",
            "conversationId": self.conversation?.id ?? "",
            "message": txtField.text!,
            "senderId": CurrentUser.shared.user?.uid ?? "",
        ]
        APIRepository().performRequest(path: Api.Endpoint.sendMessage, method: .post, parameters: parameters) { (response, error) in
            if error != nil {
                print(error)
                //completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                self.scrollToBottom(of: self.tblMain, completion: {
                    print("Done")
                })
            } else {
                if let res = response as? [String: Any], let data = res["data"] as? [String: Any], let success = Success(JSON: data)?.result, success == true {
                    self.scrollToBottom(of: self.tblMain, completion: {
                        print("Done")
                        self.txtField.text = ""
                    })
                } else {
                    //completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    self.scrollToBottom(of: self.tblMain, completion: {
                        print("Done")
                    })
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

    func showHUD(_ text: String = "Finding Users") {
        APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: 4.0), title: nil, message: text, completion: nil)
    }

    func dismissHUD() {
        APESuperHUD.dismissAll(animated: true)
    }
}
