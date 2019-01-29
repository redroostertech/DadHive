//
//  DHInfoCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class DHInfoCell: UITableViewCell {

    public static var infoIndex = 0

    @IBOutlet private var imgvwInfoType: UIImageView!
    @IBOutlet private var lblInfo: UILabel!

    var loadUser: User? {
        didSet {
            guard
                let user = self.loadUser,
                let infoArray = user.userInformation?.filter({
                    (info) -> Bool in
                    return info.userInfoType != "bio"
                })
                else { return }
            if DHInfoCell.infoIndex < (infoArray.count - 1) {
                let info = infoArray[DHInfoCell.infoIndex]
                self.lblInfo.text = info.userInfo
                DHInfoCell.infoIndex += 1
                return
            } else {
                return
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        imgvwInfoType.addGradientLayer(using: kAppCGColors)
        imgvwInfoType.makeAspectFill()
    }

    func infoType(_ type: String) {

    }

    func info(_ info: String) {
        self.lblInfo.text = info
    }

}
