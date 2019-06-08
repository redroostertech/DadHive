import UIKit
import SDWebImage
import SVProgressHUD
import APESuperHUD

class ViewProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblMain: UITableView!
    @IBOutlet weak var btnBack: UIButton!

    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSuperHUD()
        self.load(user: user!)
    }

    func load(user: User) {
        DefaultsManager().setDefault(withData: user.uid ?? "", forKey: kLastUser)
        tblMain.reloadData()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func totalRowCount() -> Int {
        return 5
    }

    func configureCell(forTable tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {

        guard let user = self.user else { return emptyCell }

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHIntroCell") as! DHIntroCell
            cell.loadUser = user
            return cell
        }

        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHImageCell") as! DHImageCell
            cell.delegate = self
            cell.loadUser = user
            if user.imageSectionOne.count > 0 {
                cell.mediaArray = user.imageSectionOne
            }
            cell.hideCheckButton()
            return cell
        }

        // Handle Section 1
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHPrimaryInfoCell") as! DHPrimaryInfoCell
            cell.loadUser = user
            return cell
        }

        if user.imageSectionTwo.count > 0 {
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHImageCell") as! DHImageCell
                cell.delegate = self
                cell.loadUser = user
                cell.mediaArray = user.imageSectionTwo
                cell.hideCheckButton()
                return cell
            }

            // Handle Section 2
            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHKidsInfoCell") as! DHKidsInfoCell
                cell.loadUser = user
                return cell
            }
        } else {
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHKidsInfoCell") as! DHKidsInfoCell
                cell.loadUser = user
                return cell
            }
        }
        return emptyCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRowCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(forTable: tableView, atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension ViewProfileVC {
    func setupUI() {

        tblMain.delegate = self
        tblMain.dataSource = self

        tblMain.register(UINib(nibName: "DHIntroCell", bundle: nil), forCellReuseIdentifier: "DHIntroCell")
        tblMain.register(UINib(nibName: "DHImageCell", bundle: nil), forCellReuseIdentifier: "DHImageCell")
        tblMain.register(UINib(nibName: "DHPrimaryInfoCell", bundle: nil), forCellReuseIdentifier: "DHPrimaryInfoCell")
        tblMain.register(UINib(nibName: "DHKidsInfoCell", bundle: nil), forCellReuseIdentifier: "DHKidsInfoCell")
        tblMain.register(UINib(nibName: "DHQuestionCell", bundle: nil), forCellReuseIdentifier: "DHQuestionCell")
    }
}

extension ViewProfileVC: SwipingDelegate {
    func didLike(user: User) {
        print("Do nothing.")
    }

    func didNotLike() {
        print("Do nothing")
    }
}
