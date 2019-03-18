//
//  GoogleAdMobManager.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GoogleAdMobManager {
    static let shared = GoogleAdMobManager()
    private init() {
        print(" \(kAppName) | GoogleAdMobManager Handler Initialized")
        GADMobileAds.configure(withApplicationID: kAdMobApplicationID)
    }
}
