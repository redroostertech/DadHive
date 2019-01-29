//
//  ModuleHandler.swift
//  test
//
//  Created by Michael Westbrooks on 11/11/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

class ModuleHandler {
    
    static let shared = ModuleHandler()

    var keyboardManager: KeyboardManager
    var awsService: AWSService
    var apiRepository: APIRepository
    var firebaseRepository: FIRRepository
    var testDataGrabberModule: TestDataGrabberModule
    var sdWebImageManagerExt: SDWebImageManagerExt
    var googleAdMobManager: GoogleAdMobManager
    
    //  Add additional services as needed
    //  ...
    
    private init() {
        print(" \(kAppName) | Module Handler Initialized")
        self.keyboardManager = KeyboardManager.shared
        self.awsService = AWSService.shared
        self.apiRepository = APIRepository.shared
        self.firebaseRepository = FIRRepository.shared
        self.testDataGrabberModule = TestDataGrabberModule.shared
        self.sdWebImageManagerExt = SDWebImageManagerExt.shared
        self.googleAdMobManager = GoogleAdMobManager.shared
    }
}

class KeyboardManager {
    static let shared = KeyboardManager()
    private init() {
        IQKeyboardManager.shared.enable = true
    }
}
