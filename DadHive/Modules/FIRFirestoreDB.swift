import Foundation
import FirebaseCore
import FirebaseFirestore
import CoreLocation
import RRoostSDK

/*
 Wrapper for Firebase Firestore DB. Contains functions needed to communicate standardized GET, PUT, DELETE, POST methods
 */
private var dbRef: Firestore!
private var docRef: DocumentReference?
private var colRef: CollectionReference?
private var lastUser: QueryDocumentSnapshot?
private let limit = 50

class FIRFirestoreDB {
    // MARK: - Shared instance
    static let shared = FIRFirestoreDB()
    
    // MARK: - Lifecycle methods
    private init() {
        dbRef = Firestore.firestore()
    }

    // MARK: - Private member functions
    private func clearDocReference() {
        docRef = nil
        dbRef = nil
    }
}

// MARK: 'POST' Public member functions
extension FIRFirestoreDB {
    func add(data: [String: Any], to collection: String, completion: @escaping(Bool, String?, Error?) -> Void) {
        var ref: DocumentReference? = nil
        ref = dbRef.collection(collection).addDocument(data: data) {
            (error) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, ref?.documentID ?? nil, nil)
            }
        }
    }
}

// MARK: - 'DELETE' Public member functions
extension FIRFirestoreDB {
    func delete(atID id: String, from collection: String, completion: @escaping(Bool, String?, Error?) -> Void) {
        dbRef.collection(collection).document(id).delete() {
            (error) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, "Placeholder", nil)
            }
        }
    }
}

// MARK: - 'PUT' Public member functions
extension FIRFirestoreDB {
    func update(withData data: [String: Any], from collection: String, at document: String, completion: @escaping(Bool, Error?) -> Void) {
        dbRef.collection(collection).document(document).setData(data, merge: true) { (error) in
            if error == nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
}

// MARK: - 'GET' Public member functions
extension FIRFirestoreDB {
    func retrieve(from collection: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(collection).getDocuments(completion: { (snapshot, error) in
            if error == nil {
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieve(byKey key: String, withValue value: String, from collection: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(collection).whereField(key, isEqualTo: value).getDocuments(completion: { (snapshot, error) in
            if error == nil {
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieve(atDocument id: String, from collection: String, completion: @escaping(Bool, DocumentSnapshot?, Error?) -> Void) {
        dbRef.collection(collection).document(id).getDocument(completion: { (snapshot, error) in
            if error == nil {
                print(id)
                print(snapshot?.data())
                completion(true, snapshot, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieve(usingPagination pagination: Bool = false, startingAtDocument document: QueryDocumentSnapshot? = nil, fromCollection collection: String, orderedByKey key: String, limitedTo limit: Int = 50, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        if let atDocument = document {
            dbRef.collection(collection).order(by: key).limit(to: limit).start(afterDocument: atDocument).getDocuments(completion: {
                (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
        } else {
            dbRef.collection(collection).order(by: key).limit(to: limit).getDocuments(completion: { (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
        }
    }
}

//  MARK:- All User Methods
//  Consider abstracting it out into its own manager.
extension FIRFirestoreDB {

    func retrieveUser(withId id: String, completion: @escaping(Bool, QueryDocumentSnapshot?, Error?) -> Void) {
        retrieve(byKey: "uid", withValue: id, from: kUsers) { (success, documents, error) in
            if error == nil, let documents = documents, documents.count > 0 {
                print(documents[0])
                completion(true, documents[0], nil)
            } else {
                completion(false, nil, error)
            }
        }
    }

    func retrieveUsers(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        if let lastUserKey = DefaultsManager().retrieveStringDefault(forKey: kLastUser) {
            print("LastUserKey exists")
            retrieveUser(withId: lastUserKey) {
                (success, document, error) in
                if error == nil, let document = document {
                    self.retrieve(startingAtDocument: document,
                                  fromCollection: kUsers,
                                  orderedByKey: "uid",
                                  limitedTo: limit,
                                  completion: { (success, documents, error) in
                        if error == nil, let documents = documents {
                            lastUser = documents.last
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
            retrieve(fromCollection: kUsers, orderedByKey: "uid", limitedTo: limit, completion: { (success, documents, error) in
                if error == nil, let documents = documents {
                    lastUser = documents.last
                    completion(true, documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
        }
    }
    
    private func retrieveUserFromGeoPoint(withId id: String, completion: @escaping(Bool, DocumentSnapshot?, Error?) -> Void) {
        retrieve(atDocument: id, from: kUsers) { (success, document, error) in
            if error == nil, let document = document {
                completion(true, document, nil)
            } else {
                completion(false, nil, error)
            }
        }
    }

    func retrieveNextUsers(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        guard let last = lastUser else {
            print("No last user captured")
            completion(false, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
            return
        }

        retrieve(startingAtDocument: last, fromCollection: kUsers, orderedByKey: "uid", limitedTo: limit, completion: { (success, documents, error) in
            if error == nil, let documents = documents {
                lastUser = documents.last
                completion(true, documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

}

//  MARK:- Delete Objects
extension FIRFirestoreDB {

    //  MARK:- Users
    func deleteAllUsers() {
        retrieve(from: kUsers) { (success, documents, error) in
            if let _ = error {
                print("There was an error retrieving users.")
            } else {
                guard let documents = documents?.filter({
                    (result) -> Bool in
                    let raw = result.data()
                    guard let user = User(JSON: raw), let theirUid = user.uid else {
                        return false
                    }
                    return theirUid != "BJn3NIG3QIMBVvvIRl1n3McjaHt1"
                }) else {
                    print("Error filtering snapshot documents")
                    return
                }
                for document in documents {
                    self.delete(atID: document.documentID, from: kUsers, completion: { (success, result, error) in
                        if let _ = error {
                            print("There was an error deleting user")
                        } else {
                            print("Successfully deleted user")
                        }
                    })
                }
                print("Completed deleting users")
            }
        }
    }

    func deleteUser(withId id: String) {
        retrieve(byKey: "uid", withValue: id, from: kUsers) { (success, documents, error) in
            if error == nil, let documents = documents, documents.count > 0 {
                self.delete(atID: documents[0].documentID, from: kUsers, completion: { (success, result, error) in
                    if let _ = error {
                        print("There was an error deleting user")
                    } else {
                        print("Successfully deleted user")
                    }
                })
            } else {
                print("There was an error retrieving user.")
            }
        }
    }

    //  MARK:- Conversations
    func deleteAllConversations() {
        retrieve(from: kConversations) { (success, documents, error) in
            if let _ = error {
                print("There was an error retrieving conversations.")
            } else {
                guard let documents = documents else {
                    print("Error getting snapshot documents")
                    return
                }
                for document in documents {
                    self.delete(atID: document.documentID, from: kConversations, completion: { (success, result, error) in
                        if let _ = error {
                            print("There was an error deleting conversation")
                        } else {
                            print("Successfully deleted conversation")
                        }
                    })
                }
                print("Completed deleting conversations")
            }
        }
    }

    func deleteConversation(withId id: String) {
        retrieve(byKey: "id", withValue: id, from: kConversations) { (success, documents, error) in
            if error == nil, let documents = documents, documents.count > 0 {
                self.delete(atID: documents[0].documentID, from: kConversations, completion: { (success, result, error) in
                    if let _ = error {
                        print("There was an error deleting conversation")
                    } else {
                        print("Successfully deleted conversation")
                    }
                })
            } else {
                print("There was an error retrieving conversations.")
            }
        }
    }

    //  MARK:- Messages
    func deleteAllMessages() {
        retrieve(from: kMessages) { (success, documents, error) in
            if let _ = error {
                print("There was an error retrieving messages.")
            } else {
                guard let documents = documents else {
                    print("Error getting snapshot documents")
                    return
                }
                for document in documents {
                    self.delete(atID: document.documentID, from: kMessages, completion: { (success, result, error) in
                        if let _ = error {
                            print("There was an error deleting message")
                        } else {
                            print("Successfully deleted message")
                        }
                    })
                }
                print("Completed deleting messages")
            }
        }
    }

    func deleteMessages(withId id: String) {
        retrieve(byKey: "id", withValue: id, from: kMessages) { (success, documents, error) in
            if error == nil, let documents = documents, documents.count > 0 {
                self.delete(atID: documents[0].documentID, from: kMessages, completion: { (success, result, error) in
                    if let _ = error {
                        print("There was an error deleting message")
                    } else {
                        print("Successfully deleted message")
                    }
                })
            } else {
                print("There was an error retrieving message.")
            }
        }
    }

    func deleteAllMessagesInConversation(withId id: String) {
        retrieve(byKey: "conversationId", withValue: id, from: kMessages) { (success, documents, error) in
            if error == nil, let documents = documents, documents.count > 0 {
                for document in documents {
                    self.delete(atID: document.documentID, from: kMessages, completion: { (success, result, error) in
                        if let _ = error {
                            print("There was an error deleting message")
                        } else {
                            print("Successfully deleted message")
                        }
                    })
                }
                print("Completed deleting messages")
            } else {
                print("There was an error retrieving message.")
            }
        }
    }
}

//  MARK:- Pagination
extension FIRFirestoreDB {

}

//  MARK:- Finding all matches
extension FIRFirestoreDB {
    func retrieveMatches(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        retrieve(from: kMatches) { (success, documents, error) in
            if let err = error {
                print("There was an error retrieving matches.")
                completion(false, nil, err)
            } else {
                guard let documents = documents, documents.count > 0 else {
                    completion(false, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
                    return
                }
                completion(true, documents, nil)
            }
        }
    }

    func retrieveMatch(withId id: String, completion: @escaping(Bool, QueryDocumentSnapshot?, Error?) -> Void) {
        retrieve(byKey: "id", withValue: id, from: kMatches) { (success, documents, error) in
            if let err = error {
                print("There was an error retrieving matches.")
                completion(false, nil, err)
            } else {
                guard let documents = documents, documents.count > 0 else {
                    completion(false, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
                    return
                }
                completion(true, documents[0], nil)
            }
        }
    }

    func addMatch(withData data: Match, completion: @escaping(Match?) -> Void) {
        add(data: data.toJSON(), to: kMatches) { (success, result, error) in
            completion(data)
        }
    }

    func checkForMatch(recipient: String, sender: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(kMatches).whereField("senderId", isEqualTo: sender).whereField("recipientId", isEqualTo: recipient).getDocuments(completion: { (snapshot, error) in
            if error == nil {
                //                print(key)
                //                print(value)
                //                print(snapshot?.documents.count)
                //                print(snapshot?.documents.first?.data())
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

}

//  MARK:- Finding all conversations
extension FIRFirestoreDB {
    func retrieveConversations(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(kConversations)
            .order(by: "createdAt")
            .order(by: "recipientId")
            .order(by: "senderId")
            .whereField("recipientId", isEqualTo: CurrentUser.shared.user?.uid ?? "")
            .whereField("senderId", isEqualTo: CurrentUser.shared.user?.uid ?? "")
            .limit(to: 20)
            .getDocuments(completion: { (snapshot, error) in
            if error == nil {
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }

    func retrieveMyConversations(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(kConversations)
            .whereField("senderId", isEqualTo: CurrentUser.shared.user?.uid ?? "")
            .limit(to: 100)
            .getDocuments(completion: { (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
    }

    func retrieveOtherConversations(_ completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(kConversations)
            .whereField("recipientId", isEqualTo: CurrentUser.shared.user?.uid ?? "")
            .limit(to: 100)
            .getDocuments(completion: { (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            })
    }

    func retrieveConversation(withId id: String, completion: @escaping(Bool, QueryDocumentSnapshot?, Error?) -> Void) {
        retrieve(byKey: "id", withValue: id, from: kConversations) { (success, documents, error) in
            if let err = error {
                print("There was an error retrieving matches.")
                completion(false, nil, err)
            } else {
                guard let documents = documents, documents.count > 0 else {
                    completion(false, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.emptyAPIResponse.rawValue]))
                    return
                }
                completion(true, documents[0], nil)
            }
        }
    }

    func createConversation(withData data: Conversation, completion: @escaping(Conversation?) -> Void) {
        add(data: data.toJSON(), to: kConversations) { (success, result, error) in
            if let error = error {
                print("Error adding message to conversation.")
            } else {

            }
            completion(data)
        }
    }

    func checkForConversation(recipient: String, sender: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(kConversations).whereField("senderId", isEqualTo: sender).whereField("recipientId", isEqualTo: recipient).whereField("senderId", isEqualTo: recipient).whereField("recipientId", isEqualTo: sender).getDocuments(completion: { (snapshot, error) in
            if error == nil {
                //                print(key)
                //                print(value)
                //                print(snapshot?.documents.count)
                //                print(snapshot?.documents.first?.data())
                completion(true, snapshot?.documents, nil)
            } else {
                completion(false, nil, error)
            }
        })
    }
}

//  MARK:- Finding all messages
extension FIRFirestoreDB {
    func retrieveMessageFromConversation(withId id: String, completion: @escaping(Bool, [QueryDocumentSnapshot]?, Error?) -> Void) {
        dbRef.collection(kMessages)
            .order(by: "createdAt")
            .whereField("conversationId", isEqualTo: id)
            .limit(to: 40)
            .addSnapshotListener { (snapshot, error) in
                if error == nil {
                    completion(true, snapshot?.documents, nil)
                } else {
                    completion(false, nil, error)
                }
            }
    }

    func createMessage(withData data: Message, completion: @escaping(String?) -> Void) {
        add(data: data.toJSON(), to: kMessages) { (success, result, error) in
            completion(result)
        }
    }

}

