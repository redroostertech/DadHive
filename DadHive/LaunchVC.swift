//
//  LaunchVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/29/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        ModuleHandler.shared.firebaseRepository.auth.sessionCheck()
    }
}
