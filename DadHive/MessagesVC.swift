import UIKit
import Foundation
import APESuperHUD
import SDWebImage

class ConversationCell: UITableViewCell {
    @IBOutlet weak var imgvwRecipient: UIImageView!
    @IBOutlet weak var lblRecipientName: TitleLabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lblMessageSentDate: UILabel!

    var conversationWrapper: ConversationWrapper? {
        didSet {
            guard let conversationwrapper = self.conversationWrapper, let conversation = conversationwrapper.conversation, let participants = conversationwrapper.participants else { return }
          self.lblRecipientName.text = conversationwrapper.getChatParticipants()

            self.lblLastMessage.text = conversation.lastMessageText ?? "No message."
            self.lblMessageSentDate.text = conversation.conversationDate?.toString()
//            self.imgvwRecipient.sd_setImage(with: conversation.trueRecipient?.imageSectionOne[0].url, placeholderImage: UIImage(named: "unknown")!, options: SDWebImageOptions.continueInBackground, completed: nil)
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

class MessagesVC: UIViewController {

  // MARK: - IBOutlets
    @IBOutlet private weak var tblMain: UITableView!
    @IBOutlet private var btnRefresh: UIButton!

  // MARK: - Public properties
    var conversationWrappers = [ConversationWrapper]()

  // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupSuperHUD()

        tblMain.delegate = self
        tblMain.dataSource = self

        showHUD("Loading Messages")
        getConversations {
            self.tblMain.reloadData()
            APESuperHUD.dismissAll(animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
    }

  // MARK: - Public member methods
    func getConversations(_ completion: @escaping () -> Void) {
      guard let currentuser = CurrentUser.shared.user else { return }
        conversationWrappers.removeAll()
        let parameters: [String: Any] = [
            "userId": currentuser.uid ?? "",
        ]
        APIRepository().performRequest(path: Api.Endpoint.findConversations, method: .post, parameters: parameters) { (response, error) in
            if let err = error {
                print(err.localizedDescription)
                self.showError("There was an error loading conversations. Please try again later.")
                completion()
            } else {
                if
                  let res = response as? [String: Any],
                  let data = res["data"] as? [String: Any],
                  let conversationResponse = Conversations(JSON: data),
                  let conversationWrappers = conversationResponse.conversationWrappers {
                    self.conversationWrappers = conversationWrappers
                    completion()
                } else {
                    self.showError("There was an error loading conversations. Please try again later.")
                    completion()
                }
            }
        }
    }

  // MARK: - IBActions
    @IBAction func refresh(_ sender: UIButton) {
        showHUD()
        getConversations {
            self.tblMain.reloadData()
            APESuperHUD.dismissAll(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MessagesVC: UITableViewDelegate, UITableViewDataSource {
  func configureCell(forTable tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell") as! ConversationCell
    let item = conversationWrappers[indexPath.row]
    cell.conversationWrapper = item
    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversationWrappers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return configureCell(forTable: tableView, atIndexPath: indexPath)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let conversationWrapper = self.conversationWrappers[indexPath.row]
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let vc = sb.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
    vc.conversationWrapper = conversationWrapper
    self.modalPresentationStyle = .overCurrentContext
    self.present(vc, animated: true, completion: nil)
  }
}
