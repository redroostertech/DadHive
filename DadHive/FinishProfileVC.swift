//
//  FinishProfileVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/26/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class ProfileSetupFlowManager {

    static let shared = ProfileSetupFlowManager()
    private var userProfile: [String: Any]!

    private init() {
        userProfile = [String: Any]()
    }

    func addData(usingKey key: String, andValue value: String) {
        userProfile[key] = value
    }

    func addData(usingKey key: String, andValue value: Int) {
        userProfile[key] = value
    }

    func addData(usingKey key: String, andValue value: Bool) {
        userProfile[key] = value
    }

    func addData(usingKey key: String, andValue value: Double) {
        userProfile[key] = value
    }
    
    func addData(usingKey key: String, andValue value: [String: Any]) {
        userProfile[key] = value
    }
}

class FinishProfileStep1VC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

class FinishProfileStep2VC: UIViewController {

}

class FinishProfileStep3VC: UIViewController {

}
