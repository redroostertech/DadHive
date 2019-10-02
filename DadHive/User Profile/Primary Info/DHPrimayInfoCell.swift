//
//  DHInfoCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK

class DHPrimaryInfoCell: UITableViewCell {

    public static var infoIndex = 0

    @IBOutlet weak private var imgLocation: UIImageView!
    @IBOutlet weak private var lblLocation: UILabel!
    @IBOutlet weak private var imgEducation: UIImageView!
    @IBOutlet weak private var lblEducation: UILabel!
    @IBOutlet weak private var imgJobTitle: UIImageView!
    @IBOutlet weak private var lblJobTitle: UILabel!
    @IBOutlet weak private var imgCompany: UIImageView!
    @IBOutlet weak private var lblCompany: UILabel!
    @IBOutlet weak private var imgBio: UIImageView!
    @IBOutlet weak private var lblBio: UILabel!

    var loadUser: User? {
        didSet {
            guard let user = self.loadUser else { return }
            self.lblLocation.text = user.infoSectionOne?.filter({
                (item) -> Bool in
                return item.type == "location"
            }).first?.info ?? "No location known"
            self.lblEducation.text = user.infoSectionOne?.filter({
                (item) -> Bool in
                return item.type == "schoolName"
            }).first?.info ?? "No location known"
            self.lblJobTitle.text = user.infoSectionOne?.filter({
                (item) -> Bool in
                return item.type == "jobTitle"
            }).first?.info ?? "No location known"
            self.lblCompany.text = user.infoSectionOne?.filter({
                (item) -> Bool in
                return item.type == "companyName"
            }).first?.info ?? "No location known"
            self.lblBio.text = user.infoSectionOne?.filter({
                (item) -> Bool in
                return item.type == "bio"
            }).first?.info ?? "No location known"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        imgLocation.applyCornerRadius(0.25)
        imgLocation.makeAspectFill()
        imgEducation.applyCornerRadius(0.25)
        imgEducation.makeAspectFill()
        imgJobTitle.applyCornerRadius(0.25)
        imgJobTitle.makeAspectFill()
        imgCompany.applyCornerRadius(0.25)
        imgCompany.makeAspectFill()
        imgBio.applyCornerRadius(0.25)
        imgBio.makeAspectFill()
    }

}
