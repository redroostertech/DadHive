import Foundation
import FirebaseCore
import FirebaseStorage

class FIRRepository {
    static let shared = FIRRepository()
    var db: FIRRealtimeDB!
    var firestore: FIRFirestoreDB!
    var storage: FIRStorage!
    private init() {
        print(" \(kAppName) | FIRRepository Handler Initialized")
        FirebaseApp.configure()
        self.db = FIRRealtimeDB.shared
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
