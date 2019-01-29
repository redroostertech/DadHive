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
    private init() {
        FirebaseApp.configure()
        self.db = FIRRealtimeDB.shared
        self.auth = FIRAuthentication.shared
        self.firestore = FIRFirestoreDB.shared
    }
}
