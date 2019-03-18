//
//  ModuleHandler.swift
//  test
//
//  Created by Michael Westbrooks on 11/11/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import SDWebImage

class ModuleHandler {

    var awsService: AWSService
    var firebaseRepository: FIRRepository
    var testDataGrabberModule: TestDataGrabberModule
    var googleAdMobManager: GoogleAdMobManager
    var locationManager: LocationManagerModule
    var notificationManager: NotificationsManagerModule
    
    init() {
        print(" \(kAppName) | Module Handler Initialized")
        IQKeyboardManager.shared.enable = true

        self.awsService = AWSService.shared
        self.firebaseRepository = FIRRepository.shared
        self.testDataGrabberModule = TestDataGrabberModule.shared
        SDWebImageManager.shared().imageDownloader?.maxConcurrentDownloads = kMaxConcurrentImageDownloads
        self.googleAdMobManager = GoogleAdMobManager.shared
        self.locationManager = LocationManagerModule.shared
        self.notificationManager = NotificationsManagerModule.shared
    }

    deinit {
        print("Modulehandler is being deinitialized")
    }
}
