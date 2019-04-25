//
//  FIRAPIService.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/17/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import Firebase

class FIRRepository {
    static let shared = FIRRepository()
    var db: FIRRealtimeDB!
    var firestore: FIRFirestoreDB!
    var auth: FIRAuthentication!
    var storage: FIRStorage!
    private init() {
        print(" \(kAppName) | FIRRepository Handler Initialized")
        FirebaseApp.configure()
        self.db = FIRRealtimeDB.shared
        self.auth = FIRAuthentication.shared
        self.firestore = FIRFirestoreDB.shared
        self.storage = FIRStorage.shared
    }
}

class FIRStorage {
    static let shared = FIRStorage()
    private var storageRef: StorageReference!

    private init() {
        self.storageRef = Storage.storage().reference()
    }

    private func clearDocReference() {

    }

    func upload(data: Data) {
        
    }
}
