import UIKit
import SVProgressHUD
import APESuperHUD
import FirebaseCore
import RRoostSDK

class UserProfileVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var tblMain: UITableView!
    @IBOutlet private var btnNext: UIButton!
    
    // MARK: - Properties
    fileprivate var count = 0
    fileprivate var usersToLike: Users?
    fileprivate var apiRepository = APIRepository()
    fileprivate var focusedUser: User? {
        didSet {
          guard let focuseduser = self.focusedUser, let uid = focuseduser.uid else {
            return tblMain.reloadData()
          }
          DefaultsManager().setDefault(withData: uid, forKey: kLastUser)
          tblMain.reloadData()
        }
    }
    private let bgThread = DispatchQueue(label: "dh_bg_thread", qos: .background, attributes: .concurrent, autoreleaseFrequency: .never, target: .global())

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSuperHUD()
    }

    override func viewWillAppear(_ animated: Bool) {
        getUsers()
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
        
        getUsers()
    }

    func load(user: User) {
      self.focusedUser = user
    }

    func emptyTable() {
      self.focusedUser = nil
    }

    func goToNextUser() {
      guard let currentUser = CurrentUser.shared.user else {
        print("User is no longer signed in. Sign them out.")
        FIRAuthentication.signout()
        return
      }

      guard currentUser.canSwipe == true else {
        print("No more swiping. Please purchase a new plan.")
        self.showErrorAlert(DadHiveError.maximumSwipesReached)
        self.emptyTable()
        return
      }

      guard let users = self.usersToLike?.users else {
        print("No users object(s). Please purchase a new plan.")
        self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
        self.emptyTable()
        return
      }

      guard count < (users.count - 1) else {
        print("No more users.")
        self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
        self.emptyTable()
        return
      }

      guard count < currentUser.maxSwipes else {
        print("No more swiping. Please purchase a new plan.")
        CurrentUser.shared.user?.disableSwiping()
        self.showErrorAlert(DadHiveError.maximumSwipesReached)
        self.emptyTable()
        return
      }

      count += 1
      load(user: users[count])

    }

    func getUsers() {
      showHUD("Finding Users", withDuration: 30.0)
      retrieveUsers { (error, results) in
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
            if let usersArray = self.usersToLike?.users, usersArray.count > 0 {
              for user in objs {
                if usersArray.contains(where: { (i) -> Bool in
                  return i.uid! == user.uid!
                }) {
                  print("Not adding new user.")
                } else {
                  print("Adding new user")
                  self.usersToLike!.users!.append(user)
                }
              }
            } else {
              self.usersToLike = res
              self.load(user: firstUser)
            }
          } else {                    self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
            self.tblMain.reloadData()
          }
        }
      }
    }

    // MARK: - Network member functions
    func like(user: User, completion: @escaping (Bool, Bool) -> Void) {
      dismissHUD()

      guard let senderId = CurrentUser.shared.user?.uid, let recipientId = user.uid else {
        completion(false, false)
        return
      }

      let parameters: [String: String] = [
        "senderId": senderId,
        "recipientId": recipientId
      ]

      self.apiRepository.performRequest(path: Api.Endpoint.createMatch, method: .post, parameters: parameters) { (response, error) in
        guard error == nil else {
          print("There was an error at the api.")
          return completion(false, false)
        }

        guard let res = response as? [String: Any] else {
          print("Response was unable to be retrieved.")
          return completion(false, false)
        }

        guard let data = res["data"] as? [String: Any], let match = Match(JSON: data), let matchexists = match.matchExists else {
          print("Data attribute does not exist for the response.")
          return completion(false, false)
        }

        completion(true, matchexists)
      }
    }

    func retrieveUsers(_ completion: @escaping(Error?, Users?) -> Void) {
      dismissHUD()
      guard let currentUser = CurrentUser.shared.user else {
        print("User is no longer signed in. Sign them out.")
        FIRAuthentication.signout()
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
        currentUser.actions?.excludedIDs.append(userId)
        currentUser.actions?.excludedIDs.append(lastId)

        let parameters: [String: Any] = [
          "userId": userId,
          "latitude": Double(lat),
          "longitude": Double(long),
          "maxDistance": Double(radius),
          "pageNo": pageNo,
          "lastId": lastId,
          "ageRangeId": currentUser.settings?.ageRange?.id ?? 0,
          "perPage": 1,
          "excludedIds": currentUser.actions?.excludedIDs ?? [String]()
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

    func createConversation(user: User, completion: @escaping (Bool) -> Void) {
      guard let senderId = CurrentUser.shared.user?.uid, let recipientId = user.uid else {
        completion(false)
        return
      }

      let parameters: [String: String] = [
        "senderId": senderId,
        "recipientId": recipientId
      ]

      self.apiRepository.performRequest(path: Api.Endpoint.createConversation, method: .post, parameters: parameters) { (response, error) in
        guard error == nil else {
          print("There was an error at the api.")
          return completion(false)
        }

        guard let res = response as? [String: Any] else {
          print("Response was unable to be retrieved.")
          return completion(false)
        }

        guard let data = res["data"] as? [String: Any], let conversation = Conversation(JSON: data) else {
          print("Data attribute does not exist for the response.")
          return completion(false)
        }

        completion(true)
      }
    }
    
    // MARK: - IBActions
    @IBAction func goToNext(_ sender: UIButton) {
        goToNextUser()
    }
}

// MARK: - SwipingDelegate
extension UserProfileVC: SwipingDelegate {
    func didLike(user: User) {
        guard let currentUser = CurrentUser.shared.user else {
            print("User is no longer signed in. Sign them out.")
            FIRAuthentication.signout()
            return
        }
        showHUD("Liking User", withDuration: 30.0)
        like(user: user) { (success, matchExists) in
            if (success) {
                if let lastid = user.uid {
                  self.bgThread.async {
                    currentUser.updateLastId(lastid)
                  }
                }

                if matchExists {
                    let matchVC = MatchVC(user: user)
                    matchVC.delegate = self
                    self.present(matchVC, animated: true, completion: { [weak self] in
                        guard let strongSelf = self else { return }

                        strongSelf.bgThread.async {
                          strongSelf.createConversation(user: user, completion: { (success) in
                            strongSelf.goToNextUser()
                          })
                        }
                    })
                } else {
                  self.goToNextUser()
                }

            } else {
                self.showError("There was an error matching with the user. Please try again.")
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension UserProfileVC: UITableViewDelegate, UITableViewDataSource {
    func totalRowCount() -> Int {
        return 5
    }
    
    func configureCell(forTable tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        guard let focuseduser = self.focusedUser else { return emptyCell }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHIntroCell") as! DHIntroCell
            cell.loadUser = focuseduser
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHImageCell") as! DHImageCell
            cell.delegate = self
            cell.loadUser = focuseduser
            if focuseduser.imageSectionOne.count > 0 {
                cell.mediaArray = focuseduser.imageSectionOne
            }
            return cell
        }
        
        // Handle Section 1
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHPrimaryInfoCell") as! DHPrimaryInfoCell
            cell.loadUser = focuseduser
            return cell
        }
        
        if focuseduser.imageSectionTwo.count > 0 {
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHImageCell") as! DHImageCell
                cell.delegate = self
                cell.loadUser = focuseduser
                cell.mediaArray = focuseduser.imageSectionTwo
                return cell
            }
            
            // Handle Section 2
            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHKidsInfoCell") as! DHKidsInfoCell
                cell.loadUser = focuseduser
                return cell
            }
        } else {
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHKidsInfoCell") as! DHKidsInfoCell
                cell.loadUser = focuseduser
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

extension UserProfileVC: MatchVCDelegate {
  func goBack(_ viewController: UIViewController) {
    self.goToNextUser()
  }
}
