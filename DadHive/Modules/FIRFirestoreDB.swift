//
//  FIRFirestoreDB.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/18/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FIRFirestoreDB {
    static let shared = FIRFirestoreDB()
    private var dbRef: Firestore!
    private var docRef: DocumentReference?
    private var colRef: CollectionReference?
    private var lastUser: QueryDocumentSnapshot?
    private init() {
        self.dbRef = Firestore.firestore()
    }
    func add(data: [String: Any], to collection: String, completion: @escaping(Bool, String?, Error?) -> Void) {
        self.docRef = self.dbRef.collection(collection).addDocument(data: data) {
            (error) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, "Placeholder", nil)
            }
        }
    }
    func retrieve(data: [String: Any]?, from collection: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        self.colRef = self.dbRef.collection(collection)
        if let data = data {
            for key in data.keys {
                let value = data[key]
                self.colRef?.whereField(key, isEqualTo: value)
            }
            self.colRef?.getDocuments(completion: { (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
        }
    }

    func update(withData data: [String: Any], from collection: String, at document: String, completion: @escaping(Bool, Error?) -> Void) {
        self.docRef = self.dbRef.collection(collection).document(document)
        self.docRef?.setData(data, options: SetOptions.merge(), completion: {
            (error) in
            if error == nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        })
    }
    private func clearDocReference() {
        self.docRef = nil
    }
}

//  All User Methods
extension FIRFirestoreDB {
    func retrieveUser(withId id: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        self.dbRef.collection(kUsers).whereField("uid", isEqualTo: id).getDocuments(completion: { (snapshot, error) in
            if error == nil {
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieveUsers(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        self.dbRef.collection(kUsers).order(by: "uid").limit(to: 10).getDocuments(completion: {
            (snapshot, error) in
            if error == nil {
                self.lastUser = snapshot?.documents.last
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieveNextUsers(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        guard let last = self.lastUser else {
            print("No last user captured")
            completion(false, nil, Errors.EmptyAPIResponse)
            return
        }

        self.dbRef.collection(kUsers).order(by: "uid").limit(to: 10).start(afterDocument: last).getDocuments(completion: {
            (snapshot, error) in
            if error == nil {
                self.lastUser = snapshot?.documents.last
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }
}
