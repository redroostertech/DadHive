import UIKit
import APESuperHUD
import Firebase
import ChameleonFramework
import SDWebImage
import Foundation

class SenderCell: UITableViewCell {
    @IBOutlet weak var lblMessage: ValueLabel!
}

class ReceiverCell: UITableViewCell {
    @IBOutlet weak var lblMessage: ValueLabel!
}

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lblUserName: TitleLabel!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnProfilePic: UIButton!
    
    var conversationWrapper: ConversationWrapper?
    var messagesToDisplay = [Message]()
    var recipients = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let conversationwrapper = self.conversationWrapper, let conversation = conversationwrapper.conversation, let id = conversation.id else {
            self.showError("Conversation no longer exists. Please go back.")
            return
        }

        tblMain.delegate = self
        tblMain.dataSource = self

        showHUD()

        DispatchQueue.main.async {
          self.recipients = conversationwrapper.getRecipients()
          if let recipient = self.recipients.first {
            self.btnProfilePic.applyCornerRadius()
            self.btnProfilePic.sd_setImage(with: recipient.imageSectionOne[0].url, for: .normal, placeholderImage: UIImage(named: "unknown")!, options: .continueInBackground, completed: nil)
            self.lblUserName.text = recipient.name?.fullName ?? ""
          }
        }

        getMessages(conversationId: id)
    }

    func getMessages(conversationId id: String) {
        FIRRealtimeDB.shared.retrieveData(atChild: "messages", whereKey: "conversationId", isEqualTo: id) { (success, snapshot, error) in
            self.messagesToDisplay = [Message]()
            if let err = error {
                print(err.localizedDescription)
                self.showError("There was an error retrieving messages. Please try again later.")
                self.tblMain.reloadData()
                self.scrollToBottom(of: self.tblMain, completion: {
                    self.dismissHUD()
                })
            } else {
                guard let messages = snapshot else {
                    self.tblMain.reloadData()
                    self.scrollToBottom(of: self.tblMain, completion: {
                        self.dismissHUD()
                    })
                    return
                }
                for i in messages.children {
                    guard let snapshot = (i as? DataSnapshot), var messageData = snapshot.value as? [String : Any] else { return }
                    messageData["key"] = String(describing: snapshot.key)
                    let message = Message(JSON: messageData)
                    self.messagesToDisplay.append(message!)
                }
                self.tblMain.reloadData()
                self.scrollToBottom(of: self.tblMain, completion: {
                    self.txtField.text = ""
                    self.dismissHUD()
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesToDisplay.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = messagesToDisplay[indexPath.row]
        if item.senderId ?? "" == CurrentUser.shared.user?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell") as! SenderCell
            cell.lblMessage.text = item.message ?? "No Message"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell") as! ReceiverCell
            cell.lblMessage.text = item.message ?? "No Message"
            return cell
        }
    }

    @IBAction func close(_ sender: UIButton) {
        FIRRealtimeDB.shared.closeConnections()
        self.dismissViewController()
    }

    @IBAction func sendMessage(_ sender: UIButton) {
      guard let conversationwrapper = self.conversationWrapper, let conversation = conversationwrapper.conversation, let id = conversation.id else {
        self.showError("Conversation no longer exists. Please go back.")
        return
      }
        let parameters: [String: Any] = [
            "createdAt" : Date().toString(format: CustomDateFormat.timeDate.rawValue),
            "conversationId": id,
            "message": txtField.text!,
            "senderId": CurrentUser.shared.user?.uid ?? "",
        ]

        FIRRealtimeDB.shared.add(data: parameters, atChild: "messages", completion: {
            (success, results, error) in
            if let err = error {
                print(err.localizedDescription)
                self.showError("There was an error sending message. Please try again.")
            } else {
              print("Successful updating.")
            }
        })
    }

    func generateError(fromString string: String) -> Error {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : string ])
    }

    @IBAction func openSettings(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "More options", preferredStyle: .actionSheet)
        let unmatch = UIAlertAction(title: "Unmatch User", style: .default) { (action) in
          guard let currentuser = CurrentUser.shared.user else { return }
          let parameters: [String: Any] = [
            "senderId": currentuser.uid ?? "",
            "recipientId": self.recipients[0].uid ?? ""
          ]
          APIRepository().performRequest(path: Api.Endpoint.deleteMatch, method: .post, parameters: parameters) { (response, error) in
            if let err = error {
              print(err.localizedDescription)
              self.showError("There was an error unmatching user. Please try again later.")
              alert.dismissViewController()
            } else {
              if
                let res = response as? [String: Any],
                let data = res["success"] as? [String: Any],
                let success = Success(JSON: data),
                let result = success.result,
                (result) {
                alert.dismissViewController()
              } else {
                self.showError("There was an error unmatching user. Please try again later.")
                alert.dismissViewController()
              }
            }
          }
        }
        let reportUser = UIAlertAction(title: "Report User", style: .destructive) { (action) in
          guard let currentuser = CurrentUser.shared.user else { return }
          let parameters: [String: Any] = [
            "senderId": currentuser.uid ?? "",
            "senderEmail": currentuser.email ?? "",
            "reportingUserId": self.recipients[0].uid ?? "",
            "reportingUserEmail": self.recipients[0].email ?? ""
          ]
          APIRepository().performRequest(path: Api.Endpoint.reportUser, method: .post, parameters: parameters) { (response, error) in
            if let err = error {
              print(err.localizedDescription)
              self.showError("There was an error reporting user. Please try again later.")
              alert.dismissViewController()
            } else {
              if
                let res = response as? [String: Any],
                let data = res["success"] as? [String: Any],
                let success = Success(JSON: data),
                let result = success.result,
                (result) {
                alert.dismissViewController()
              } else {
                self.showError("There was an error reporting user. Please try again later.")
                alert.dismissViewController()
              }
            }
          }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismissViewController()
        }
        alert.addAction(unmatch)
        alert.addAction(reportUser)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func goToProfile(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToViewProfile", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "goToViewProfile", let vc = segue.destination as? ViewProfileVC {
            vc.user = self.recipients[0]
        }
    }
}
