//
//  Main.swift
//  codewithmike
//
//  Created by Michael Westbrooks on 11/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD
import APESuperHUD
import Firebase

var count = 0

class UserProfileVC: UIViewController {

    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var btnNext: UIButton!

    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = ""
        return cell
    }

    var users: Users?
    var currentUser: User?
    var apiRepository = APIRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSuperHUD()
    }

    override func viewWillAppear(_ animated: Bool) {
        retrieveUsers()
    }

    func retrieveUsers() {
        showHUD("Finding Users", withDuration: 30.0)
        self.loadUsers { (error, results) in
            self.dismissHUD()
            if error == nil, let res = results, let objs = results?.users, let firstUser = objs.first {
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
            } else {
                print(error?.localizedDescription)
                self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
                self.tblMain.reloadData()
            }
        }
    }

    func load(user: User) {
        self.currentUser = user
        DefaultsManager().setDefault(withData: user.uid ?? "", forKey: kLastUser)
        tblMain.reloadData()
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
//                return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
            }

            guard let res = response as? [String: Any] else {
                print("Response was unable to be retrieved.")
                return completion(false, nil)
//                return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
            }

            guard let data = res["data"] as? [String: Any] else {
                print("Data attribute does not exist for the response.")
                return completion(false, nil)
//                return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
            }

            if let rawData = data["users"] as? [String: Any], let userData = User(JSON: rawData), let uid = userData.uid {
                print("Match exists")
                completion(true, userData)
//                return completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]), nil)
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

    @IBAction func goToNext(_ sender: UIButton) {
        goToNextUser()
    }

    func showErrorAlert(_ error: DadHiveError) {
        SVProgressHUD.showError(withStatus: error.rawValue)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
    }
}

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

extension UserProfileVC: SwipingDelegate {
    func didLike(user: User) {
        self.showHUD("Liking User", withDuration: 30.0)
        like(user: user) { (success, user) in
            self.dismissHUD()
            if (success) {
                if let user = user {
                    let matchVC = MatchVC(user: user)
                    self.present(matchVC, animated: true, completion: {
                        self.goToNextUser()
                    })
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

extension UserProfileVC {
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
    }

    func showHUD(_ text: String = "Finding Users", withDuration duration: TimeInterval? = 4.0) {
        APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: duration), title: nil, message: text, completion: nil)
    }

    func dismissHUD() {
        APESuperHUD.dismissAll(animated: true)
    }

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

    func loadUsers(_ completion: @escaping(Error?, Users?) -> Void) {
        if
            let lat = CurrentUser.shared.user?.settings?.location?.addressLat,
            let long = CurrentUser.shared.user?.settings?.location?.addressLong,
            let radius = CurrentUser.shared.user?.settings?.maxDistance,
            let pageNo = CurrentUser.shared.user?.currentPage,
            let userId = CurrentUser.shared.user?.uid
        {
            let parameters: [String: Any] = [
                "userId": userId,
                "latitude": Double(lat),
                "longitude": Double(long),
                "maxDistance": Double(radius),
                "pageNo": pageNo,
                "lastId": CurrentUser.shared.user!.lastId ?? "",
                "ageRangeId": CurrentUser.shared.user!.settings?.ageRange?.id ?? 4
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
}
