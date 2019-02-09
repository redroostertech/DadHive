//
//  Main.swift
//  codewithmike
//
//  Created by Michael Westbrooks on 11/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

var count = 0

class UserProfileVC: UIViewController {

    @IBOutlet var tblMain: UITableView!
    @IBOutlet var btnNext: UIButton!

    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "No Data"
        return cell
    }
    var users = [User]()
    var currentUser: User?
    var locationModule = LocationManagerModule()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnNext.applyCornerRadius()

        self.tblMain.delegate = self
        self.tblMain.dataSource = self

        self.tblMain.register(UINib(nibName: "DHIntroCell", bundle: nil), forCellReuseIdentifier: "DHIntroCell")
        self.tblMain.register(UINib(nibName: "DHImageCell", bundle: nil), forCellReuseIdentifier: "DHImageCell")
        self.tblMain.register(UINib(nibName: "DHCarouselCell", bundle: nil), forCellReuseIdentifier: "DHCarouselCell")
        self.tblMain.register(UINib(nibName: "DHInfoCell", bundle: nil), forCellReuseIdentifier: "DHInfoCell")
        self.tblMain.register(UINib(nibName: "DHQuestionCell", bundle: nil), forCellReuseIdentifier: "DHQuestionCell")

        locationModule.requestLocation()
        locationModule.getUserLocation {
            (location) in
            if let location = location {
                loadUsers {
                    self.tblMain.reloadData()
                }
            } else {

            }
        }
//        locationModule.getUserLocation {
//            self.updateUser(withData: ["userLocation": location.toDict], completion: {
//                (error) in
//                if let _ = error {
//                    print(error!)
//                    completion()
//                } else {
//                    completion()
//                }
//            })
//        } else {
//            completion()
//        }
    }

    func loadUsers(_ completion: @escaping () -> Void) {
        FIRFirestoreDB.shared.retrieveUsers {
            (success, snapshot, error) in
            if let error = error {
                print(error)
                completion()
            } else {
                guard let documents = snapshot?.filter({
                    (result) -> Bool in
                    let user = User(JSON: result.data())
                    return user?.userId != CurrentUser.shared.user?.userId
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

    func load(user: User) {
        self.currentUser = user

        //  Save last user
        DefaultsManager().setDefault(withData: user.userId, forKey: kLastUser)

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

        if count % 3 == 0 {
            DispatchQueue.global(qos: .background).async {
                print("In background")
                FIRFirestoreDB.shared.retrieveNextUsers {
                    (success, snapshot, error) in
                    if let error = error {
                        print(error)
                    } else {
                        guard let documents = snapshot?.filter({
                            (result) -> Bool in
                            let user = User(JSON: result.data())
                            return user?.userId != CurrentUser.shared.user?.userId
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
            if indexPath.row < user.maxCountForInfo {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DHInfoCell") as! DHInfoCell
                cell.loadUser = user
                return cell
            }

            if indexPath.row >= user.maxCountForInfo {
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
