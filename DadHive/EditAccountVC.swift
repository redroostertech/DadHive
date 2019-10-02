import UIKit
import RRoostSDK

class EditAccountVC: UIViewController {

    @IBOutlet weak var lblTitle: TitleLabel!
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var btnSave: UIButton!

    var userInfo: Info?
    var currentUser = CurrentUser.shared
    var type = 1

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.tintColor = .darkText
  }

    @IBAction func save(_ sender: UIButton) {
        let alert = UIAlertController(title: "Email Change", message: "You are about to change your email address on file. Are you sure", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            if self.txtField.text != "" {
                self.currentUser.user?.change(email: self.txtField.text, {
                    (error) in
                    if let err = error {
                        print(err)
                    } else {
                        DispatchQueue.main.async {
                            self.popViewController()
                        }
                    }
                })
            } else {
                self.showError("Please provide new email.")
            }
        }
        let no = UIAlertAction(title: "No", style: .default) { (action) in
            alert.dismissViewController()
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
}
