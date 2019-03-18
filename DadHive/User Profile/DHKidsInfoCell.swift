//
//  DHKidsInfoCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 3/3/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class DHKidsInfoCell: UITableViewCell {

    @IBOutlet private var lblKidsBio: UILabel!
    @IBOutlet private var lblKidsAgeRanges: UILabel!
    @IBOutlet private var imgKids: UIImageView!

    var loadUser: User? {
        didSet {
            guard let user = self.loadUser else { return }
            self.lblKidsBio.text = user.infoSectionTwo?.filter({
                (item) -> Bool in
                return item.type == "kidsBio"
            }).first?.info ?? "No location known"
            self.lblKidsAgeRanges.text = user.infoSectionTwo?.filter({
                (item) -> Bool in
                return item.type == "kidsAges"
            }).first?.info ?? "No location known"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        imgKids.applyCornerRadius(0.25)
        imgKids.makeAspectFill()
    }

    
}
