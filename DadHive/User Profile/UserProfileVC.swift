//
//  Main.swift
//  codewithmike
//
//  Created by Michael Westbrooks on 11/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class UserProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipingDelegate {

    @IBOutlet var tblMain: UITableView!
    @IBOutlet var btnNext: UIButton!

    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "No Data"
        return cell
    }
    var users = [User]()
    var currentUser: User?
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnNext.applyCornerRadius()

//        let nextDateString = DefaultsManager().retrieveStringDefault(forKey: "nextActiveDate")
//        let nextDateFormatter = DateFormatter()
//        nextDateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        nextDateFormatter.timeZone = TimeZone.current
//        nextDateFormatter.dateFormat = CustomDateFormat.regular.rawValue
//        self.nextActiveDate = nextDateFormatter.date(from: nextDateString ?? "")

        self.tblMain.delegate = self
        self.tblMain.dataSource = self

        self.tblMain.register(UINib(nibName: "DHIntroCell", bundle: nil), forCellReuseIdentifier: "DHIntroCell")
        self.tblMain.register(UINib(nibName: "DHImageCell", bundle: nil), forCellReuseIdentifier: "DHImageCell")
        self.tblMain.register(UINib(nibName: "DHCarouselCell", bundle: nil), forCellReuseIdentifier: "DHCarouselCell")
        self.tblMain.register(UINib(nibName: "DHInfoCell", bundle: nil), forCellReuseIdentifier: "DHInfoCell")
        self.tblMain.register(UINib(nibName: "DHQuestionCell", bundle: nil), forCellReuseIdentifier: "DHQuestionCell")

        loadUsers {
            self.tblMain.reloadData()
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
                        self.users.append(User(JSON: document.data())!)
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
        tblMain.reloadData()
    }

    func goToNextUser() {
        if (CurrentUser.shared.user?.userCanSwipe ?? true) {
            if count < users.count - 1 {
                if count < 10 {
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
                                            self.users.append(User(JSON: document.data())!)
                                        }
                                        print("Count of users array is \(self.users.count)")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("No more swiping. Please purchase a new plan.")
                    CurrentUser.shared.user?.disableSwiping()
                }
            } else {
                print("No more users.")
            }
        } else {
            print("No more swiping. Please purchase a new plan.")
        }
    }

    @IBAction func goToNext(_ sender: UIButton) {
        goToNextUser()
    }

    func didLikeUser() {
        goToNextUser()
    }

}
