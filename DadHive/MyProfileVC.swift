//
//  MyProfileVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class MyProfileVC: UITableViewController {

    @IBOutlet var btnProfileImages: [UIButton]!
    @IBOutlet var lblName: TitleLabel!
    @IBOutlet var lblNameValue: ValueLabel!
    @IBOutlet var lblAge: TitleLabel!
    @IBOutlet var lblAgeValue: ValueLabel!
    @IBOutlet var lblLocation: TitleLabel!
    @IBOutlet var lblLocationValue: ValueLabel!
    @IBOutlet var lblBioValue: ValueLabel!
    @IBOutlet var lblBio: TitleLabel!
    @IBOutlet var lblWork: TitleLabel!
    @IBOutlet var lblWorkValue: ValueLabel!
    @IBOutlet var lblJobTitle: TitleLabel!
    @IBOutlet var lblJobTitleValue: ValueLabel!
    @IBOutlet var lblSchool: TitleLabel!
    @IBOutlet var lblSchoolValue: ValueLabel!
    @IBOutlet var lblKidsNamesValue: ValueLabel!
    @IBOutlet var lblKidsNames: TitleLabel!
    @IBOutlet var lblKidsAges: TitleLabel!
    @IBOutlet var lblKidsAgesValue: ValueLabel!
    @IBOutlet var lblKidsBio: TitleLabel!
    @IBOutlet var lblKidsBioValue: ValueLabel!
    @IBOutlet var lblQuestionOne: TitleLabel!
    @IBOutlet var lblQuestionOneValue: ValueLabel!
    @IBOutlet var lblQuestionTwo: TitleLabel!
    @IBOutlet var lblQuestionTwoValue: ValueLabel!
    @IBOutlet var lblQuestionThree: TitleLabel!
    @IBOutlet var lblQuestionThreeValue: ValueLabel!

    var userInfo: Info?
    var currentUser = CurrentUser.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarHairline()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        var x = 0
        while x < btnProfileImages.count {
            let button = btnProfileImages[x]
            button.tag = x
            button.contentMode = .scaleAspectFill
            x += 1
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return currentUser.user?.infoSectionOne?.count ?? 0
        case 2: return currentUser.user?.infoSectionTwo?.count ?? 0
        case 3: return currentUser.user?.infoSectionThree?.count ?? 0
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard let data = currentUser.user?.infoSectionOne else {
                return
            }
            userInfo = data[indexPath.row]
            performSegue(withIdentifier: "goToEdit", sender: self)
        case 2:
            guard let data = currentUser.user?.infoSectionTwo else {
                return
            }
            userInfo = data[indexPath.row]
            performSegue(withIdentifier: "goToEdit", sender: self)
        case 3:
            guard let data = currentUser.user?.infoSectionThree else {
                return
            }
            userInfo = data[indexPath.row]
            performSegue(withIdentifier: "goToEdit", sender: self)
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        clearNavigationBackButtonText()
        if segue.identifier == "goToEdit" {
            let destination = segue.destination as! EditVC
            destination.userInfo = userInfo
            destination.type = 1
        }
    }

}

extension MyProfileVC {
    func setupUI() {
        lblNameValue.text = String(describing: currentUser.user?.name?.fullName ?? "No Response")
        lblAgeValue.text = String(describing: currentUser.user?.age ?? 0)
        lblLocationValue.text = String(describing: currentUser.user?.settings?.location?.getString ?? "No Response")
        lblBioValue.text = String(describing: currentUser.user?.bio ?? "No Response")
        lblWorkValue.text = String(describing: currentUser.user?.companyName ?? "No Response")
        lblJobTitleValue.text = String(describing: currentUser.user?.jobTitle ?? "No Response")
        lblSchoolValue.text = String(describing: currentUser.user?.schoolName ?? "No Response")
        lblKidsNamesValue.text = String(describing: currentUser.user?.kidsNames ?? "No Response")
        lblKidsAgesValue.text = String(describing: currentUser.user?.kidsAges ?? "No Response")
        lblKidsBioValue.text = String(describing: currentUser.user?.kidsBio ?? "No Response")
        lblQuestionOne.text = String(describing: currentUser.user?.questionOneTitle ?? "Select a question")
        lblQuestionOneValue.text = String(describing: currentUser.user?.questionOneResponse ?? "No Response")
        lblQuestionTwo.text = String(describing: currentUser.user?.questionTwoTitle ?? "Select a question")
        lblQuestionTwoValue.text = String(describing: currentUser.user?.questionTwoResponse ?? "No Response")
        lblQuestionThree.text = String(describing: currentUser.user?.questionThreeTitle ?? "Select a question")
        lblQuestionThreeValue.text = String(describing: currentUser.user?.questionThreeResponse ?? "No Response")
        tableView.reloadData()
    }
}
