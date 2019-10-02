import UIKit
import SDWebImage
import RRoostSDK

class SettingsVC: UITableViewController {

    @IBOutlet weak var btnProfilePicture: UIButton!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var lblPreferences: UILabel!
    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblMyPosts: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
        loadUI()
      
      self.tableView.cellForRow(at: IndexPath(row: 3, section: 0))?.isHidden = true
      self.tableView.cellForRow(at: IndexPath(row: 3, section: 0))?.frame.size.height = .zero
    }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    CurrentUser.shared.refresh {
      self.loadUI()
    }
  }
    
    func loadUI() {
        lblFullname.font = UIFont(name: kFontBody, size: kFontSizeBody)
        lblFullname.text = CurrentUser.shared.user?.name?.fullName ?? ""
        lblPreferences.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        lblAccount.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        lblMyPosts.font = UIFont(name: kFontMenu, size: kFontSizeMenu)
        btnProfilePicture.applyCornerRadius()
        
        if let mediaArray = CurrentUser.shared.user?.media, mediaArray.count > 0 {
            let media = mediaArray[0]
            self.btnProfilePicture.imageView?.contentMode = .scaleAspectFill
            if media.url != nil {
                self.btnProfilePicture.sd_setImage(with: media.url, for: .normal, completed: nil)
            } else {
                self.btnProfilePicture.setImage(UIImage(named: "unknown"), for: .normal)
            }
        }
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
    }

    @IBAction func refreshProfile(_ sender: UIButton) {
        CurrentUser.shared.refresh {
            self.loadUI()
        }
    }
}
