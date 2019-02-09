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
        self.dbRef.collection(collection).addDocument(data: data) {
            (error) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, "Placeholder", nil)
            }
        }
    }

    func delete(atID id: String, from collection: String, completion: @escaping(Bool, String?, Error?) -> Void) {
        self.dbRef.collection(collection).document(id).delete() {
            (error) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, "Placeholder", nil)
            }
        }
    }

    func retrieve(from collection: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        self.dbRef.collection(collection).getDocuments(completion: { (snapshot, error) in
            if error == nil {
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieve(byKey key: String, withValue value: String, from collection: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        self.dbRef.collection(collection).whereField(key, isEqualTo: value).getDocuments(completion: { (snapshot, error) in
            if error == nil {
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieve(usingPagination pagination: Bool = false,
                  startingAtDocument document: QueryDocumentSnapshot? = nil,
                  fromCollection collection: String,
                  orderedByKey key: String,
                  limitedTo limit: Int = 50,
                  completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void)
    {
        if pagination, let atDocument = document {
            self.dbRef.collection(collection).order(by: key).limit(to: limit).start(afterDocument: atDocument).getDocuments(completion: {
                (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
        } else {
            self.dbRef.collection(collection).order(by: key).limit(to: limit).getDocuments(completion: { (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
        }
    }

    func update(withData data: [String: Any], from collection: String, at document: String, completion: @escaping(Bool, Error?) -> Void) {
        self.dbRef.collection(collection).document(document).setData(data, options: SetOptions.merge(), completion: {
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
        self.dbRef = nil
    }
}

//  MARK:- All User Methods
//  Consider abstracting it out into its own manager.
extension FIRFirestoreDB {
    func retrieveUser(withId id: String, completion: @escaping(Bool, QueryDocumentSnapshot?, Error?) -> Void) {
        self.retrieve(byKey: "uid", withValue: id, from: kUsers) { (success, documents, error) in
            if error == nil, let documents = documents, documents.count > 0 {
                completion(true, documents[0], nil)
            } else {
                completion(false, nil, error)
            }
        }
    }

    func retrieveUsers(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        if let lastUserKey = DefaultsManager().retrieveStringDefault(forKey: kLastUser) {
            print("LastUserKey exists")
            self.retrieveUser(withId: lastUserKey) {
                (success, document, error) in
                if error == nil, let document = document {
                    self.retrieve(usingPagination: true, startingAtDocument: document, fromCollection: kUsers, orderedByKey: "uid", limitedTo: 10, completion: { (success, documents, error) in
                        if error == nil, let documents = documents {
                            self.lastUser = documents.last
                            completion(true, documents, nil)
                        } else {
                            completion(false, nil, error)
                        }
                    })
                } else {
                    completion(false, nil, error)
                }
            }
        } else {
            print("LastUserKey does not exist")
            self.retrieve(fromCollection: kUsers, orderedByKey: "uid", limitedTo: 10, completion: { (success, documents, error) in
                if error == nil, let documents = documents {
                    self.lastUser = documents.last
                    completion(true, documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
        }
    }

    func retrieveNextUsers(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        guard let last = self.lastUser else {
            print("No last user captured")
            completion(false, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
            return
        }

        self.retrieve(usingPagination: true, startingAtDocument: last, fromCollection: kUsers, orderedByKey: "uid", limitedTo: 10, completion: { (success, documents, error) in
            if error == nil, let documents = documents {
                self.lastUser = documents.last
                completion(true, documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func deleteAllUsers() {
        self.retrieve(from: kUsers) { (success, documents, error) in
            if let _ = error {
                print("There was an error retrieving users.")
            } else {
                guard let documents = documents?.filter({
                    (result) -> Bool in
                    let user = User(JSON: result.data())
                    return user?.userId != CurrentUser.shared.user?.userId
                }) else {
                    print("Error filtering snapshot documents")
                    return
                }
                for document in documents {
                    self.delete(atID: document.documentID, from: kUsers, completion: { (success, result, error) in
                        if let _ = error {
                            print("There was an error deleting user")
                        }
                    })
                }
                print("Completed deleting users")
            }
        }
    }
}
