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

    var userInfo: [String: Any]?
    var userInformationSectionTwo: [[String: Any]] = [
        [
            "type": "name",
            "title": "Name",
            "info": ""
        ],[
            "type": "age",
            "title": "Age",
            "info": ""
        ],[
            "type": "location",
            "title": "Location",
            "info": ""
        ],[
            "type": "bio",
            "title": "About Me",
            "info": ""
        ],[
            "type": "work",
            "title": "Work",
            "info": ""
        ],[
            "type": "jobTitle",
            "title": "Job Title",
            "info": ""
        ],[
            "type": "school",
            "title": "School / University",
            "info": ""
        ]
    ]

    var userInformationSectionThree: [[String: Any]] = [
        [
            "type": "kidsNames",
            "title": "Kids Names",
            "info": ""
        ],[
            "type": "kidsAges",
            "title": "Kids Ages",
            "info": ""
        ],[
            "type": "kidsBio",
            "title": "About My Kids",
            "info": ""
        ]
    ]

    var userInformationSectionFour: [[String: Any]] = [
        [
            "type": "questionOne",
            "title": "On our spare time, my kids and I like to...",
            "info": ""
        ],[
            "type": "questionTwo",
            "title": "Describe my kids in 3 words",
            "info": ""
        ],[
            "type": "questionThree",
            "title": "When I'm not with my kids, you will find me at...",
            "info": ""
        ]
    ]

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
        print(CurrentUser.shared.user)
        setupUI()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return userInformationSectionTwo.count
        case 2: return userInformationSectionThree.count
        case 3: return userInformationSectionFour.count
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            userInfo = userInformationSectionTwo[indexPath.row]
            performSegue(withIdentifier: "goToEdit", sender: self)
        case 2:
            userInfo = userInformationSectionThree[indexPath.row]
            performSegue(withIdentifier: "goToEdit", sender: self)
        case 3:
            userInfo = userInformationSectionFour[indexPath.row]
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
        lblNameValue.text = String(describing: CurrentUser.shared.user?.name?.userFullName ?? "No Response")
        lblAgeValue.text = String(describing: CurrentUser.shared.user?.userAge ?? 0)
        lblLocationValue.text = String(describing: CurrentUser.shared.user?.userLocation ?? "No Response")
        lblBioValue.text = String(describing: CurrentUser.shared.user?.userBio ?? "No Response")
        lblWorkValue.text = String(describing: CurrentUser.shared.user?.userWork ?? "No Response")
        lblJobTitleValue.text = String(describing: CurrentUser.shared.user?.userJobTitle ?? "No Response")
        lblSchoolValue.text = String(describing: CurrentUser.shared.user?.userSchool ?? "No Response")
        lblKidsNamesValue.text = String(describing: CurrentUser.shared.user?.userKidsNames ?? "No Response")
        lblKidsAgesValue.text = String(describing: CurrentUser.shared.user?.userKidsAges ?? "No Response")
        lblKidsBioValue.text = String(describing: CurrentUser.shared.user?.userKidsBio ?? "No Response")
        lblQuestionOneValue.text = String(describing: CurrentUser.shared.user?.userQuestionOne ?? "No Response")
        lblQuestionTwoValue.text = String(describing: CurrentUser.shared.user?.userQuestionTwo ?? "No Response")
        lblQuestionThreeValue.text = String(describing: CurrentUser.shared.user?.userQuestionThree ?? "No Response")
    }
}
