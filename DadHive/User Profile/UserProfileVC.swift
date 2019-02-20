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

var count = 0

class UserProfileVC: UIViewController {

    @IBOutlet var tblMain: UITableView!
    @IBOutlet var btnNext: UIButton!

    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "No Data"
        return cell
    }
    var uniqueUsers = Array<[String: Any]>()
    var users = [User]()
    var currentUser: User?
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSuperHUD()

        self.tblMain.delegate = self
        self.tblMain.dataSource = self

        self.tblMain.register(UINib(nibName: "DHIntroCell", bundle: nil), forCellReuseIdentifier: "DHIntroCell")
        self.tblMain.register(UINib(nibName: "DHImageCell", bundle: nil), forCellReuseIdentifier: "DHImageCell")
        self.tblMain.register(UINib(nibName: "DHCarouselCell", bundle: nil), forCellReuseIdentifier: "DHCarouselCell")
        self.tblMain.register(UINib(nibName: "DHInfoCell", bundle: nil), forCellReuseIdentifier: "DHInfoCell")
        self.tblMain.register(UINib(nibName: "DHQuestionCell", bundle: nil), forCellReuseIdentifier: "DHQuestionCell")

        APESuperHUD.showOrUpdateHUD(icon: .happyFace,
                                    message: "Finding Users",
                                    duration: 1000.0,
                                    particleEffectFileName: "FireFliesParticle",
                                    presentingView: self.view,
                                    completion: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(UserProfileVC.saveLocation(_:)),
                                       name: Notification.Name(rawValue: kSaveLocationObservationKey),
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(UserProfileVC.addUser(_:)),
                                       name: Notification.Name(rawValue: kAddUserObservationKey),
                                       object: nil)

        LocationManagerModule.shared.requestLocation()

        self.loadUsers {
            APESuperHUD.removeHUD(animated: true, presentingView: self.view)
            self.tblMain.reloadData()
        }

    }

    @objc
    func saveLocation(_ notification: Notification) {
        LocationManagerModule.shared.getUserLocation {
            (location) in
            APESuperHUD.removeHUD(animated: true, presentingView: self.view)
            if let _ = location {
                self.loadUsers {
                    self.tblMain.reloadData()
                }
            } else {
                self.showErrorAlert(DadHiveError.noMoreUsersAvailable)
            }
        }
    }

    @objc
    func addUser(_ notification: Notification) {
        if
            let userData = notification.userInfo?["user"] as? [String: Any],
            let u = User(JSON: userData),
            u.uid != CurrentUser.shared.user?.uid ?? "",
            self.users.contains(where: { (user) -> Bool in
                return user.key == (userData["key"] as? String) ?? ""
            }) == false
        {
            self.users.append(u)
            if self.users.count == 1 {
                self.load(user: self.users[0])
            }
        }
    }

    func loadUsers(_ completion: @escaping () -> Void) {
        if let lat = CurrentUser.shared.user?.settings?.location?.addressLat, let long = CurrentUser.shared.user?.settings?.location?.addressLong, let radius = CurrentUser.shared.user?.settings?.maxDistance {

            FIRFirestoreDB.shared.retrieveUsersByLocationWithPagination(atLat: lat, andLong: long, withRadius: radius) {
                completion()
            }

        } else {

            FIRFirestoreDB.shared.retrieveUsers {
                (success, snapshot, error) in
                if let error = error {
                    print(error)
                    completion()
                } else {
                    guard let documents = snapshot?.filter({
                        (result) -> Bool in
                        let user = User(JSON: result.data())
                        return user?.uid != CurrentUser.shared.user?.uid ?? ""
                    }) else {
                        completion()
                        return
                    }
                    if documents.count > 0 {
                        self.load(user: User(JSON: documents[0].data())!)
                        for document in documents {
                            var rawData: [String: Any] = document.data()
                            rawData["snapshotKey"] = document.documentID
                            self.users.append(User(JSON: rawData)!)
                        }
                        completion()
                    } else {
                        completion()
                    }
                }
            }
        }
    }

    func load(user: User) {
        self.currentUser = user
        DefaultsManager().setDefault(withData: user.uid ?? "", forKey: kLastUser)
        tblMain.reloadData()
    }

    func goToNextUser() {
        guard let currentUser = CurrentUser.shared.user else {
            print("User is no longer signed in. Sign them out.")
            FIRAuthentication.shared.signout()
            return
        }
        guard currentUser.canSwipe == true else {
            print("No more swiping. Please purchase a new plan.")
            self.showErrorAlert(DadHiveError.maximumSwipesReached)
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

        if count % 5 == 0 {
            DispatchQueue.global(qos: .background).async {
                if let lat = CurrentUser.shared.user?.settings?.location?.addressLat, let long = CurrentUser.shared.user?.settings?.location?.addressLong, let radius = CurrentUser.shared.user?.settings?.maxDistance {

                    FIRFirestoreDB.shared.retrieveUsersByLocationWithPagination(atLat: lat, andLong: long, withRadius: radius) {
                        print("Done with retrieveUsersyLocationWithPagination")
                    }
                    
                } else {
                    FIRFirestoreDB.shared.retrieveNextUsers {
                        (success, snapshot, error) in
                        if let error = error {
                            print(error)
                        } else {
                            guard let documents = snapshot?.filter({
                                (result) -> Bool in
                                let user = User(JSON: result.data())
                                return user?.uid != CurrentUser.shared.user?.uid ?? ""
                            }) else {
                                return
                            }
                            if documents.count > 0 {
                                for document in documents {
                                    var rawData: [String: Any] = document.data()
                                    rawData["snapshotKey"] = document.documentID
                                    self.users.append(User(JSON: rawData)!)
                                }
                                print("Count of users array is \(self.users.count)")
                            }
                        }
                    }
                }
            }
        }

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
        return self.currentUser?.countForTable ?? 0
    }

    func configureCell(forTable tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {

        guard let user = self.currentUser else { return emptyCell }

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHIntroCell") as! DHIntroCell
            cell.loadUser = user
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DHImageCell") as! DHImageCell
            cell.delegate = self
            cell.loadUser = user
            return cell
        } else {
            if indexPath.row < user.countForTable {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHInfoCell") as! DHInfoCell
                cell.loadUser = user
                return cell
            }

            if indexPath.row >= user.countForTable {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHQuestionCell") as! DHQuestionCell
                cell.loadUser = user
                return cell
            } else {
                return emptyCell
            }
        }
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
    func didLikeUser() {
        goToNextUser()
    }

    func didNotLikeUser() {
        goToNextUser()
    }
}

extension UserProfileVC {
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

    func setupUI() {
        self.btnNext.applyCornerRadius()
    }
}
