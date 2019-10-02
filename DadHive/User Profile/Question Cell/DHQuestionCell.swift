//
//  DHQuestionCell.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK

class DHQuestionCell: UITableViewCell {

    public static var infoIndex = 0

    @IBOutlet private var lblQuestion: UILabel!
    @IBOutlet private var lblResponse: UILabel!

    var loadUser: User? {
        didSet {
            guard
                let user = self.loadUser,
                let infoArray = user.infoSectionThree else { return }
            if DHQuestionCell.infoIndex > (infoArray.count - 1) { return } else {
                let info = infoArray[DHQuestionCell.infoIndex]
                self.lblQuestion.text = info.title ?? "No question"
                self.lblResponse.text = info.info ?? "No response"
                DHQuestionCell.infoIndex += 1
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        lblQuestion.makeTitleCase()
        lblQuestion.makeMultipleLines(2)
        lblResponse.makeMultipleLines()
    }

}
