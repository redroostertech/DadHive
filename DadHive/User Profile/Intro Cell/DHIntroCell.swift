//
//  DHIntroCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class DHIntroCell: UITableViewCell {

    @IBOutlet private var lblName: UILabel!
    @IBOutlet private var lblKids: UILabel!

    var loadUser: User? {
        didSet {
            guard let user = self.loadUser else { return }
            self.lblName.text = user.name?.userFullName
            self.lblKids.text = user.userKidsNames
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}
