//
//  ViewProfileVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 3/19/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD
import APESuperHUD

class ViewProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblMain: UITableView!
    @IBOutlet weak var btnBack: UIButton!

    var user: User?

    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = ""
        return cell
    }

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
        showHUD()
    }

    func showHUD(_ text: String = "Loading User") {
        APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: 4.0), title: nil, message: text, completion: nil)
    }

    func dismissHUD() {
        APESuperHUD.dismissAll(animated: true)
    }

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
