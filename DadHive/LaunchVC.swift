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
        if let _ = DefaultsManager().retrieveAnyDefault(forKey: kAuthorizedUser) {
            FIRRepository.shared.auth.checkSession(nil)
        } else {
            FIRRepository.shared.auth.signout()
        }
    }
}
