import UIKit
import SVProgressHUD
import APESuperHUD
import Firebase

class UserProfileVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var tblMain: UITableView!
    @IBOutlet private var btnNext: UIButton!
    
    // MARK: - Properties
    fileprivate var count = 0
    fileprivate var users: Users?
    fileprivate var currentUser: User?
    fileprivate var apiRepository = APIRepository()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSuperHUD()
    }

    override func viewWillAppear(_ animated: Bool) {
        retrieveUsers()
    }

    // MARK: - Public member functions
    func setupUI() {
        btnNext.applyCornerRadius()
        
        tblMain.delegate = self
        tblMain.dataSource = self
        
        tblMain.register(UINib(nibName: "DHIntroCell", bundle: nil), forCellReuseIdentifier: "DHIntroCell")
        tblMain.register(UINib(nibName: "DHImageCell", bundle: nil), forCellReuseIdentifier: "DHImageCell")
        tblMain.register(UINib(nibName: "DHPrimaryInfoCell", bundle: nil), forCellReuseIdentifier: "DHPrimaryInfoCell")
        tblMain.register(UINib(nibName: "DHKidsInfoCell", bundle: nil), forCellReuseIdentifier: "DHKidsInfoCell")
        tblMain.register(UINib(nibName: "DHQuestionCell", bundle: nil), forCellReuseIdentifier: "DHQuestionCell")
        
        retrieveUsers()
    }
    
    func retrieveUsers() {
        showHUD("Finding Users", withDuration: 30.0)
        loadUsers { (error, results) in
            self.dismissHUD()
            if let err = error {
                print(err.localizedDescription)
                self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
                self.tblMain.reloadData()
            } else {
                if
                    let res = results,
                    let objs = results?.users,
                    let firstUser = objs.first
                {
                    if let usersArray = self.users?.users, usersArray.count > 0 {
                        for user in objs {
                            if usersArray.contains(where: { (i) -> Bool in
                                return i.uid! == user.uid!
                            }) {
                                print("Not adding new user.")
                            } else {
                                print("Adding new user")
                                self.users!.users!.append(user)
                            }
                        }
                    } else {
                        self.users = res
                        self.load(user: firstUser)
                    }
                } else {                    self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
                    self.tblMain.reloadData()
                }
            }
        }
    }

    func load(user: User) {
        self.currentUser = user
        DefaultsManager().setDefault(withData: user.uid ?? "", forKey: kLastUser)
        tblMain.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func goToNext(_ sender: UIButton) {
        goToNextUser()
    }
}

extension UserProfileVC {
    func loadUsers(_ completion: @escaping(Error?, Users?) -> Void) {
        guard let currentUser = CurrentUser.shared.user else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
            return
        }
        if
            let userId = currentUser.uid,
            let lat = currentUser.settings?.location?.addressLat,
            let long = currentUser.settings?.location?.addressLong,
            let radius = currentUser.settings?.maxDistance,
            let pageNo = (currentUser.currentPage != nil) ? currentUser.currentPage : 1,
            let lastId = (currentUser.lastId != nil) ? currentUser.lastId : ""
        {
            let parameters: [String: Any] = [
                "userId": userId,
                "latitude": Double(lat),
                "longitude": Double(long),
                "maxDistance": Double(radius),
                "pageNo": pageNo,
                "lastId": lastId,
                "ageRangeId": currentUser.settings?.ageRange?.id ?? 0,
                "perPage": 1
            ]
            self.apiRepository.performRequest(path: Api.Endpoint.getNearbyUsers, method: .post, parameters: parameters) { (response, error) in
                guard error == nil else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                
                guard let res = response as? [String: Any] else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                
                guard let data = res["data"] as? [String: Any] else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                
                guard let usersData = Users(JSON: data) else {
                    return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
                }
                completion(nil, usersData)
            }
        }
    }
    
    func like(user: User, completion: @escaping (Bool, User?)->Void) {
        guard let senderId = CurrentUser.shared.user?.uid, let recipientId = user.uid else {
            completion(false, nil)
            return
        }
        
        //  MARK:- Create match object
        let parameters: [String: String] = [
            "senderId": senderId,
            "recipientId": recipientId
        ]
        self.apiRepository.performRequest(path: Api.Endpoint.createMatch, method: .post, parameters: parameters) { (response, error) in
            guard error == nil else {
                print("There was an error at the api.")
                return completion(false, nil)
            }
            
            guard let res = response as? [String: Any] else {
                print("Response was unable to be retrieved.")
                return completion(false, nil)
            }
            
            guard let data = res["data"] as? [String: Any] else {
                print("Data attribute does not exist for the response.")
                return completion(false, nil)
            }
            
            if let userData = Users(JSON: data), let users = userData.users, users.count > 0 {
                print("Match exists")
                completion(true, users[0])
            } else {
                print("Match does not exist yet. Continue")
                completion(true, nil)
            }
        }
    }
    
    func goToNextUser() {
        guard let currentUser = CurrentUser.shared.user else {
            print("User is no longer signed in. Sign them out.")
            FIRAuthentication.signout()
            return
        }
        
        if let lastId = self.users?.users?[count].docId {
            currentUser.updateLastId(lastId)
        }
        
        guard currentUser.canSwipe == true else {
            print("No more swiping. Please purchase a new plan.")
            self.showErrorAlert(DadHiveError.maximumSwipesReached)
            return
        }
        
        guard let users = self.users?.users else {
            print("No users object(s). Please purchase a new plan.")
            self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
            return
        }
        
        guard count < (users.count - 1) else {
            print("No more users.")
            self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
            return
        }
        
        guard count < currentUser.maxSwipes else {
            print("No more swiping. Please purchase a new plan.")
            CurrentUser.shared.user?.disableSwiping()
            self.showErrorAlert(DadHiveError.maximumSwipesReached)
            return
        }
        
        count += 1
        load(user: users[count])
        
    }
}

// MARK: - SwipingDelegate
extension UserProfileVC: SwipingDelegate {
    func didLike(user: User) {
        showHUD("Liking User", withDuration: 30.0)
        like(user: user) { (success, user) in
            self.dismissHUD()
            if (success) {
                if let user = user {
                    let matchVC = MatchVC(user: user)
                    self.present(matchVC, animated: true, completion: nil)
                } else {
                    self.goToNextUser()
                }
            } else {
                self.showError("There was an error matching with the user. Please try again.")
            }
        }
    }
    
    func didNotLike() {
        goToNextUser()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension UserProfileVC: UITableViewDelegate, UITableViewDataSource {
    func totalRowCount() -> Int {
        return 5
    }
    
    func configureCell(forTable tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        guard let user = self.currentUser else { return emptyCell }
        
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
